// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'editor_room.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EditorRoom _$EditorRoomFromJson(Map<String, dynamic> json) => EditorRoom(
  surfaces: (json['surfaces'] as List<dynamic>)
      .map((e) => EditorRoomSurface.fromJson(e as Map<String, dynamic>))
      .toList(),
  objects: (json['objects'] as List<dynamic>)
      .map((e) => EditorRoomObject.fromJson(e as Map<String, dynamic>))
      .toList(),
  eventCommands: (json['eventCommands'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(
      $enumDecode(_$AngstromEventTypeEnumMap, k),
      EditorEventCommand.fromJson(e as Map<String, dynamic>),
    ),
  ),
  name: json['name'] as String? ?? 'Untitled Room',
  music: json['music'] == null
      ? null
      : SoundReference.fromJson(json['music'] as Map<String, dynamic>),
  x: (json['x'] as num?)?.toInt() ?? 0,
  y: (json['y'] as num?)?.toInt() ?? 0,
  lastPageIndex: (json['lastPageIndex'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$EditorRoomToJson(EditorRoom instance) =>
    <String, dynamic>{
      'surfaces': instance.surfaces,
      'objects': instance.objects,
      'eventCommands': instance.eventCommands.map(
        (k, e) => MapEntry(_$AngstromEventTypeEnumMap[k]!, e),
      ),
      'name': instance.name,
      'music': instance.music,
      'x': instance.x,
      'y': instance.y,
      'lastPageIndex': instance.lastPageIndex,
    };

const _$AngstromEventTypeEnumMap = {
  AngstromEventType.onEnter: 'onEnter',
  AngstromEventType.onMove: 'onMove',
  AngstromEventType.onExit: 'onExit',
  AngstromEventType.onApproach: 'onApproach',
  AngstromEventType.onActivate: 'onActivate',
  AngstromEventType.onLeave: 'onLeave',
};
