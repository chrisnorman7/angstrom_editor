// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'editor_room_object.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EditorRoomObject _$EditorRoomObjectFromJson(Map<String, dynamic> json) =>
    EditorRoomObject(
      id: json['id'] as String,
      name: json['name'] as String,
      events: (json['events'] as List<dynamic>)
          .map((e) => $enumDecode(_$AngstromEventTypeEnumMap, e))
          .toList(),
      eventComments: (json['eventComments'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry($enumDecode(_$AngstromEventTypeEnumMap, k), e as String),
      ),
      x: (json['x'] as num?)?.toInt() ?? 0,
      y: (json['y'] as num?)?.toInt() ?? 0,
      ambiance: json['ambiance'] == null
          ? null
          : SoundReference.fromJson(json['ambiance'] as Map<String, dynamic>),
      ambianceMaxDistance: (json['ambianceMaxDistance'] as num?)?.toInt() ?? 20,
      door: json['door'] == null
          ? null
          : EditorDoor.fromJson(json['door'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$EditorRoomObjectToJson(
  EditorRoomObject instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'x': instance.x,
  'y': instance.y,
  'ambiance': instance.ambiance,
  'ambianceMaxDistance': instance.ambianceMaxDistance,
  'events': instance.events.map((e) => _$AngstromEventTypeEnumMap[e]!).toList(),
  'eventComments': instance.eventComments.map(
    (k, e) => MapEntry(_$AngstromEventTypeEnumMap[k]!, e),
  ),
  'door': instance.door,
};

const _$AngstromEventTypeEnumMap = {
  AngstromEventType.onEnter: 'onEnter',
  AngstromEventType.onMove: 'onMove',
  AngstromEventType.onExit: 'onExit',
  AngstromEventType.onApproach: 'onApproach',
  AngstromEventType.onActivate: 'onActivate',
  AngstromEventType.onLeave: 'onLeave',
};
