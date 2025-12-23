import 'package:angstrom_editor/angstrom_editor.dart';
import 'package:angstrom_editor/src/widgets/sound_reference_list_tile.dart';
import 'package:backstreets_widgets/extensions.dart';
import 'package:backstreets_widgets/screens.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';

/// A screen for editing the given [command].
class EditEditorEventCommandScreen extends StatefulWidget {
  /// Create an instance.
  const EditEditorEventCommandScreen({
    required this.command,
    required this.onChange,
    super.key,
  });

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
  Widget build(final BuildContext context) => Cancel(
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
            onChange: (final value) {
              command.interfaceSound = value;
              save();
            },
            soundReference: command.interfaceSound,
            title: 'Interface sound',
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

  /// Save the [command].
  void save() {
    EditorContextScope.of(context).editorContext.save();
    setState(() {});
    widget.onChange();
  }
}
