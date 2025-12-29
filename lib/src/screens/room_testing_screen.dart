import 'package:angstrom/angstrom.dart';
import 'package:angstrom_editor/angstrom_editor.dart';
import 'package:backstreets_widgets/extensions.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';

/// A screen for testing the given [room].
class RoomTestingScreen extends StatefulWidget {
  /// Create an instance.
  const RoomTestingScreen({
    required this.rooms,
    required this.room,
    required this.getSound,
    super.key,
  });

  /// The rooms to use.
  final List<LoadedRoom> rooms;

  /// The room to test with.
  final LoadedRoom room;

  /// The get sound function to use.
  final GetSound getSound;

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
      startRoom: widget.room,
      rooms: widget.rooms,
    );
  }

  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final editorRoom = widget.room.editorRoom;
    return Cancel(
      child: GameScreen(
        engine: engine,
        title: 'Test ${editorRoom.name}',
        getSound: widget.getSound,
        gameShortcutsBuilder: (final context, final shortcuts) {
          shortcuts.addAll([
            GameShortcut(
              title: 'Teleport',
              shortcut: GameShortcutsShortcut.keyT,
              onStart: (final innerContext) {
                innerContext.pushWidgetBuilder(
                  (_) => SelectRoomScreen(
                    rooms: widget.rooms,
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
}
