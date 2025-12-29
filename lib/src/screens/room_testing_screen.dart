import 'package:angstrom/angstrom.dart';
import 'package:angstrom_editor/angstrom_editor.dart';
import 'package:backstreets_widgets/extensions.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';

/// A screen for testing a room.
class RoomTestingScreen extends StatefulWidget {
  /// Create an instance.
  const RoomTestingScreen({required this.editorContext, super.key});

  /// The editor context to use.
  final EditorContext editorContext;

  /// Create state for this widget.
  @override
  RoomTestingScreenState createState() => RoomTestingScreenState();
}

/// State for [RoomTestingScreen].
class RoomTestingScreenState extends State<RoomTestingScreen> {
  /// The engine to use.
  late final RoomTestingAngstromEngine engine;

  /// Initialise state.
  @override
  void initState() {
    super.initState();
    engine = RoomTestingAngstromEngine(
      startRoom: widget.editorContext.room,
      rooms: rooms,
      engineCommands: widget.editorContext.engineCommands,
      callEngineCommand: widget.editorContext.callEngineCommand,
    );
  }

  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final editorRoom = widget.editorContext.room.editorRoom;
    return Cancel(
      child: GameScreen(
        engine: engine,
        title: 'Test ${editorRoom.name}',
        getSound: widget.editorContext.getSound,
        gameShortcutsBuilder: (final context, final shortcuts) {
          shortcuts.addAll([
            GameShortcut(
              title: 'Teleport',
              shortcut: GameShortcutsShortcut.keyT,
              onStart: (final innerContext) {
                innerContext.pushWidgetBuilder(
                  (_) => SelectRoomScreen(
                    rooms: rooms,
                    onChange: (final value) => engine.teleportPlayer(
                      value.id,
                      value.editorRoom.surfaces.first.points.first.coordinates,
                    ),
                    roomId: engine.room.id,
                  ),
                );
              },
            ),
            GameShortcut(
              title: 'Announce current room',
              shortcut: GameShortcutsShortcut.keyR,
              onStart: (final innerContext) {
                final room = engine.loadedRoom;
                final editorRoom = room.editorRoom;
                final eventNames = editorRoom.eventCommands.keys
                    .map((final eventType) => eventType.name)
                    .join(', ');
                return engine.speak(
                  '${editorRoom.name}: ${room.id} ( $eventNames)',
                );
              },
            ),
            GameShortcut(
              title: 'Jump to object',
              shortcut: GameShortcutsShortcut.keyJ,
              onStart: (final innerContext) {
                final editorContext = EditorContext(
                  room: engine.loadedRoom,
                  getSound: widget.editorContext.getSound,
                  newId: widget.editorContext.newId,
                  footsteps: widget.editorContext.footsteps,
                  musicSoundPaths: widget.editorContext.musicSoundPaths,
                  ambianceSoundPaths: widget.editorContext.ambianceSoundPaths,
                  doorSounds: widget.editorContext.doorSounds,
                  wallAttenuation: widget.editorContext.wallAttenuation,
                  wallFactor: widget.editorContext.wallFactor,
                  onExamineObject: widget.editorContext.onExamineObject,
                  getExamineObjectDistance:
                      widget.editorContext.getExamineObjectDistance,
                  getExamineObjectOrdering:
                      widget.editorContext.getExamineObjectOrdering,
                  onNoRoomObjects: widget.editorContext.onNoRoomObjects,
                  engineCommands: widget.editorContext.engineCommands,
                  callEngineCommand: widget.editorContext.callEngineCommand,
                );
                innerContext.pushWidgetBuilder(
                  (_) => SelectObjectScreen(
                    editorContext: editorContext,
                    objects: engine.loadedRoom.editorRoom.objects,
                    onChange: (final value) {
                      engine.teleportPlayer(engine.room.id, value.coordinates);
                    },
                  ),
                );
              },
            ),
          ]);
          return shortcuts;
        },
        onExamineObject: (final objectReference, final state) {
          final object = engine.loadedRoom.editorRoom.objects.firstWhere(
            (final o) =>
                o.coordinates == objectReference.coordinates &&
                o.name == objectReference.name,
          );
          final eventNames = object.eventCommands.keys
              .map((final eventType) => eventType.name)
              .join(', ');
          engine.speak(
            '${object.name}: ${object.x}, ${object.y} ($eventNames)',
          );
        },
      ),
    );
  }

  /// Get the rooms for the editor context.
  List<LoadedRoom> get rooms => widget.editorContext.file.parent.rooms.toList();
}
