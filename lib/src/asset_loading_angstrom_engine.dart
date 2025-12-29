import 'dart:async';
import 'dart:convert';

import 'package:angstrom/angstrom.dart';
import 'package:angstrom_editor/angstrom_editor.dart';
import 'package:flutter/services.dart';

/// An [AngstromEngine] whose [buildRoom] method builds [LoadedRoom]s from asset
/// keys.
class AssetLoadingAngstromEngine extends AngstromEngine {
  /// Create an instance.
  AssetLoadingAngstromEngine({
    required super.playerCharacter,
    required this.assetBundle,
    super.musicFadeIn,
    super.musicFadeOut,
    this.roomEvents = const {},
  });

  /// The map of asset keys to [LoadedRoomEvents] instances.
  ///
  /// The [roomEvents] map will be used by [buildRoom] to ensure the appropriate
  /// events are bound to the right things.
  final Map<String, LoadedRoomEvents> roomEvents;

  /// The asset bundle to use.
  final AssetBundle assetBundle;

  /// Load a room from [key].
  @override
  Future<LoadedRoom> buildRoom(final String key) async {
    final source = await assetBundle.loadString(key);
    final json = jsonDecode(source) as Map<String, dynamic>;
    final editorRoom = EditorRoom.fromJson(json);
    final loadedRoomEvents = roomEvents[key];
    for (final surface in editorRoom.surfaces) {
      for (final eventType in surface.eventCommands.keys) {
        if (loadedRoomEvents == null) {
          throw StateError(
            // ignore: lines_longer_than_80_chars
            'No events have been provided for room ${editorRoom.name} with ID $key.\nEvents map: $roomEvents.',
          );
        }
        final surfaceEvents = loadedRoomEvents.surfaceEvents[surface.id];
        if (surfaceEvents == null) {
          throw StateError(
            // ignore: lines_longer_than_80_chars
            'While events were provided for the ${editorRoom.name} room with ID $key, `surfaceEvents` is `null`.',
          );
        }
        if (surfaceEvents.getEventCallback(eventType) == null) {
          throw StateError(
            // ignore: lines_longer_than_80_chars
            'While loading events for the ${editorRoom.name} room from asset key $key, the ${eventType.name} event which is required by the ${surface.name} surface with ID ${surface.id} is `null`.',
          );
        }
      }
    }
    return LoadedRoom(
      path: key,
      editorRoom: editorRoom,
      events:
          loadedRoomEvents ??
          const LoadedRoomEvents(surfaceEvents: {}, objectEvents: {}),
    );
  }
}
