import 'dart:async';

import 'package:angstrom/angstrom.dart';
import 'package:angstrom_editor/angstrom_editor.dart';

/// An engine for testing [rooms].
class RoomTestingAngstromEngine extends AngstromEngine {
  /// Create an instance.
  RoomTestingAngstromEngine({
    required this.startRoom,
    required this.rooms,
    super.musicFadeIn,
    super.musicFadeOut,
  }) : super(
         playerCharacter: PlayerCharacter(
           id: 'whatever',
           name: '${startRoom.editorRoom.name} test',
           locationId: startRoom.id,
           x: startRoom.editorRoom.surfaces.first.points.first.x,
           y: startRoom.editorRoom.surfaces.first.points.first.y,
           statsMap: {},
         ),
       );

  /// The ID of the starting room.
  final LoadedRoom startRoom;

  /// The rooms which have been created.
  final List<LoadedRoom> rooms;

  /// Get the current room.
  LoadedRoom get loadedRoom => rooms.firstWhere((final r) => r.id == room.id);

  /// Build a room.
  @override
  FutureOr<LoadedRoom> buildRoom(final String id) {
    final room = rooms.firstWhere(
      (final room) => room.id == id,
      orElse: () =>
          throw UnimplementedError('There is no room with the id $id.'),
    );
    final editorRoom = room.editorRoom;
    return LoadedRoom(
      path: room.path,
      editorRoom: editorRoom,
      events: LoadedRoomEvents(
        surfaceEvents: {
          for (final surface in editorRoom.surfaces)
            surface.id: EditorRoomSurfaceEvents(
              onEnter: (final engine) {
                const eventType = AngstromEventType.onEnter;
                return runCommand(
                  eventType: eventType,
                  command: surface.eventCommands[eventType],
                )(engine);
              },
              onExit: (final engine) {
                const eventType = AngstromEventType.onExit;
                return runCommand(
                  eventType: eventType,
                  command: surface.eventCommands[eventType],
                )(engine);
              },
              onMove: (final engine) {
                const eventType = AngstromEventType.onMove;
                return runCommand(
                  eventType: eventType,
                  command: surface.eventCommands[eventType],
                )(engine);
              },
            ),
        },
        objectEvents: {
          for (final object in editorRoom.objects)
            object.id: EditorRoomObjectEvents(
              onActivate: (final engine) {
                const eventType = AngstromEventType.onActivate;
                return runCommand(
                  eventType: eventType,
                  command: object.eventCommands[eventType],
                )(engine);
              },
              onApproach: (final engine) {
                const eventType = AngstromEventType.onApproach;
                return runCommand(
                  eventType: eventType,
                  command: object.eventCommands[eventType],
                )(engine);
              },
              onLeave: (final engine) {
                const eventType = AngstromEventType.onLeave;
                return runCommand(
                  eventType: eventType,
                  command: object.eventCommands[eventType],
                )(engine);
              },
            ),
        },
        onEnter: (final engine) {
          const eventType = AngstromEventType.onEnter;
          return runCommand(
            eventType: eventType,
            command: editorRoom.eventCommands[eventType],
          )(engine);
        },
        onLeave: (final engine) {
          const eventType = AngstromEventType.onLeave;
          return runCommand(
            eventType: eventType,
            command: editorRoom.eventCommands[eventType],
          )(engine);
        },
      ),
    );
  }

  /// Run the given [command] as the given [eventType].
  AngstromCallback runCommand({
    required final AngstromEventType eventType,
    required final EditorEventCommand? command,
  }) => (final engine) {
    final text = command?.spokenText;
    if (text != null) {
      engine.speak(text);
    }
    final soundReference = command?.interfaceSound;
    if (soundReference != null) {
      engine.playInterfaceSound(soundReference);
    }
    final door = command?.door;
    if (door != null) {
      Door(
        coordinates: door.coordinates,
        destinationId: door.targetRoomId,
        stopPlayer: door.stopPlayer,
        useSound: door.useSound,
      ).onActivate(engine);
    }
  };
}
