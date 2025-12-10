import 'package:angstrom/angstrom.dart';
import 'package:angstrom_editor/angstrom_editor.dart';
import 'package:backstreets_widgets/extensions.dart';
import 'package:backstreets_widgets/screens.dart';
import 'package:backstreets_widgets/shortcuts.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:code_builder/code_builder.dart';
import 'package:flutter/material.dart';

/// A [ListTile] for editing a room [object].
class RoomObjectListTile extends StatelessWidget {
  /// Create an instance.
  const RoomObjectListTile({
    required this.editorContext,
    required this.object,
    required this.onChange,
    this.autofocus = false,
    super.key,
  });

  /// The editor context to use.
  final EditorContext editorContext;

  /// The room object to edit.
  final EditorRoomObject object;

  /// The function to call when [object] changes.
  final VoidCallback onChange;

  /// Whether the [ListTile] should be autofocused.
  final bool autofocus;

  /// Build the widget.
  @override
  Widget build(final BuildContext context) {
    final ambiance = object.ambiance;
    final buffer = StringBuffer('${object.x}, ${object.y}');
    for (final surface in editorContext.room.editorRoom.surfaces) {
      if (surface.points
          .where((final p) => p.coordinates == object.coordinates)
          .isNotEmpty) {
        buffer.write(' (${surface.name})');
      }
    }
    final door = object.door;
    return PerformableActionsListTile(
      actions: [
        PerformableAction(
          name: 'Rename',
          activator: renameShortcut,
          invoke: () => context.pushWidgetBuilder(
            (_) => GetText(
              onDone: (final value) {
                context.pop();
                object.name = value;
                onChange();
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
              (_) => SelectSound(
                soundPaths: editorContext.ambianceSoundPaths,
                getSound: editorContext.getSound,
                setSound: (final value) {
                  object.ambiance = value.asSoundReference();
                  onChange();
                },
                looping: true,
              ),
            ),
          )
        else ...[
          PerformableAction(
            name: 'Edit ambiance (${ambiance.path})',
            invoke: () => context.pushWidgetBuilder(
              (_) => SelectSound(
                soundPaths: editorContext.ambianceSoundPaths,
                getSound: editorContext.getSound,
                setSound: (final value) {
                  object.ambiance = value.asSoundReference(
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
                  object.ambiance = ambiance.path.asSoundReference(
                    volume: value,
                  );
                  onChange();
                },
              ),
            ),
          ),
        ],
        PerformableAction(
          name: 'Move north',
          activator: moveUpShortcut,
          invoke: () {
            object.y += 1;
            onChange();
          },
        ),
        PerformableAction(
          name: 'Move east',
          activator: moveRightShortcut,
          invoke: () {
            object.x += 1;
            onChange();
          },
        ),
        PerformableAction(
          name: 'Move south',
          activator: moveDownShortcut,
          invoke: () {
            object.y -= 1;
            onChange();
          },
        ),
        PerformableAction(
          name: 'Move west',
          activator: moveLeftShortcut,
          invoke: () {
            object.x -= 1;
            onChange();
          },
        ),
        for (final event in [
          AngstromEventType.onApproach,
          if (door == null) AngstromEventType.onActivate,
          AngstromEventType.onLeave,
        ]) ...[
          PerformableAction(
            name: event.name,
            checked: object.events.contains(event),
            invoke: () {
              if (object.events.contains(event)) {
                object.events.remove(event);
              } else {
                object.events.add(event);
              }
              onChange();
            },
          ),
          if (object.events.contains(event))
            PerformableAction(
              name: 'Comment for ${event.name}',
              invoke: () => context.pushWidgetBuilder(
                (_) => EditCommentScreen(
                  onChange: (final value) {
                    if (value == null) {
                      if (object.eventComments.containsKey(event)) {
                        object.eventComments.remove(event);
                      }
                    } else {
                      object.eventComments[event] = value;
                    }
                    onChange();
                  },
                ),
              ),
            ),
        ],
        if (door == null)
          PerformableAction(
            name: 'Make door',
            activator: doorShortcut,
            invoke: () => context.pushWidgetBuilder(
              (_) => SelectDoorTargetScreen(
                roomsDirectory: editorContext.file.parent,
                onChange: (final value) {
                  object.door = EditorDoor(
                    targetObjectId: value.object.id,
                    x: value.object.x,
                    y: value.object.y,
                    targetRoomId: value.room.id,
                  );
                  onChange();
                },
                getSound: editorContext.getSound,
              ),
            ),
          )
        else ...[
          PerformableAction(
            name: 'Edit Door',
            activator: doorShortcut,
            invoke: () => context.pushWidgetBuilder(
              (_) => EditDoorScreen(editorContext: editorContext, door: door),
            ),
          ),
          PerformableAction(
            name: 'Remove door',
            invoke: () {
              object.door = null;
              onChange();
            },
          ),
        ],
        PerformableAction(
          name: 'Copy door code',
          activator: copyExtraShortcut,
          invoke: () {
            final buffer = StringBuffer()
              ..writeln('Door(')
              ..writeln('  coordinates: const Point(${object.x}, ${object.y}),')
              ..writeln(
                '  destinationId: ${literalString(editorContext.room.id)},',
              )
              ..writeln('  useSound: useSound // TODO: Change me,')
              ..writeln(').onActivate(engine);');
            buffer.toString().copyToClipboard();
          },
        ),
        PerformableAction(
          name: 'Delete',
          activator: deleteShortcut,
          invoke: () {
            for (final room in editorContext.file.parent.rooms) {
              for (final roomObject in room.editorRoom.objects) {
                if (roomObject.door?.targetObjectId == object.id) {
                  context.showMessage(
                    message:
                        // ignore: lines_longer_than_80_chars
                        'You cannot delete ${object.name} because it is used as the target for the ${roomObject.name} door.',
                  );
                  return;
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
                onChange();
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
    );
  }
}
