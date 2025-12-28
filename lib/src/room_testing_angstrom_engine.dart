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
           name: 'Unnamed',
           locationId: startRoom.id,
           x: startRoom.editorRoom.x,
           y: startRoom.editorRoom.y,
           statsMap: {},
         ),
       );

  /// The ID of the starting room.
  final LoadedRoom startRoom;

  /// The rooms which have been created.
  final List<LoadedRoom> rooms;
  @override
  FutureOr<Room> buildRoom(final String id) => rooms.firstWhere(
    (final room) => room.id == id,
    orElse: () => throw UnimplementedError('There is no room with the id $id.'),
  );
}
