# Changelog

## 0.7.4

- Try and save focus when editing rooms, surfaces, and objects.
- Give new rooms filenames which match their actual names.
- Clear all files from the rooms directory before generating code.

## 0.7.3

- Added a link to the template repository.

## 0.7.2

- Objects with no `ambiance` will not have their `ambianceMaxDistance` generated.
- Use `const` for coordinates.

## 0.7.1

- Room files will now be renamed when the rooms themselves are renamed.

## 0.7.0

- Add the ability to copy a room ID.
- Added the door shortcut to copy door code for room objects.
- Handle renamed rooms more gracefully.
- Throw `InvalidDoorException` when a door is tested with an invalid room ID.
- Show build errors before writing code.

## 0.6.0

- Add call tracing for `EngineCommand`s.

## 0.5.0

- Create the rooms directory if it does not exist.
- Required `editorContext` in a few places.
- Add all rooms to the `CustomEngine` class.
- Add room name prefixes to object base classes.
- Allow the specifying of music fade times in `CustomEngine` classes.
- Fix a bug where surface events were not added.
- Added `LoadedRoom.className` and `LoadedRoom.getterName` to aid in code generation.

## 0.4.0

- Don't pass editor contexts around.
- Upgrade dependencies.

## 0.3.1

- Updated dependencies.

## 0.3.0

- Feat: Add a basic command editor.
- Fix: Show room names in generated source code.

## 0.2.0

- Feat: Set comments for the events which are defined in the editor.
- Feat: Specify events on rooms.
- Feat: Optionally play a sound when a build fails.
- Refactor: Updated dependencies.

## 0.1.0

- Update some `getSound`-related code.

## 0.0.4

- Code cleanup.

## 0.0.3

- Upgraded angstrom dependency.
- Enabled automatic publishing.

## 0.0.2

- Publish to GitHub.

## 0.0.1

- Initial release.
