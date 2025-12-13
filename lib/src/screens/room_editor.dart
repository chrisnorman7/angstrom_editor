import 'package:angstrom_editor/angstrom_editor.dart';
import 'package:backstreets_widgets/screens.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';

/// Edit the given [editorContext].
class RoomEditor extends StatefulWidget {
  /// Create an instance.
  const RoomEditor({required this.editorContext, super.key});

  /// The room editor context to use.
  final EditorContext editorContext;

  @override
  State<RoomEditor> createState() => _RoomEditorState();
}

class _RoomEditorState extends State<RoomEditor> {
  /// Build the widget.
  @override
  Widget build(final BuildContext context) {
    final room = widget.editorContext.room;
    return Cancel(
      child: TabbedScaffold(
        tabs: [
          TabbedScaffoldTab(
            title: room.editorRoom.name,
            icon: const Icon(Icons.map),
            child: RoomEditorPage(editorContext: widget.editorContext),
          ),
          TabbedScaffoldTab(
            title: 'Surfaces',
            icon: const Icon(Icons.list),
            child: CommonShortcuts(
              newCallback: _newSurface,
              child: RoomSurfacesPage(
                editorContext: widget.editorContext,
                onChange: () {
                  widget.editorContext.save();
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
                  editorContext: widget.editorContext,
                  onChange: () {
                    widget.editorContext.save();
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
          widget.editorContext.save();
        },
      ),
    );
  }

  /// Create a new surface.
  void _newSurface() {
    final surface = EditorRoomSurface(
      id: widget.editorContext.newId(),
      name: 'Untitled Surface',
      points: [],
      contactSounds: widget.editorContext.footsteps.first.soundPaths,
    );
    widget.editorContext.room.editorRoom.surfaces.add(surface);
    widget.editorContext.save();
    setState(() {});
  }

  /// Create a new object.
  void _newObject() {
    final object = EditorRoomObject(
      id: widget.editorContext.newId(),
      name: 'Untitled Object',
    );
    widget.editorContext.room.editorRoom.objects.add(object);
    widget.editorContext.save();
    setState(() {});
  }
}
