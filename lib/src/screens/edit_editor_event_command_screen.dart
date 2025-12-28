import 'package:angstrom_editor/angstrom_editor.dart';
import 'package:angstrom_editor/src/widgets/sound_reference_list_tile.dart';
import 'package:backstreets_widgets/extensions.dart';
import 'package:backstreets_widgets/screens.dart';
import 'package:backstreets_widgets/shortcuts.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';

/// A screen for editing the given [command].
class EditEditorEventCommandScreen extends StatefulWidget {
  /// Create an instance.
  const EditEditorEventCommandScreen({
    required this.editorContext,
    required this.command,
    required this.onChange,
    super.key,
  });

  /// The editor context that [command] belongs to.
  final EditorContext editorContext;

  /// The command to edit.
  final EditorEventCommand command;

  /// The function to call when [command] changes.
  final VoidCallback onChange;

  /// Create state for this widget.
  @override
  EditEditorEventCommandScreenState createState() =>
      EditEditorEventCommandScreenState();
}

/// State for [EditEditorEventCommandScreen].
class EditEditorEventCommandScreenState
    extends State<EditEditorEventCommandScreen> {
  /// The command to edit.
  late final EditorEventCommand command;

  /// Initialise state.
  @override
  void initState() {
    super.initState();
    command = widget.command;
  }

  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final door = command.door;
    return Cancel(
      child: SimpleScaffold(
        title: 'Command Editor',
        body: ListView(
          children: [
            ListTile(
              autofocus: true,
              title: const Text('Comment'),
              subtitle: Text(command.comment),
              onTap: () => context.pushWidgetBuilder(
                (_) => EditCommentScreen(
                  onChange: (final value) {
                    command.comment = value ?? command.comment;
                    save();
                  },
                  comment: command.comment,
                ),
              ),
            ),
            TextListTile(
              value: command.spokenText ?? '',
              onChanged: (final value) {
                command.spokenText = value.trim().isEmpty ? null : value;
                save();
              },
              header: 'Speak text',
              labelText: 'Text',
              title: 'Spoken Text',
            ),
            SoundReferenceListTile(
              editorContext: widget.editorContext,
              onChange: (final value) {
                command.interfaceSound = value;
                save();
              },
              soundReference: command.interfaceSound,
              title: 'Interface sound',
            ),
            PerformableActionsListTile(
              actions: [
                if (door == null)
                  PerformableAction(
                    name: 'Make Door',
                    activator: doorShortcut,
                    invoke: () => context.pushWidgetBuilder(
                      (_) => SelectDoorTargetScreen(
                        roomsDirectory: widget.editorContext.file.parent,
                        onChange: (final value) {
                          final door = EditorDoor(
                            targetObjectId: value.object.id,
                            x: value.object.x,
                            y: value.object.y,
                            targetRoomId: value.room.id,
                          );
                          command.door = door;
                          save();
                        },
                        getSound: widget.editorContext.getSound,
                      ),
                    ),
                  )
                else ...[
                  PerformableAction(
                    name: 'Edit door',
                    activator: doorShortcut,
                    invoke: () => context.pushWidgetBuilder(
                      (_) => EditDoorScreen(door: door),
                    ),
                  ),
                  PerformableAction(
                    name: 'Delete door',
                    activator: deleteShortcut,
                    invoke: () {
                      command.door = null;
                      save();
                    },
                  ),
                ],
              ],
            ),
            CheckboxListTile(
              value: command.hasHandler,
              onChanged: (final value) {
                command.hasHandler = !command.hasHandler;
                save();
              },
              title: const Text('Extra code needed'),
            ),
          ],
        ),
      ),
    );
  }

  /// Save the [command].
  void save() {
    widget.editorContext.save();
    setState(() {});
    widget.onChange();
  }
}
