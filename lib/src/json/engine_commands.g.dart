// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'engine_commands.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EngineCommand _$EngineCommandFromJson(Map<String, dynamic> json) =>
    EngineCommand(
      id: json['id'] as String,
      name: json['name'] as String,
      comment: json['comment'] as String,
    );

Map<String, dynamic> _$EngineCommandToJson(EngineCommand instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'comment': instance.comment,
    };

EngineCommands _$EngineCommandsFromJson(Map<String, dynamic> json) =>
    EngineCommands(
      engineCommands: (json['engineCommands'] as List<dynamic>)
          .map((e) => EngineCommand.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$EngineCommandsToJson(EngineCommands instance) =>
    <String, dynamic>{'engineCommands': instance.engineCommands};
