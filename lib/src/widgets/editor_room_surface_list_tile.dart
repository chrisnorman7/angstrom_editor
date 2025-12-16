import 'package:angstrom/angstrom.dart';
import 'package:angstrom_editor/angstrom_editor.dart';
import 'package:backstreets_widgets/extensions.dart';
import 'package:backstreets_widgets/screens.dart';
import 'package:backstreets_widgets/shortcuts.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_games/flutter_audio_games.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

/// A [ListTile] which shows a surface with the given [surfaceId].
class EditorRoomSurfaceListTile extends StatelessWidget {
  /// Create an instance.
  const EditorRoomSurfaceListTile({
    required this.editorContext,
    required this.surfaceId,
    required this.onChange,
    this.autofocus = false,
    super.key,
  });

  /// The editor context to use.
  final EditorContext editorContext;

  /// The ID of the surface to show.
  final String surfaceId;

  /// The function to call when the surface has changed.
  final VoidCallback onChange;

  /// Whether the [ListTile] should be autofocused.
  final bool autofocus;

  /// Build the widget.
  @override
  Widget build(final BuildContext context) {
    final room = editorContext.room;
    final surface = room.editorRoom.surfaces.firstWhere(
      (final s) => s.id == surfaceId,
    );
    final ambiance = surface.ambiance;
    return FootstepsPlaySoundSemantics(
      key: ValueKey(surface.contactSounds.join('|')),
      footstepSounds: surface.contactSounds,
      getSound: editorContext.getSound,
      interval: surface.moveInterval,
      volume: surface.contactSoundsVolume,
      child: MaybePlaySoundSemantics(
        sound: ambiance == null
            ? null
            : editorContext.getSound(
                soundReference: ambiance,
                destroy: false,
                loadMode: LoadMode.disk,
                looping: true,
              ),
        child: PerformableActionsListTile(
          actions: [
            PerformableAction(
              name: 'Rename',
              activator: renameShortcut,
              invoke: () => context.pushWidgetBuilder(
                (_) => GetText(
                  onDone: (final value) {
                    context.pop();
                    surface.name = value;
                    onChange();
                  },
                  labelText: 'Name',
                  text: surface.name,
                  title: 'Rename Surface',
                ),
              ),
            ),
            PerformableAction(
              name: 'Copy ID',
              activator: copyExtraShortcut,
              invoke: surface.id.copyToClipboard,
            ),
            ...editorContext.footsteps.map((final footsteps) {
              final checked = listEquals(
                surface.contactSounds,
                footsteps.soundPaths,
              );
              return PerformableAction(
                name: footsteps.name,
                checked: checked,
                invoke: () {
                  if (checked) {
                    return;
                  }
                  surface.contactSounds.clear();
                  surface.contactSounds.addAll(footsteps.soundPaths);
                  onChange();
                },
              );
            }),
            if (ambiance == null)
              PerformableAction(
                name: 'Add ambiance',
                invoke: () => context.pushWidgetBuilder(
                  (_) => SelectSoundScreen(
                    soundPaths: editorContext.ambianceSoundPaths,
                    getSound: editorContext.getSound,
                    setSound: (final value) {
                      surface.ambiance = value.asSoundReference(
                        volume: ambiance?.volume ?? 0.7,
                      );
                      onChange();
                    },
                    looping: true,
                    soundPath: ambiance?.path,
                    volume: ambiance?.volume ?? 0.7,
                  ),
                ),
              )
            else ...[
              PerformableAction(
                name: 'Edit ambiance',
                invoke: () => context.pushWidgetBuilder(
                  (_) => SelectSoundScreen(
                    soundPaths: editorContext.ambianceSoundPaths,
                    getSound: editorContext.getSound,
                    setSound: (final value) {
                      surface.ambiance = value.asSoundReference(
                        volume: ambiance.volume,
                      );
                      onChange();
                    },
                    looping: true,
                    soundPath: ambiance.path,
                    volume: ambiance.volume,
                  ),
                ),
              ),
              PerformableAction(
                name: 'Edit ambiance volume (${ambiance.volume})',
                invoke: () => context.pushWidgetBuilder(
                  (_) => EditVolumeScreen(
                    volume: ambiance.volume,
                    onChanged: (final value) {
                      surface.ambiance = ambiance.path.asSoundReference(
                        volume: value,
                      );
                      onChange();
                    },
                  ),
                ),
              ),
            ],
            PerformableAction(
              name: 'Wall',
              checked: surface.isWall,
              invoke: () {
                surface.isWall = !surface.isWall;
                onChange();
              },
            ),
            for (final event in [
              AngstromEventType.onEnter,
              AngstromEventType.onMove,
              AngstromEventType.onExit,
            ])
              ...() {
                final command = surface.eventCommands[event];
                if (command == null) {
                  return [PerformableAction(name: 'Add ${event.name}')];
                }
                return [
                  PerformableAction(name: 'Edit ${event.name}'),
                  PerformableAction(
                    name: 'Delete ${event.name}',
                    invoke: () {
                      surface.eventCommands.remove(event);
                      editorContext.save();
                      onChange();
                    },
                  ),
                ];
              }(),
            PerformableAction(
              name: 'delete',
              activator: deleteShortcut,
              invoke: () {
                if (room.editorRoom.surfaces.length == 1) {
                  context.showMessage(
                    message: 'You cannot delete the only surface.',
                  );
                  return;
                } else if (surface.points.isNotEmpty) {
                  context.showMessage(
                    message:
                        // ignore: lines_longer_than_80_chars
                        'You can only delete surfaces which are not assigned to any tiles.',
                  );
                  return;
                } else {
                  context.showConfirmMessage(
                    message: 'Are you sure you want to delete ${surface.name}?',
                    noLabel: 'Cancel',
                    title: confirmDelete,
                    yesCallback: () {
                      room.editorRoom.surfaces.removeWhere(
                        (final s) => s.id == surface.id,
                      );
                      editorContext.save();
                      onChange();
                    },
                  );
                }
              },
            ),
          ],
          autofocus: autofocus,
          title: Text(surface.name),
          subtitle: ambiance == null
              ? null
              : SoundReferenceText(soundReference: ambiance),
          onTap: () {},
        ),
      ),
    );
  }
}
