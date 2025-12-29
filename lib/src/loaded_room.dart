import 'package:angstrom/angstrom.dart';
import 'package:angstrom_editor/angstrom_editor.dart';
import 'package:path/path.dart' as p;
import 'package:recase/recase.dart';

/// A room which derives its property from [editorRoom].
class LoadedRoom extends Room {
  /// Create an instance.
  const LoadedRoom({
    required this.path,
    required this.editorRoom,
    required this.events,
  });

  /// The asset path for this room.
  final String path;

  /// The room from the editor.
  final EditorRoom editorRoom;

  /// The events for this room.
  final LoadedRoomEvents events;

  /// The ID of this room.
  @override
  String get id => path.replaceAll(r'\', '/');

  /// The music to play in this room.
  @override
  SoundReference? get music => editorRoom.music;

  /// Returns the surfaces for this room.
  @override
  List<RoomSurface> get surfaces => editorRoom.surfaces.map((final surface) {
    final surfaceEvents =
        events.surfaceEvents[surface.id] ?? const EditorRoomSurfaceEvents();
    return RoomSurface(
      points: surface.points.map((final point) => point.coordinates).toSet(),
      contactSounds: surface.contactSounds,
      ambiance: surface.ambiance,
      contactSoundsVolume: surface.contactSoundsVolume,
      isWall: surface.isWall,
      moveInterval: surface.moveInterval,
      onEnter: surfaceEvents.onEnter,
      onExit: surfaceEvents.onExit,
      onMove: surfaceEvents.onMove,
    );
  }).toList();

  /// The objects in this room.
  @override
  List<RoomObject> get objects => editorRoom.objects.map((final object) {
    final objectEvents =
        events.objectEvents[object.id] ?? const EditorRoomObjectEvents();
    return RoomObject(
      id: object.id,
      name: object.name,
      coordinates: object.coordinates,
      ambiance: object.ambiance,
      ambianceMaxDistance: object.ambianceMaxDistance,
      onApproach: objectEvents.onApproach,
      onActivate: objectEvents.onActivate,
      onLeave: objectEvents.onLeave,
    );
  }).toList();

  /// The player has entered the room.
  @override
  void onEnter(final AngstromEngine engine) {
    events.onEnter?.call(engine);
  }

  /// The player has left the room.
  @override
  void onLeave(final AngstromEngine engine) {
    events.onLeave?.call(engine);
  }

  /// A suitable class name for this room.
  String get className => p.basenameWithoutExtension(id).pascalCase;

  /// A suitable getter name for this room.
  String get getterName => className.camelCase;
}
