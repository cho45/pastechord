# Paste Chord Plugin

Paste Chord is a simple dialog-based plugin for MuseScore 4 that allows you to copy and paste chords efficiently.

## Features & Benefits

- **Replace only the chord notes in bulk while preserving note values (rhythm/duration)**
- Greatly streamlines repetitive editing and arrangement tasks by letting you overwrite multiple chords at once
- Also supports copying and pasting fret information for tablature (e.g., guitar)

## Installation

1. Launch MuseScore and go to Edit → Preferences → Folders.
2. Check the path of the "Plugins" folder.
3. Copy the `pastechord.qml` file from this repository into that Plugins folder.
4. In MuseScore, open Plugins → Plugin Manager and enable "Paste Chord".

## Usage

1. Select a chord in MuseScore.
2. Go to Plugins → Paste Chord to open the dialog.
3. Click the "Copy Chord" button to copy the chord, then select the range where you want to paste and click "Paste Chord".
4. Click "Close" to exit the dialog if needed.

## Overview

- Copies pitch, Tpc, and fret information of the selected chord
- Pastes the copied chord to all chords in the selected range

## Limitations & Notes

- Due to MuseScore plugin system limitations, the OS clipboard cannot be accessed. The plugin temporarily stores the copied chord internally, so you must use the "Copy Chord" and "Paste Chord" buttons.
- The MuseScore plugin API is unstable and may change or break in future versions or environments. This plugin may stop working after MuseScore updates.

## Additional Notes

- If you select a non-chord element or no range, an error message will be shown.
- Fret information (string, fret) is only copied/pasted if present.
- MuseScore 4 is required to use this plugin.

## License

MIT

---

For questions or bug reports, please open an Issue.
