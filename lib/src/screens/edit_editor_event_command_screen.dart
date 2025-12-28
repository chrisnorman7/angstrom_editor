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
            if (door == null)
              ListTile(
                title: const Text('Add door'),
                onTap: () => context.pushWidgetBuilder(
                  (_) => SelectDoorTargetScreen(
                    roomsDirectory: widget.editorContext.file.parent,
                    onChange: (final value) {
                      command.door = EditorDoor(
                        targetObjectId: value.object.id,
                        x: value.object.x,
                        y: value.object.y,
                        targetRoomId: value.room.id,
                      );
                      save();
                    },
                    getSound: widget.editorContext.getSound,
                  ),
                ),
              )
            else
              PerformableActionsListTile(
                actions: [
                  PerformableAction(
                    name: 'Delete door',
                    activator: deleteShortcut,
                    invoke: () {
                      command.door = null;
                      save();
                    },
                  ),
                ],
                title: const Text('Edit Door'),
                onTap: () => context.pushWidgetBuilder(
                  (_) => EditDoorScreen(
                    editorContext: widget.editorContext,
                    door: door,
                  ),
                ),
              ),
            CheckboxListTile(
              value: command.hasHandler,
              onChanged: (final value) {
                command.hasHandler = !command.hasHandler;
                save();
              },
              title: const Text('Extra code needed'),
            ),
            EngineCommandListTile(
              engineCommands: widget.editorContext.engineCommands,
              onChange: (final value) {
                command.engineCommandId = value?.id;
                save();
              },
              engineCommandId: command.engineCommandId,
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
