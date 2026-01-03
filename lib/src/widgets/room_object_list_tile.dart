import 'package:angstrom/angstrom.dart';
import 'package:angstrom_editor/angstrom_editor.dart';
import 'package:backstreets_widgets/extensions.dart';
import 'package:backstreets_widgets/screens.dart';
import 'package:backstreets_widgets/shortcuts.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:code_builder/code_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_games/flutter_audio_games.dart';

/// A [ListTile] for editing a room [object].
class RoomObjectListTile extends StatelessWidget {
  /// Create an instance.
  const RoomObjectListTile({
    required this.object,
    required this.onChange,
    this.autofocus = false,
    super.key,
  });

  /// The room object to edit.
  final EditorRoomObject object;

  /// The function to call when [object] changes.
  final ValueChanged<EditorRoomObject?> onChange;

  /// Whether the [ListTile] should be autofocused.
  final bool autofocus;

  /// Build the widget.
  @override
  Widget build(final BuildContext context) {
    final ambiance = object.ambiance;
    final buffer = StringBuffer('${object.x}, ${object.y}');
    final editorContext = context.editorContext;
    for (final surface in editorContext.room.editorRoom.surfaces) {
      if (surface.points
          .where((final p) => p.coordinates == object.coordinates)
          .isNotEmpty) {
        buffer.write(' (${surface.name})');
      }
    }
    final sound = ambiance == null
        ? null
        : editorContext.getSound(
            soundReference: ambiance,
            destroy: false,
            looping: true,
          );
    return MaybePlaySoundSemantics(
      sound: sound,
      child: PerformableActionsListTile(
        actions: [
          PerformableAction(
            name: 'Rename',
            activator: renameShortcut,
            invoke: () => context.pushWidgetBuilder(
              (_) => GetText(
                onDone: (final value) {
                  context.pop();
                  object.name = value;
                  onChange(object);
                },
                labelText: 'Name',
                text: object.name,
                title: 'Rename Object',
              ),
            ),
          ),
          if (ambiance == null)
            PerformableAction(
              name: 'Add ambiance',
              invoke: () => context.pushWidgetBuilder(
                (_) => SelectSoundScreen(
                  soundPaths: editorContext.ambianceSoundPaths,
                  getSound: editorContext.getSound,
                  setSound: (final value) {
                    object.ambiance = value.asSoundReference();
                    onChange(object);
                  },
                  looping: true,
                ),
              ),
            )
          else ...[
            PerformableAction(
              name: 'Edit ambiance (${ambiance.path})',
              invoke: () => context.pushWidgetBuilder(
                (_) => SelectSoundScreen(
                  soundPaths: editorContext.ambianceSoundPaths,
                  getSound: editorContext.getSound,
                  setSound: (final value) {
                    object.ambiance = value.asSoundReference(
                      volume: ambiance.volume,
                    );
                    onChange(object);
                  },
                  looping: true,
                  soundPath: ambiance.path,
                  volume: ambiance.volume,
                ),
              ),
            ),
            ...SoundReferenceVolumeActions(
              soundReference: ambiance,
              onChange: (final value) {
                object.ambiance = value;
                onChange(object);
              },
              volumeDownShortcut: null,
              volumeUpShortcut: null,
            ).getActions(context),
          ],
          PerformableAction(
            name: 'Move north',
            activator: moveUpShortcut,
            invoke: () {
              object.y += 1;
              onChange(object);
            },
          ),
          PerformableAction(
            name: 'Move east',
            activator: moveRightShortcut,
            invoke: () {
              object.x += 1;
              onChange(object);
            },
          ),
          PerformableAction(
            name: 'Move south',
            activator: moveDownShortcut,
            invoke: () {
              object.y -= 1;
              onChange(object);
            },
          ),
          PerformableAction(
            name: 'Move west',
            activator: moveLeftShortcut,
            invoke: () {
              object.x -= 1;
              onChange(object);
            },
          ),
          ...EventCommandsPerformableActions(
            editorContext: editorContext,
            events: [
              AngstromEventType.onApproach,
              AngstromEventType.onActivate,
              AngstromEventType.onLeave,
            ],
            map: object.eventCommands,
            save: () {
              editorContext.save();
              onChange(object);
            },
          ).getActions(context),
          PerformableAction(
            name: 'Copy door code',
            activator: doorShortcut,
            invoke: () {
              final buffer = StringBuffer()
                ..writeln('Door(')
                ..writeln(
                  '  coordinates: const Point(${object.x}, ${object.y}),',
                )
                ..writeln(
                  '  destinationId: ${literalString(editorContext.room.id)},',
                )
                ..writeln('  useSound: useSound // TODO: Change me,')
                ..writeln(').onActivate(engine);');
              buffer.toString().copyToClipboard();
            },
          ),
          PerformableAction(
            name: 'Copy ID',
            activator: copyExtraShortcut,
            invoke: object.id.copyToClipboard,
          ),
          PerformableAction(
            name: 'Delete',
            activator: deleteShortcut,
            invoke: () {
              for (final room in editorContext.file.parent.rooms) {
                final editorRoom = room.editorRoom;
                for (final surface in editorRoom.surfaces) {
                  for (final command in surface.eventCommands.values) {
                    final door = command.door;
                    if (door?.targetObjectId == object.id) {
                      context.showMessage(
                        message:
                            // ignore: lines_longer_than_80_chars
                            'You cannot delete ${object.name} because it is used as the target for the ${surface.name} door.',
                      );
                      return;
                    }
                  }
                }
                for (final roomObject in editorRoom.objects) {
                  for (final command in roomObject.eventCommands.values) {
                    final door = command.door;
                    if (door?.targetObjectId == object.id) {
                      context.showMessage(
                        message:
                            // ignore: lines_longer_than_80_chars
                            'You cannot delete ${object.name} because it is used as the target for the ${roomObject.name} door.',
                      );
                      return;
                    }
                  }
                }
              }
              context.showConfirmMessage(
                message: 'Really delete ${object.name}?',
                noLabel: 'Cancel',
                yesCallback: () {
                  editorContext.room.editorRoom.objects.removeWhere(
                    (final o) => o.id == object.id,
                  );
                  onChange(null);
                },
                title: confirmDelete,
                yesLabel: 'Delete',
              );
            },
          ),
        ],
        title: Text(object.name),
        subtitle: Text(buffer.toString()),
        autofocus: autofocus,
        onTap: () {},
      ),
    );
  }
}
