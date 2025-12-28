import 'package:json_annotation/json_annotation.dart';
import 'package:recase/recase.dart';

part 'engine_commands.g.dart';

/// A custom command within the engine.
@JsonSerializable()
class EngineCommand {
  /// Create an instance.
  EngineCommand({required this.id, required this.name, required this.comment});

  /// Create an instance from a JSON object.
  factory EngineCommand.fromJson(final Map<String, dynamic> json) =>
      _$EngineCommandFromJson(json);

  /// The ID of this command.
  final String id;

  /// The name of this command.
  ///
  /// The [name] must be a valid Dart identifier.
  String name;

  /// The comment for this command.
  String comment;

  /// Convert an instance to JSON.
  Map<String, dynamic> toJson() => _$EngineCommandToJson(this);

  /// The getter name for this command.
  String get getterName => name.camelCase;
}

/// A class which holds a list of [engineCommands].
@JsonSerializable()
class EngineCommands {
  /// Create an instance.
  const EngineCommands({required this.engineCommands});

  /// Create an instance from a JSON object.
  factory EngineCommands.fromJson(final Map<String, dynamic> json) =>
      _$EngineCommandsFromJson(json);

  /// The commands which have been created.
  final List<EngineCommand> engineCommands;

  /// Convert an instance to JSON.
  Map<String, dynamic> toJson() => _$EngineCommandsToJson(this);
}
