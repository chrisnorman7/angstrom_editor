// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'editor_event_command.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EditorEventCommand _$EditorEventCommandFromJson(Map<String, dynamic> json) =>
    EditorEventCommand(
      comment: json['comment'] as String,
      spokenText: json['spokenText'] as String?,
      interfaceSound: json['interfaceSound'] == null
          ? null
          : SoundReference.fromJson(
              json['interfaceSound'] as Map<String, dynamic>,
            ),
      hasHandler: json['hasHandler'] as bool? ?? false,
      door: json['door'] == null
          ? null
          : EditorDoor.fromJson(json['door'] as Map<String, dynamic>),
      engineCommandId: json['engineCommandId'] as String?,
    );

Map<String, dynamic> _$EditorEventCommandToJson(EditorEventCommand instance) =>
    <String, dynamic>{
      'comment': instance.comment,
      'spokenText': instance.spokenText,
      'interfaceSound': instance.interfaceSound,
      'hasHandler': instance.hasHandler,
      'door': instance.door,
      'engineCommandId': instance.engineCommandId,
    };
