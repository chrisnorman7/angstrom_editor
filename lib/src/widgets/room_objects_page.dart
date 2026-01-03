import 'package:angstrom_editor/angstrom_editor.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';

/// The room objects page.
class RoomObjectsPage extends StatefulWidget {
  /// Create an instance.
  const RoomObjectsPage({required this.onChange, super.key});

  /// The function to call when a surface has been edited.
  final VoidCallback onChange;

  @override
  State<RoomObjectsPage> createState() => RoomObjectsPageState();
}

/// State for [RoomObjectsPage].
class RoomObjectsPageState extends State<RoomObjectsPage> {
  /// The ID of the object which was last touched.
  String? _lastId;

  /// Build the widget.
  @override
  Widget build(final BuildContext context) {
    final editorContext = context.editorContext;
    final room = editorContext.room.editorRoom;
    final objects = room.objects;
    if (objects.isEmpty) {
      return const CenterText(text: 'There are no objects in this room.');
    }
    objects.sort(
      (final a, final b) =>
          a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    return ListView.builder(
      itemBuilder: (final context, final index) {
        final object = objects[index];
        final autofocus = _lastId == null ? index == 0 : object.id == _lastId;
        return RoomObjectListTile(
          autofocus: autofocus,
          object: object,
          onChange: (final newObject) {
            _lastId = newObject?.id;
            widget.onChange();
            setState(() {});
          },
        );
      },
      itemCount: objects.length,
      shrinkWrap: true,
    );
  }
}
