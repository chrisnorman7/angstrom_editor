// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'editor_room_surface.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EditorRoomSurface _$EditorRoomSurfaceFromJson(Map<String, dynamic> json) =>
    EditorRoomSurface(
      id: json['id'] as String,
      name: json['name'] as String,
      points: (json['points'] as List<dynamic>)
          .map((e) => ObjectCoordinates.fromJson(e as Map<String, dynamic>))
          .toList(),
      contactSounds: (json['contactSounds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      events: (json['events'] as List<dynamic>)
          .map((e) => $enumDecode(_$AngstromEventTypesEnumMap, e))
          .toList(),
      contactSoundsVolume:
          (json['contactSoundsVolume'] as num?)?.toDouble() ?? 0.7,
      isWall: json['isWall'] as bool? ?? false,
      moveInterval: json['moveInterval'] == null
          ? const Duration(milliseconds: 500)
          : Duration(microseconds: (json['moveInterval'] as num).toInt()),
      ambiance: json['ambiance'] == null
          ? null
          : SoundReference.fromJson(json['ambiance'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$EditorRoomSurfaceToJson(EditorRoomSurface instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'points': instance.points,
      'contactSounds': instance.contactSounds,
      'events': instance.events
          .map((e) => _$AngstromEventTypesEnumMap[e]!)
          .toList(),
      'contactSoundsVolume': instance.contactSoundsVolume,
      'isWall': instance.isWall,
      'moveInterval': instance.moveInterval.inMicroseconds,
      'ambiance': instance.ambiance,
    };

const _$AngstromEventTypesEnumMap = {
  AngstromEventTypes.onEnter: 'onEnter',
  AngstromEventTypes.onMove: 'onMove',
  AngstromEventTypes.onExit: 'onExit',
  AngstromEventTypes.onApproach: 'onApproach',
  AngstromEventTypes.onActivate: 'onActivate',
  AngstromEventTypes.onLeave: 'onLeave',
};
