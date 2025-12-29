import 'package:angstrom_editor/angstrom_editor.dart';

/// The base class for all [EngineCommand] callers.
sealed class EngineCommandCaller {
  /// Create an instance.
  const EngineCommandCaller({required this.eventType});

  /// The type of the event which called the command.
  final AngstromEventType eventType;
}

/// The caller was a [room].
class RoomEngineCommandCaller extends EngineCommandCaller {
  /// Create an instance.
  const RoomEngineCommandCaller({required super.eventType, required this.room});

  /// The room which called the command.
  final LoadedRoom room;
}

/// The caller was a [surface].
class SurfaceEngineCommandCaller extends EngineCommandCaller {
  /// Create an instance.
  const SurfaceEngineCommandCaller({
    required super.eventType,
    required this.surface,
  });

  /// The surface which called the command.
  final EditorRoomSurface surface;
}

/// The caller was an [object].
class ObjectEngineCommandCaller extends EngineCommandCaller {
  /// Create an instance.
  const ObjectEngineCommandCaller({
    required super.eventType,
    required this.object,
  });

  /// The object which called the command.
  final EditorRoomObject object;
}
