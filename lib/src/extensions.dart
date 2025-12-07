import 'dart:convert';
import 'dart:io';

import 'package:angstrom_editor/angstrom_editor.dart';

/// Useful extensions on [Directory] instances.
extension DirectoryX on Directory {
  /// Convert all JSON files in `this` [Directory] to [LoadedRoom] instances.
  Iterable<LoadedRoom> get rooms {
    final files = listSync().whereType<File>().toList();
    final rooms = files.map((final file) {
      final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final editorRoom = EditorRoom.fromJson(json);
      return LoadedRoom(
        path: file.path,
        editorRoom: editorRoom,
        events: const LoadedRoomEvents(surfaceEvents: {}, objectEvents: {}),
      );
    });
    return rooms;
  }
}
