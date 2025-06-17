import QtQuick
import QtQuick.Controls

import MuseScore 3.0
import Muse.Ui
import Muse.UiComponents

MuseScore {
    version: "1.0"
    description: qsTr("A plugin to copy and paste chords")
    title: "Paste Chord"
    categoryCode: "paste-chord"
    thumbnailName: "note_names.png"
    pluginType: "dialog"
    
    requiresScore: true
    
    width: 300
    height: 150
    
    property var copiedChord: null
    property string statusMessage: qsTr("Select a chord and press the copy button")
    
    onRun: {}
    
    function copyChord() {
        var cursor = curScore.newCursor()
        cursor.rewind(Cursor.SELECTION_START)
        
        if (!cursor.segment) {
            statusMessage = qsTr("No selection range")
            return
        }
        
        if (!cursor.element || cursor.element.type !== Element.CHORD) {
            statusMessage = qsTr("The selected element is not a chord")
            return
        }
        
        var chord = cursor.element
        copiedChord = {
            notes: [],
            frets: []
        }
        
        // Copy notes
        for (var i = 0; i < chord.notes.length; i++) {
            var note = chord.notes[i]
            copiedChord.notes.push({
                pitch: note.pitch,
                tpc: note.tpc
            })
            
            // Copy fret information for tablature
            if (note.fret !== undefined && note.string !== undefined) {
                copiedChord.frets.push({
                    string: note.string,
                    fret: note.fret
                })
            }
        }
        
        statusMessage = qsTr("Chord copied: ") + copiedChord.notes.length + qsTr(" notes")
    }
    
    function pasteChordToElement(chord) {
        try {
            if (chord.notes.length > 0) {
                // Remove all existing notes (leave the last one)
                while (chord.notes.length > 1) {
                    chord.remove(chord.notes[1])
                }
                
                // Change the first note
                var firstNote = chord.notes[0]
                firstNote.pitch = copiedChord.notes[0].pitch
                firstNote.tpc = copiedChord.notes[0].tpc
                
                // Set tablature info for the first note
                if (copiedChord.frets.length > 0 && copiedChord.frets[0]) {
                    var firstFret = copiedChord.frets[0]
                    if (firstFret.string !== undefined && firstFret.fret !== undefined) {
                        firstNote.string = firstFret.string
                        firstNote.fret = firstFret.fret
                    }
                }
                
                // Add the rest of the notes
                for (var i = 1; i < copiedChord.notes.length; i++) {
                    var noteData = copiedChord.notes[i]
                    var newNote = newElement(Element.NOTE)
                    newNote.pitch = noteData.pitch
                    newNote.tpc = noteData.tpc
                    
                    // Set tablature info if available
                    if (i < copiedChord.frets.length && copiedChord.frets[i]) {
                        var fretData = copiedChord.frets[i]
                        if (fretData.string !== undefined && fretData.fret !== undefined) {
                            newNote.string = fretData.string
                            newNote.fret = fretData.fret
                        }
                    }
                    
                    chord.add(newNote)
                }
            }
            return true
        } catch (e) {
            console.log("Chord paste error: " + e.message)
            return false
        }
    }
    
    function pasteChord() {
        if (!copiedChord) {
            statusMessage = qsTr("No chord has been copied")
            return
        }
        
        var cursor = curScore.newCursor()
        cursor.rewind(Cursor.SELECTION_START)
        
        if (!cursor.segment) {
            statusMessage = qsTr("No selection range")
            return
        }
        
        curScore.startCmd()
        
        var processedCount = 0
        var startTick = cursor.tick
        
        // Get the end position of the selection range
        var endCursor = curScore.newCursor()
        endCursor.rewind(Cursor.SELECTION_END)
        var endTick = endCursor.tick
        
        try {
            // Process all chords in the selection range
            cursor.rewind(Cursor.SELECTION_START)
            
            while (cursor.segment && cursor.tick < endTick) {
                if (cursor.element && cursor.element.type === Element.CHORD) {
                    if (pasteChordToElement(cursor.element)) {
                        processedCount++
                    }
                }
                
                if (!cursor.next()) {
                    break
                }
            }
            
            if (processedCount > 0) {
                statusMessage = qsTr("Chord pasted: ") + processedCount + qsTr(" places (") + copiedChord.notes.length + qsTr(" notes)")
            } else {
                statusMessage = qsTr("No chord found in the selection range")
            }
            
        } catch (e) {
            statusMessage = qsTr("Error occurred while pasting: ") + e.message
        }
        
        curScore.endCmd()
    }
    
    Item {
        id: window
        
        anchors.fill: parent
        
        StyledTextLabel {
            id: statusLabel
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 10
            wrapMode: Text.WordWrap
            text: statusMessage
        }
        
        Row {
            anchors.centerIn: parent
            spacing: 20
            
            FlatButton {
                id: copyButton
                text: qsTr("Copy Chord")
                width: 120
                onClicked: copyChord()
            }
            
            FlatButton {
                id: pasteButton  
                text: qsTr("Paste Chord")
                width: 120
                enabled: copiedChord !== null
                onClicked: pasteChord()
            }
        }
        
        FlatButton {
            id: closeButton
            text: qsTr("Close")
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.margins: 10
            onClicked: quit()
        }
    }
}
