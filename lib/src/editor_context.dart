import 'dart:io';

import 'package:angstrom/angstrom.dart';
import 'package:angstrom_editor/angstrom_editor.dart';
import 'package:flutter_audio_games/flutter_audio_games.dart' show Sound;

/// Holds context for an [room].
class EditorContext {
  /// Create an instance.
  const EditorContext({
    required this.file,
    required this.room,
    required this.getSound,
    required this.newId,
    required this.footsteps,
    required this.musicSoundPaths,
    required this.ambianceSoundPaths,
    required this.doorSounds,
    required this.wallAttenuation,
    required this.wallFactor,
    required this.onExamineObject,
    required this.getExamineObjectDistance,
    required this.getExamineObjectOrdering,
    required this.onNoRoomObjects,
    required this.engineCommands,
  });

  /// The file where [room] is saved.
  final File file;

  /// The room to edit.
  final LoadedRoom room;

  /// The function which converts paths to [Sound]s.
  final GetSound getSound;

  /// A function to get a new ID.
  final String Function() newId;

  /// The possible footstep sounds.
  final List<FootstepsSounds> footsteps;

  /// The list of possible music sound paths.
  final List<String> musicSoundPaths;

  /// The list of possible ambiance sound paths.
  final List<String> ambianceSoundPaths;

  /// The list of possible door sounds.
  final List<String> doorSounds;

  /// How much to attenuate [RoomObject] ambiances by when there are walls in
  /// the way.
  final double wallAttenuation;

  /// How far to cutoff frequencies when occluding sounds for walls.
  final double wallFactor;

  /// The function to use to examine [RoomObject]s.
  final ExamineObjectCallback onExamineObject;

  /// The function to determine how far away objects can be examined.
  final ExamineObjectDistance getExamineObjectDistance;

  /// The function to call to get the order of examined objects.
  final ExamineObjectOrdering getExamineObjectOrdering;

  /// The function to call to handle the [NoRoomObjects] event.
  final NoRoomObjectsCallback onNoRoomObjects;

  /// The engine commands which have been created.
  final List<EngineCommand> engineCommands;

  /// Save [room].
  void save() {
    final source = encoder.convert(room.editorRoom.toJson());
    file.writeAsStringSync(source);
  }
}
