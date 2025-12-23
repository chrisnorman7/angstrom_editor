import 'dart:convert';
import 'dart:io';

import 'package:angstrom/angstrom.dart';
import 'package:angstrom_editor/angstrom_editor.dart';
import 'package:flutter/material.dart';
import 'package:textwrap/textwrap.dart';

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

/// Useful methods for [String]s.
extension StringX on String {
  /// Return `this` [String] as an inline comment.
  String get asInlineComment =>
      fill(this, width: 80, initialIndent: '// ', subsequentIndent: '// ');

  /// Return `this` [String] as a doc comment.
  String get asDocComment =>
      fill(this, width: 80, initialIndent: '/// ', subsequentIndent: '/// ');
}

/// Useful methods for [BuildContext]s.
extension BuildContextX on BuildContext {
  /// Get the nearest [EditorContext].
  EditorContext get editorContext => EditorContextScope.of(this).editorContext;

  /// Get the current angstrom engine.
  EditorEngine get engine => EditorContextScope.of(this).engine;

  /// The get sound function to use.
  GetSound get getSound => editorContext.getSound;

  /// The nearest loaded room.
  LoadedRoom get loadedRoom => editorContext.room;

  /// The nearest editor room.
  EditorRoom get editorRoom => loadedRoom.editorRoom;
}
