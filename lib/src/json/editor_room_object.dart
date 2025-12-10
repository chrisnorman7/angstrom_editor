import 'dart:math';

import 'package:angstrom/angstrom.dart';
import 'package:angstrom_editor/angstrom_editor.dart';
import 'package:json_annotation/json_annotation.dart';

part 'editor_room_object.g.dart';

/// A class which holds metadata about a [RoomObject].
@JsonSerializable()
class EditorRoomObject {
  /// Create an instance.
  EditorRoomObject({
    required this.id,
    required this.events,
    required this.name,
    this.x = 0,
    this.y = 0,
    this.ambiance,
    this.ambianceMaxDistance = 20,
    this.door,
  });

  /// Create an instance from a JSON object.
  factory EditorRoomObject.fromJson(final Map<String, dynamic> json) =>
      _$EditorRoomObjectFromJson(json);

  /// The ID of this object.
  final String id;

  /// The name of this object.
  String name;

  /// The x coordinate of this object.
  int x;

  /// The y coordinate of this object.
  int y;

  /// The coordinates of this object.
  @JsonKey(includeFromJson: false, includeToJson: false)
  Point<int> get coordinates => Point(x, y);

  /// Set [coordinates].
  set coordinates(final Point<int> value) {
    x = value.x;
    y = value.y;
  }

  /// The ambiance for this object.
  SoundReference? ambiance;

  /// The distance at which the [ambiance] should be heard.
  int ambianceMaxDistance;

  /// The events which this object expects.
  final List<AngstromEventType> events;

  /// A door which this object represents.
  EditorDoor? door;

  /// Convert an instance to JSON.
  Map<String, dynamic> toJson() => _$EditorRoomObjectToJson(this);
}
