import 'package:angstrom/angstrom.dart';
import 'package:angstrom_editor/angstrom_editor.dart';
import 'package:json_annotation/json_annotation.dart';

part 'editor_event_command.g.dart';

/// A command which will run when an event fires.
@JsonSerializable()
class EditorEventCommand {
  /// Create an instance.
  EditorEventCommand({
    required this.comment,
    this.spokenText,
    this.interfaceSound,
    this.hasHandler = false,
  });

  /// Create an instance from a JSON object.
  factory EditorEventCommand.fromJson(final Map<String, dynamic> json) =>
      _$EditorEventCommandFromJson(json);

  /// The comment for the generated function.
  String comment;

  /// Some text to speak.
  String? spokenText;

  /// The reference to an interface sound to play.
  SoundReference? interfaceSound;

  /// Whether a corresponding handler function should be generated.
  bool hasHandler;

  /// A door to send the player through.
  EditorDoor? door;

  /// Convert an instance to JSON.
  Map<String, dynamic> toJson() => _$EditorEventCommandToJson(this);
}
