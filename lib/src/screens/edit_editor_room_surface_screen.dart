import 'package:angstrom_editor/angstrom_editor.dart';
import 'package:backstreets_widgets/screens.dart';
import 'package:backstreets_widgets/shortcuts.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A screen for editing a [surface].
class EditEditorRoomSurfaceScreen extends StatefulWidget {
  /// Create an instance.
  const EditEditorRoomSurfaceScreen({
    required this.editorContext,
    required this.surface,
    required this.onChange,
    super.key,
  });

  /// The editor context to use.
  final EditorContext editorContext;

  /// The surface to edit.
  final EditorRoomSurface surface;

  /// The function to call when [surface] changes.
  final ValueChanged<EditorRoomSurface> onChange;

  /// Create state for this widget.
  @override
  EditEditorRoomSurfaceScreenState createState() =>
      EditEditorRoomSurfaceScreenState();
}

/// State for [EditEditorRoomSurfaceScreen].
class EditEditorRoomSurfaceScreenState
    extends State<EditEditorRoomSurfaceScreen> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final surface = widget.surface;
    final contactSounds = surface.contactSounds;
    final editorContext = widget.editorContext;
    final index = editorContext.footsteps.indexWhere(
      (final sounds) => listEquals(contactSounds, sounds.soundPaths),
    );
    final currentFootstepSounds = editorContext.footsteps[index];
    final previousFootstepSounds =
        editorContext.footsteps[(index - 1) % editorContext.footsteps.length];
    final nextFootstepSounds =
        editorContext.footsteps[(index + 1) % editorContext.footsteps.length];
    const contactSoundsTitle = Text('Contact sounds');
    final contactSoundsSubtitle = Text(currentFootstepSounds.name);
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
                  value: surface.name,
                  onChanged: (final value) {
                    surface.name = value;
                    onChange();
                  },
                  header: 'Name',
                  autofocus: true,
                  labelText: 'Name',
                  title: 'Rename Surface',
                ),
                FootstepsPlaySoundSemantics(
                  editorContext: editorContext,
                  interval: surface.moveInterval,
                  footstepSounds: contactSounds,
                  volume: surface.contactSoundsVolume,
                  child: nextFootstepSounds.name == currentFootstepSounds.name
                      ? ListTile(
                          title: contactSoundsTitle,
                          subtitle: contactSoundsSubtitle,
                          onTap: () {},
                        )
                      : PerformableActionsListTile(
                          actions: [
                            PerformableAction(
                              name: previousFootstepSounds.name,
                              activator: moveUpShortcut,
                              invoke: () {
                                surface.contactSounds.clear();
                                surface.contactSounds.addAll(
                                  previousFootstepSounds.soundPaths,
                                );
                                onChange();
                              },
                            ),
                            PerformableAction(
                              name: nextFootstepSounds.name,
                              activator: moveDownShortcut,
                              invoke: () {
                                surface.contactSounds.clear();
                                surface.contactSounds.addAll(
                                  nextFootstepSounds.soundPaths,
                                );
                                onChange();
                              },
                            ),
                          ],
                          title: contactSoundsTitle,
                          subtitle: contactSoundsSubtitle,
                          onTap: () {},
                        ),
                ),
                DoubleListTile(
                  value: surface.contactSoundsVolume,
                  onChanged: (final value) {
                    surface.contactSoundsVolume = value;
                    onChange();
                  },
                  title: 'Contact sounds volume',
                  max: 5,
                  min: 0,
                  modifier: 0.1,
                ),
                CheckboxListTile(
                  value: surface.isWall,
                  onChanged: (final value) {
                    surface.isWall = !surface.isWall;
                    onChange();
                  },
                  title: const Text('Wall'),
                ),
                SoundPathListTile(
                  onChange: (final value) {
                    surface.ambiance = value;
                    onChange();
                  },
                  getSound: editorContext.getSound,
                  soundPaths: editorContext.ambianceSoundPaths,
                  title: 'Ambiance',
                  looping: true,
                  soundReference: surface.ambiance,
                ),
                CustomDurationListTile(
                  duration: surface.moveInterval,
                  onChange: (final value) {
                    surface.moveInterval = value;
                    onChange();
                  },
                  title: 'Move interval',
                ),
              ],
            ),
          ),
          TabbedScaffoldTab(
            title: 'Events',
            icon: const Icon(Icons.keyboard),
            child: EventCommandsPage(
              editorContext: editorContext,
              eventTypes: const [
                AngstromEventType.onEnter,
                AngstromEventType.onExit,
                AngstromEventType.onMove,
              ],
              commands: surface.eventCommands,
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
    widget.onChange(widget.surface);
    setState(() {});
  }
}
