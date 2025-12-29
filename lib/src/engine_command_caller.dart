import 'package:angstrom_editor/angstrom_editor.dart';

/// The base class for all [EngineCommand] callers.
sealed class EngineCommandCaller {
  /// Create an instance.
  const EngineCommandCaller({required this.eventType});

  /// Create an instance from [roomId].
  static RoomEngineCommandCaller roomId({
    required final AngstromEventType eventType,
    required final String roomId,
  }) => RoomEngineCommandCaller(eventType: eventType, roomId: roomId);

  /// Create an instance from [surfaceId].
  static SurfaceEngineCommandCaller surfaceId({
    required final AngstromEventType eventType,
    required final String roomId,
    required final String surfaceId,
  }) => SurfaceEngineCommandCaller(
    eventType: eventType,
    roomId: roomId,
    surfaceId: surfaceId,
  );

  /// Create an instance from [objectId].
  static ObjectEngineCommandCaller objectId({
    required final AngstromEventType eventType,
    required final String roomId,
    required final String objectId,
  }) => ObjectEngineCommandCaller(
    eventType: eventType,
    roomId: roomId,
    objectId: objectId,
  );

  /// The type of the event which called the command.
  final AngstromEventType eventType;

  /// Describe this object.
  @override
  String toString() => '<$runtimeType eventType: ${eventType.name}>';
}

/// The caller was a [roomId].
class RoomEngineCommandCaller extends EngineCommandCaller {
  /// Create an instance.
  const RoomEngineCommandCaller({
    required super.eventType,
    required this.roomId,
  });

  /// The ID of the room which called the command.
  final String roomId;

  /// Describe this object.
  @override
  String toString() =>
      '<$runtimeType eventType: ${eventType.name}, roomId: $roomId>';
}

/// The caller was a [surfaceId].
class SurfaceEngineCommandCaller extends EngineCommandCaller {
  /// Create an instance.
  const SurfaceEngineCommandCaller({
    required super.eventType,
    required this.roomId,
    required this.surfaceId,
  });

  /// The ID of the room which contains the surface.
  final String roomId;

  /// The ID of the surface which called the command.
  final String surfaceId;

  /// Describe this object.
  @override
  String toString() =>
      // ignore: lines_longer_than_80_chars
      '<$runtimeType eventType: ${eventType.name}, roomId: $roomId, surfaceId: $surfaceId>';
}

/// The caller was an [objectId].
class ObjectEngineCommandCaller extends EngineCommandCaller {
  /// Create an instance.
  const ObjectEngineCommandCaller({
    required super.eventType,
    required this.roomId,
    required this.objectId,
  });

  /// The ID of the room which contains the object.
  final String roomId;

  /// The ID of the object which called the command.
  final String objectId;

  /// Describe this object.
  @override
  String toString() =>
      // ignore: lines_longer_than_80_chars
      '<$runtimeType eventType: ${eventType.name}, roomId: $roomId, objectId: $objectId>';
}
