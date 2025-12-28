import 'dart:io';

import 'package:angstrom_editor/angstrom_editor.dart';
import 'package:backstreets_widgets/extensions.dart';
import 'package:backstreets_widgets/screens.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';

/// A screen for editing a [door].
class EditDoorScreen extends StatefulWidget {
  /// Create an instance.
  const EditDoorScreen({
    required this.editorContext,
    required this.door,
    super.key,
  });

  /// The editor context to use.
  final EditorContext editorContext;

  /// The door to change.
  final EditorDoor door;

  /// Create state for this widget.
  @override
  EditDoorScreenState createState() => EditDoorScreenState();
}

/// State for [EditDoorScreen].
class EditDoorScreenState extends State<EditDoorScreen> {
  /// The door to work on.
  late final EditorDoor door;

  /// Initialise state.
  @override
  void initState() {
    super.initState();
    door = widget.door;
  }

  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final currentEditorContext = widget.editorContext;
    final roomsDirectory = currentEditorContext.file.parent;
    final rooms = roomsDirectory.rooms.toList();
    final room = rooms.firstWhere(
      (final room) => room.id == door.targetRoomId,
      orElse: () => rooms.first,
    );
    final editorContext = EditorContext(
      file: File(room.path),
      room: room,
      getSound: currentEditorContext.getSound,
      newId: currentEditorContext.newId,
      footsteps: currentEditorContext.footsteps,
      musicSoundPaths: currentEditorContext.musicSoundPaths,
      ambianceSoundPaths: currentEditorContext.ambianceSoundPaths,
      doorSounds: currentEditorContext.doorSounds,
      wallAttenuation: currentEditorContext.wallAttenuation,
      wallFactor: currentEditorContext.wallFactor,
      onExamineObject: currentEditorContext.onExamineObject,
      getExamineObjectDistance: currentEditorContext.getExamineObjectDistance,
      getExamineObjectOrdering: currentEditorContext.getExamineObjectOrdering,
      onNoRoomObjects: currentEditorContext.onNoRoomObjects,
      engineCommands: widget.editorContext.engineCommands,
    );
    final objects = [for (final room in rooms) ...room.editorRoom.objects];
    final object = objects.firstWhere((final o) => o.id == door.targetObjectId);
    return Cancel(
      child: SimpleScaffold(
        title: 'Edit Door',
        body: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              autofocus: true,
              title: const Text('Target object'),
              subtitle: Text(object.name),
              onTap: () => context.pushWidgetBuilder(
                (_) => SelectDoorTargetScreen(
                  roomsDirectory: roomsDirectory,
                  onChange: (final value) {
                    door
                      ..coordinates = value.object.coordinates
                      ..targetObjectId = value.object.id
                      ..targetRoomId = value.room.id;
                    save();
                  },
                  getSound: editorContext.getSound,
                  objectId: object.id,
                  roomId: room.id,
                ),
              ),
            ),
            ListTile(
              title: const Text('Target room'),
              subtitle: Text(room.editorRoom.name),
              onTap: () => room.id.copyToClipboard(),
            ),
            ListTile(
              title: const Text('Target coordinates'),
              subtitle: Text('${object.x}, ${object.y}'),
              onTap: () => 'Point(${object.x}, ${object.y})'.copyToClipboard(),
            ),
            CheckboxListTile(
              value: door.stopPlayer,
              onChanged: (final value) {
                door.stopPlayer = !door.stopPlayer;
                save();
              },
              title: const Text('Stop player'),
            ),
            SoundPathListTile(
              soundPaths: editorContext.doorSounds,
              getSound: editorContext.getSound,
              title: 'Use sound',
              onChange: (final value) {
                door.useSound = value;
                save();
              },
              soundReference: door.useSound,
            ),
          ],
        ),
      ),
    );
  }

  /// Save the [door].
  void save() {
    widget.editorContext.save();
    setState(() {});
  }
}
