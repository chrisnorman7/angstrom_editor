import 'package:angstrom/angstrom.dart';
import 'package:angstrom_editor/angstrom_editor.dart';
import 'package:json_annotation/json_annotation.dart';

part 'editor_room_surface.g.dart';

/// A room surface in the editor.
@JsonSerializable()
class EditorRoomSurface {
  /// Create an instance.
  EditorRoomSurface({
    required this.id,
    required this.name,
    required this.points,
    required this.contactSounds,
    required this.events,
    required this.eventComments,
    this.contactSoundsVolume = 0.7,
    this.isWall = false,
    this.moveInterval = const Duration(milliseconds: 500),
    this.ambiance,
  });

  /// Create an instance from a JSON object.
  factory EditorRoomSurface.fromJson(final Map<String, dynamic> json) =>
      _$EditorRoomSurfaceFromJson(json);

  /// The ID of this surface.
  final String id;

  /// The name of this surface.
  String name;

  /// The points that this surface covers.
  final List<ObjectCoordinates> points;

  /// The list of footstep sounds for this surface.
  final List<String> contactSounds;

  /// The list of events which should be programmed on this surface.
  final List<AngstromEventType> events;

  /// The doc comments to be generated for [events].
  final Map<AngstromEventType, String> eventComments;

  /// The volume to play [contactSounds] at.
  double contactSoundsVolume;

  /// Whether this surface is a wall.
  bool isWall;

  /// The move interval.
  Duration moveInterval;

  /// The ambiance to play while the player is traversing this surface.
  SoundReference? ambiance;

  /// Convert an instance to JSON.
  Map<String, dynamic> toJson() => _$EditorRoomSurfaceToJson(this);
}
