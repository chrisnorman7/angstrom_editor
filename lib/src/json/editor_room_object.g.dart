// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'editor_room_object.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EditorRoomObject _$EditorRoomObjectFromJson(Map<String, dynamic> json) =>
    EditorRoomObject(
      id: json['id'] as String,
      name: json['name'] as String,
      eventCommands: (json['eventCommands'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
          $enumDecode(_$AngstromEventTypeEnumMap, k),
          EditorEventCommand.fromJson(e as Map<String, dynamic>),
        ),
      ),
      x: (json['x'] as num?)?.toInt() ?? 0,
      y: (json['y'] as num?)?.toInt() ?? 0,
      ambiance: json['ambiance'] == null
          ? null
          : SoundReference.fromJson(json['ambiance'] as Map<String, dynamic>),
      ambianceMaxDistance: (json['ambianceMaxDistance'] as num?)?.toInt() ?? 20,
    );

Map<String, dynamic> _$EditorRoomObjectToJson(EditorRoomObject instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'x': instance.x,
      'y': instance.y,
      'ambiance': instance.ambiance,
      'ambianceMaxDistance': instance.ambianceMaxDistance,
      'eventCommands': instance.eventCommands.map(
        (k, e) => MapEntry(_$AngstromEventTypeEnumMap[k]!, e),
      ),
    };

const _$AngstromEventTypeEnumMap = {
  AngstromEventType.onEnter: 'onEnter',
  AngstromEventType.onMove: 'onMove',
  AngstromEventType.onExit: 'onExit',
  AngstromEventType.onApproach: 'onApproach',
  AngstromEventType.onActivate: 'onActivate',
  AngstromEventType.onLeave: 'onLeave',
};
