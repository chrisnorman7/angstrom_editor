import 'dart:convert';
import 'dart:io';

import 'package:angstrom/angstrom.dart';
import 'package:angstrom_editor/angstrom_editor.dart';

/// The engine to use for the editor.
class EditorEngine extends AngstromEngine {
  /// Create an instance.
  EditorEngine({required super.playerCharacter}) : super();

  /// Build rooms by loading [id] as a [File].
  @override
  Room buildRoom(final String id) {
    final file = File(id);
    final source = file.readAsStringSync();
    final json = jsonDecode(source) as Map<String, dynamic>;
    final editorRoom = EditorRoom.fromJson(json);
    return LoadedRoom(
      path: id,
      editorRoom: editorRoom,
      events: const LoadedRoomEvents(surfaceEvents: {}, objectEvents: {}),
    );
  }
}
