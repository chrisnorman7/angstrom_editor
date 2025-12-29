import 'package:angstrom_editor/angstrom_editor.dart';
import 'package:backstreets_widgets/screens.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';

/// A screen for selecting a new room from [rooms].
class SelectRoomScreen extends StatelessWidget {
  /// Create an instance.
  const SelectRoomScreen({
    required this.rooms,
    required this.onChange,
    this.roomId,
    this.title = 'Select Room',
    super.key,
  });

  /// The rooms to pick from.
  final List<LoadedRoom> rooms;

  /// The function to call when a new room is selected.
  final ValueChanged<LoadedRoom> onChange;

  /// The ID of the current room.
  final String? roomId;

  /// The title of the resulting [SimpleScaffold].
  final String title;

  /// Build the widget.
  @override
  Widget build(final BuildContext context) => Cancel(
    child: SimpleScaffold(
      title: title,
      body: ListView.builder(
        itemBuilder: (final context, final index) {
          final room = rooms[index];
          final editorRoom = room.editorRoom;
          return ListTile(
            autofocus: roomId == null ? index == 0 : room.id == roomId,
            title: Text(editorRoom.name),
            onTap: () {
              Navigator.pop(context);
              onChange(room);
            },
          );
        },
      ),
    ),
  );
}
