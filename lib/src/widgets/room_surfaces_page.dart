import 'package:angstrom_editor/angstrom_editor.dart';
import 'package:flutter/material.dart';

/// A page for editing a room surfaces.
class RoomSurfacesPage extends StatelessWidget {
  /// Create an instance.
  const RoomSurfacesPage({
    required this.editorContext,
    required this.onChange,
    super.key,
  });

  /// The editor context to work with.
  final EditorContext editorContext;

  /// The function to call when a surface has been edited.
  final VoidCallback onChange;

  /// Build the widget.
  @override
  Widget build(final BuildContext context) {
    final room = editorContext.room;
    final surfaces = room.editorRoom.surfaces;
    return ListView.builder(
      itemBuilder: (final context, final index) {
        final surface = surfaces[index];
        return EditorRoomSurfaceListTile(
          editorContext: editorContext,
          surfaceId: surface.id,
          onChange: onChange,
          autofocus: index == 0,
        );
      },
      itemCount: surfaces.length,
      shrinkWrap: true,
    );
  }
}
