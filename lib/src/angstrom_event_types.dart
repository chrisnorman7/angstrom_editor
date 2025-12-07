import 'package:angstrom/angstrom.dart' show Room, RoomObject, RoomSurface;

/// An enum to hold the types of events on [Room]s, [RoomSurface]s, and
/// [RoomObject]s.
enum AngstromEventTypes {
  /// [RoomSurface] or [Room] onEnter.
  onEnter,

  /// [RoomSurface] onMove.
  onMove,

  /// [RoomSurface] onExit.
  onExit,

  /// [RoomObject] onApproach.
  onApproach,

  /// [RoomObject] onActivate.
  onActivate,

  /// [Room] and [RoomObject] onLeave.
  onLeave,
}
