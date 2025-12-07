import 'package:angstrom_editor/angstrom_editor.dart';

/// The target for a door.
class DoorTarget {
  /// Create an instance.
  const DoorTarget({required this.room, required this.object});

  /// The target room.
  final LoadedRoom room;

  /// The object to use.
  final EditorRoomObject object;
}
