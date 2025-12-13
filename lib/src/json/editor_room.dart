import 'dart:math';

import 'package:angstrom/angstrom.dart';
import 'package:angstrom_editor/angstrom_editor.dart';
import 'package:json_annotation/json_annotation.dart';

part 'editor_room.g.dart';

/// A room that the editor can modify.
@JsonSerializable()
class EditorRoom {
  /// Create an instance.
  EditorRoom({
    required this.surfaces,
    required this.objects,
    final EventsMap? eventCommands,
    this.name = 'Untitled Room',
    this.music,
    this.x = 0,
    this.y = 0,
    this.lastPageIndex = 0,
  }) : eventCommands = eventCommands ?? {};

  /// Create an instance from a JSON object.
  factory EditorRoom.fromJson(final Map<String, dynamic> json) =>
      _$EditorRoomFromJson(json);

  /// The surfaces for this room.
  final List<EditorRoomSurface> surfaces;

  /// The objects which are part of this room.
  final List<EditorRoomObject> objects;

  /// The events that this room supports.
  final EventsMap eventCommands;

  /// The name of this room.
  String name;

  /// The music for this room.
  SoundReference? music;

  /// The last visited x coordinate in this room.
  int x;

  /// The last visited y coordinate in this room.
  int y;

  /// The cursor coordinates in this room.
  @JsonKey(includeFromJson: false, includeToJson: false)
  Point<int> get coordinates => Point(x, y);

  /// Set [coordinates].
  set coordinates(final Point<int> value) {
    x = value.x;
    y = value.y;
  }

  /// The index of the last page which was accessed to edit this room.
  int lastPageIndex;

  /// Convert an instance to JSON.
  Map<String, dynamic> toJson() => _$EditorRoomToJson(this);
}
