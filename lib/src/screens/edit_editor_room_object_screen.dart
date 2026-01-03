import 'package:angstrom_editor/angstrom_editor.dart';
import 'package:backstreets_widgets/screens.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';

/// A screen for editing [object].
class EditEditorRoomObjectScreen extends StatefulWidget {
  /// Create an instance.
  const EditEditorRoomObjectScreen({
    required this.editorContext,
    required this.object,
    required this.onChange,
    super.key,
  });

  /// The editor context to use.
  final EditorContext editorContext;

  /// The surface to edit.
  final EditorRoomObject object;

  /// The function to call when [object] changes.
  final ValueChanged<EditorRoomObject> onChange;

  /// Create state for this widget.
  @override
  EditEditorRoomObjectScreenState createState() =>
      EditEditorRoomObjectScreenState();
}

/// State for [EditEditorRoomObjectScreen].
class EditEditorRoomObjectScreenState
    extends State<EditEditorRoomObjectScreen> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final object = widget.object;
    return Cancel(
      child: TabbedScaffold(
        tabs: [
          TabbedScaffoldTab(
            title: 'Settings',
            icon: const Icon(Icons.settings),
            child: ListView(
              shrinkWrap: true,
              children: [
                TextListTile(
                  value: object.name,
                  onChanged: (final value) {
                    object.name = value;
                    onChange();
                  },
                  header: 'Name',
                  autofocus: true,
                  labelText: 'Name',
                  title: 'Rename Object',
                ),
                SoundPathListTile(
                  soundPaths: widget.editorContext.ambianceSoundPaths,
                  getSound: widget.editorContext.getSound,
                  title: 'Ambiance',
                  onChange: (final value) {
                    object.ambiance = value;
                    onChange();
                  },
                  looping: true,
                  soundReference: object.ambiance,
                ),
                IntListTile(
                  value: object.ambianceMaxDistance,
                  onChanged: (final value) {
                    object.ambianceMaxDistance = value;
                    onChange();
                  },
                  title: 'Ambiance max distance',
                  labelText: 'Distance',
                  min: 1,
                ),
              ],
            ),
          ),
          TabbedScaffoldTab(
            title: 'Events',
            icon: const Icon(Icons.keyboard),
            child: EventCommandsPage(
              editorContext: widget.editorContext,
              eventTypes: const [
                AngstromEventType.onActivate,
                AngstromEventType.onApproach,
                AngstromEventType.onLeave,
              ],
              commands: object.eventCommands,
              onChange: onChange,
            ),
          ),
        ],
      ),
    );
  }

  /// Call `onChange` and [setState].
  void onChange() {
    widget.editorContext.save();
    widget.onChange(widget.object);
    setState(() {});
  }
}
