import 'package:angstrom/angstrom.dart';
import 'package:angstrom_editor/angstrom_editor.dart';

/// Events for a room surface.
class EditorRoomSurfaceEvents {
  /// Create an instance.
  const EditorRoomSurfaceEvents({this.onEnter, this.onMove, this.onExit});

  /// `RoomSurface.onEnter`.
  final AngstromCallback? onEnter;

  /// `RoomSurface.onMove`.
  final AngstromCallback? onMove;

  /// `RoomSurface.onExit`.
  final AngstromCallback? onExit;

  /// Get the appropriate callback for [eventType] or `null`.
  ///
  /// This method will only work with events which are associated with
  /// [EditorRoomSurface]s. Attempting to get a callback for an event type for
  /// another type of object (AngstromEventType.onLeave] for example) will
  /// result in [UnimplementedError] being thrown.
  AngstromCallback? getEventCallback(final AngstromEventType eventType) {
    switch (eventType) {
      case AngstromEventType.onEnter:
        return onEnter;
      case AngstromEventType.onMove:
        return onMove;
      case AngstromEventType.onExit:
        return onExit;
      default:
        throw UnimplementedError(
          '$eventType is not implemented by $runtimeType.',
        );
    }
  }

  /// Pretty print this object.
  @override
  String toString() =>
      '$runtimeType(onEnter: $onEnter, onMove: $onMove, onExit: $onExit)';
}
