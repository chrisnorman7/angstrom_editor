// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'editor_room_object.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EditorRoomObject _$EditorRoomObjectFromJson(Map<String, dynamic> json) =>
    EditorRoomObject(
      id: json['id'] as String,
      events: (json['events'] as List<dynamic>)
          .map((e) => $enumDecode(_$AngstromEventTypesEnumMap, e))
          .toList(),
      name: json['name'] as String,
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

Map<String, dynamic> _$EditorRoomObjectToJson(EditorRoomObject instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'x': instance.x,
      'y': instance.y,
      'ambiance': instance.ambiance,
      'ambianceMaxDistance': instance.ambianceMaxDistance,
      'events': instance.events
          .map((e) => _$AngstromEventTypesEnumMap[e]!)
          .toList(),
      'door': instance.door,
    };

const _$AngstromEventTypesEnumMap = {
  AngstromEventTypes.onEnter: 'onEnter',
  AngstromEventTypes.onMove: 'onMove',
  AngstromEventTypes.onExit: 'onExit',
  AngstromEventTypes.onApproach: 'onApproach',
  AngstromEventTypes.onActivate: 'onActivate',
  AngstromEventTypes.onLeave: 'onLeave',
};
