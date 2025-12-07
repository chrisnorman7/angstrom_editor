import 'package:angstrom/angstrom.dart';
import 'package:angstrom_editor/angstrom_editor.dart';

/// A class which provides various events which can be tacked onto [LoadedRoom]
/// instances.
class LoadedRoomEvents {
  /// Create an instance.
  const LoadedRoomEvents({
    required this.surfaceEvents,
    required this.objectEvents,
    this.onEnter,
    this.onLeave,
  });

  /// The map of [EditorRoomSurface] IDs to events.
  final Map<String, EditorRoomSurfaceEvents> surfaceEvents;

  /// The map of [EditorRoomObject] IDs to events.
  final Map<String, EditorRoomObjectEvents> objectEvents;

  /// The function to call when the player enters the room.
  final AngstromCallback? onEnter;

  /// The function to call when the player leaves the room.
  final AngstromCallback? onLeave;
}
