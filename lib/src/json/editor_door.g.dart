// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'editor_door.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EditorDoor _$EditorDoorFromJson(Map<String, dynamic> json) => EditorDoor(
  targetObjectId: json['targetObjectId'] as String,
  x: (json['x'] as num).toInt(),
  y: (json['y'] as num).toInt(),
  targetRoomId: json['targetRoomId'] as String,
  useSound: json['useSound'] == null
      ? null
      : SoundReference.fromJson(json['useSound'] as Map<String, dynamic>),
  stopPlayer: json['stopPlayer'] as bool? ?? false,
);

Map<String, dynamic> _$EditorDoorToJson(EditorDoor instance) =>
    <String, dynamic>{
      'targetObjectId': instance.targetObjectId,
      'x': instance.x,
      'y': instance.y,
      'targetRoomId': instance.targetRoomId,
      'useSound': instance.useSound,
      'stopPlayer': instance.stopPlayer,
    };
