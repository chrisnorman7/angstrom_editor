import 'dart:math';

import 'package:angstrom/angstrom.dart';
import 'package:json_annotation/json_annotation.dart';

part 'editor_door.g.dart';

/// A door in the editor.
@JsonSerializable()
class EditorDoor {
  /// Create an instance.
  EditorDoor({
    required this.targetObjectId,
    required this.x,
    required this.y,
    required this.targetRoomId,
    this.useSound,
    this.stopPlayer = false,
  });

  /// Create an instance from a JSON object.
  factory EditorDoor.fromJson(final Map<String, dynamic> json) =>
      _$EditorDoorFromJson(json);

  /// The ID of the target object.
  String targetObjectId;

  /// The target x coordinate.
  int x;

  /// The target y coordinate.
  int y;

  /// The target coordinates.
  @JsonKey(includeFromJson: false, includeToJson: false)
  Point<int> get coordinates => Point(x, y);

  /// Set the [coordinates].
  set coordinates(final Point<int> value) {
    x = value.x;
    y = value.y;
  }

  /// The ID of the destination room.
  String targetRoomId;

  /// The sound to play when the door is used.
  SoundReference? useSound;

  /// Whether the player should stop when they use this door.
  bool stopPlayer;

  /// Convert an instance to JSON.
  Map<String, dynamic> toJson() => _$EditorDoorToJson(this);
}
