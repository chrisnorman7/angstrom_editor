import 'dart:io';

import 'package:angstrom_editor/angstrom_editor.dart';
import 'package:backstreets_widgets/extensions.dart';
import 'package:backstreets_widgets/screens.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_games/flutter_audio_games.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

/// A screen for selecting the target of a door.
class SelectDoorTargetScreen extends StatefulWidget {
  /// Create an instance.
  const SelectDoorTargetScreen({
    required this.roomsDirectory,
    required this.onChange,
    required this.getSound,
    this.roomId,
    this.objectId,
    super.key,
  });

  /// The directory where room files are stored.
  final Directory roomsDirectory;

  /// The function to call when a target has been selected.
  final ValueChanged<DoorTarget> onChange;

  /// The function to get sounds.
  final GetSound getSound;

  /// The ID of the current room.
  final String? roomId;

  /// The ID of the current object.
  final String? objectId;

  /// Create state for this widget.
  @override
  SelectDoorTargetScreenState createState() => SelectDoorTargetScreenState();
}

/// State for [SelectDoorTargetScreen].
class SelectDoorTargetScreenState extends State<SelectDoorTargetScreen> {
  /// The selected room.
  LoadedRoom? _room;

  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final room = _room;
    if (room == null) {
      final rooms = widget.roomsDirectory.rooms.toList();
      return Cancel(
        child: SimpleScaffold(
          title: 'Select Room',
          body: ListView.builder(
            itemBuilder: (final context, final index) {
              final room = rooms[index];
              final editorRoom = room.editorRoom;
              final music = room.music;
              final sound = music == null
                  ? null
                  : widget.getSound(
                      soundReference: music,
                      destroy: false,
                      loadMode: LoadMode.disk,
                      looping: true,
                    );
              return MaybePlaySoundSemantics(
                sound: sound,
                child: ListTile(
                  autofocus: widget.roomId == null
                      ? index == 0
                      : room.id == widget.roomId,
                  title: Text(editorRoom.name),
                  onTap: () => setState(() => _room = room),
                ),
              );
            },
            itemCount: rooms.length,
            shrinkWrap: true,
          ),
        ),
      );
    }
    final objects = room.editorRoom.objects;
    return Cancel(
      child: SimpleScaffold(
        title: 'Select Object',
        body: ListView.builder(
          itemBuilder: (final context, final index) {
            final object = objects[index];
            final ambiance = object.ambiance;
            final sound = ambiance == null
                ? null
                : widget.getSound(
                    soundReference: ambiance,
                    destroy: false,
                    loadMode: LoadMode.disk,
                    looping: true,
                  );
            return MaybePlaySoundSemantics(
              sound: sound,
              child: ListTile(
                autofocus: widget.objectId == null
                    ? index == 0
                    : object.id == widget.objectId,
                title: Text(object.name),
                subtitle: Text('${object.x}, ${object.y}'),
                onTap: () {
                  context.pop();
                  widget.onChange(DoorTarget(room: room, object: object));
                },
              ),
            );
          },
          itemCount: objects.length,
          shrinkWrap: true,
        ),
      ),
    );
  }
}
