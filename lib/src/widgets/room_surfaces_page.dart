import 'package:angstrom_editor/angstrom_editor.dart';
import 'package:flutter/material.dart';

/// A page for editing a room surfaces.
class RoomSurfacesPage extends StatefulWidget {
  /// Create an instance.
  const RoomSurfacesPage({required this.onChange, super.key});

  /// The function to call when a surface has been edited.
  final VoidCallback onChange;

  @override
  State<RoomSurfacesPage> createState() => RoomSurfacesPageState();
}

/// State for [RoomSurfacesPage].
class RoomSurfacesPageState extends State<RoomSurfacesPage> {
  /// The ID of the surface which was last touched.
  String? _lastId;

  /// Build the widget.
  @override
  Widget build(final BuildContext context) {
    final room = context.editorContext.room;
    final surfaces = room.editorRoom.surfaces
      ..sort(
        (final a, final b) =>
            a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
    return ListView.builder(
      itemBuilder: (final context, final index) {
        final surface = surfaces[index];
        final autofocus = _lastId == null ? index == 0 : surface.id == _lastId;
        return EditorRoomSurfaceListTile(
          autofocus: autofocus,
          surfaceId: surface.id,
          onChange: (final newSurface) {
            _lastId = newSurface?.id;
            widget.onChange();
            setState(() {});
          },
        );
      },
      itemCount: surfaces.length,
      shrinkWrap: true,
    );
  }
}
