import 'package:angstrom_editor/angstrom_editor.dart';
import 'package:backstreets_widgets/screens.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';

/// Edit the nearest [EditorContext].
class RoomEditor extends StatefulWidget {
  /// Create an instance.
  const RoomEditor({super.key});

  @override
  State<RoomEditor> createState() => _RoomEditorState();
}

class _RoomEditorState extends State<RoomEditor> {
  /// Build the widget.
  @override
  Widget build(final BuildContext context) {
    final editorContext = context.editorContext;
    final room = editorContext.room;
    return Cancel(
      child: TabbedScaffold(
        tabs: [
          TabbedScaffoldTab(
            title: room.editorRoom.name,
            icon: const Icon(Icons.map),
            child: const RoomEditorPage(),
          ),
          TabbedScaffoldTab(
            title: 'Surfaces',
            icon: const Icon(Icons.list),
            child: CommonShortcuts(
              newCallback: _newSurface,
              child: RoomSurfacesPage(
                onChange: () {
                  editorContext.save();
                  setState(() {});
                },
              ),
            ),
            floatingActionButton: NewButton(
              onPressed: _newSurface,
              tooltip: 'New surface',
            ),
          ),
          TabbedScaffoldTab(
            title: 'Objects',
            icon: const Icon(Icons.people),
            child: CommonShortcuts(
              child: CommonShortcuts(
                newCallback: _newObject,
                child: RoomObjectsPage(
                  onChange: () {
                    editorContext.save();
                    setState(() {});
                  },
                ),
              ),
            ),
            floatingActionButton: NewButton(
              onPressed: _newObject,
              tooltip: 'New object',
            ),
          ),
        ],
        initialPageIndex: room.editorRoom.lastPageIndex,
        onPageChange: (final value) {
          room.editorRoom.lastPageIndex = value;
          editorContext.save();
        },
      ),
    );
  }

  /// Create a new surface.
  void _newSurface() {
    final editorContext = context.editorContext;
    final surface = EditorRoomSurface(
      id: editorContext.newId(),
      name: 'Untitled Surface',
      points: [],
      contactSounds: editorContext.footsteps.first.soundPaths,
    );
    editorContext.room.editorRoom.surfaces.add(surface);
    editorContext.save();
    setState(() {});
  }

  /// Create a new object.
  void _newObject() {
    final editorContext = context.editorContext;
    final object = EditorRoomObject(
      id: editorContext.newId(),
      name: 'Untitled Object',
    );
    editorContext.room.editorRoom.objects.add(object);
    editorContext.save();
    setState(() {});
  }
}
