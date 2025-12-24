import 'dart:math';

import 'package:angstrom/angstrom.dart';
import 'package:angstrom_editor/angstrom_editor.dart';
import 'package:backstreets_widgets/extensions.dart';
import 'package:backstreets_widgets/shortcuts.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_games/flutter_audio_games.dart';

/// A page for editing a room.
class RoomEditorPage extends StatefulWidget {
  /// Create an instance.
  const RoomEditorPage({super.key});

  /// Create state.
  @override
  RoomEditorPageState createState() => RoomEditorPageState();
}

/// State for [RoomEditorPage].
class RoomEditorPageState extends State<RoomEditorPage> {
  /// The editor context to work with.
  late EditorContext _editorContext;

  /// The engine to use.
  late AngstromEngine _engine;

  /// The room to work with.
  LoadedRoom get room => _editorContext.room;

  /// The editor room to use.
  EditorRoom get editorRoom => room.editorRoom;

  /// The coordinates of the player.
  Point<int> get coordinates => Point(editorRoom.x, editorRoom.y);

  /// Get the surface at the current coordinates.
  EditorRoomSurface? get surface => getSurfaceAt(coordinates);

  /// The current selection box.
  PointBox? _selectionBox;

  /// An object which is being moved.
  EditorRoomObject? _movingObject;

  /// Initialise state.
  @override
  void initState() {
    super.initState();
  }

  /// Build the widget.
  @override
  Widget build(final BuildContext context) {
    final scope = EditorContextScope.of(context);
    _editorContext = scope.editorContext;
    _engine = scope.engine;
    final s = surface;
    final box = _selectionBox;
    final objects = editorRoom.objects
        .where((final o) => o.coordinates == coordinates)
        .toList();
    final objectsText = objects.isEmpty
        ? ''
        : ' (${objects.map((final o) => o.name).join(' | ')})';
    final movingObject = _movingObject;
    final Widget text;
    if (movingObject != null) {
      text = Text(
        '${coordinates.x}, ${coordinates.y} (move ${movingObject.name})',
      );
    } else if (box != null) {
      final surface1 = getSurfaceAt(box.southwest);
      final surface2 = getSurfaceAt(box.northeast);
      final buffer = StringBuffer('${box.start.x}, ${box.start.y} ');
      if (surface1 != null) {
        buffer.write('(${surface1.name}) ');
      }
      buffer.write('-> ${box.northeast.x}, ${box.northeast.y}');
      if (surface2 != null) {
        buffer.write(' (${surface2.name})');
      }
      text = Text(buffer.toString());
    } else if (s == null) {
      text = Text('${coordinates.x}, ${coordinates.y}$objectsText');
    } else {
      text = Text('${coordinates.x}, ${coordinates.y}: ${s.name}$objectsText');
    }
    return MenuAnchor(
      menuChildren: [
        for (var i = 0; i < editorRoom.surfaces.length; i++)
          () {
            final menuSurface = editorRoom.surfaces[i];
            return PerformableActionMenuItem(
              action: PerformableAction(
                name: menuSurface.name,
                invoke: () {
                  if (box != null) {
                    final points = box.points.toList();
                    context.showConfirmMessage(
                      message:
                          // ignore: lines_longer_than_80_chars
                          'Are you sure you want to set ${points.length} tiles to ${menuSurface.name}?',
                      title: 'Confirm Surface Change',
                      yesLabel: 'Change ${points.length} tiles',
                      yesCallback: () {
                        for (final surface in editorRoom.surfaces) {
                          surface.points.removeWhere(
                            (final p) => points.contains(p.coordinates),
                          );
                          if (surface.id == menuSurface.id) {
                            for (final point in points) {
                              surface.points.add(
                                ObjectCoordinates(point.x, point.y),
                              );
                            }
                          }
                        }
                      },
                    );
                    return;
                  }
                  final oldSurface = surface;
                  if (oldSurface != null) {
                    oldSurface.points.removeWhere(
                      (final p) => p.coordinates == coordinates,
                    );
                  }
                  menuSurface.points.add(
                    ObjectCoordinates(coordinates.x, coordinates.y),
                  );
                  _editorContext.save();
                  _engine.movePlayer(coordinates);
                  setState(() {});
                },
                checked: menuSurface.id == surface?.id,
              ),
              autofocus: i == 0,
            );
          }(),
      ],
      builder: (final context, final controller, _) {
        final shortcuts = <GameShortcut>[
          GameShortcut(
            title: 'Move north',
            shortcut: GameShortcutsShortcut.keyW,
            onStart: (final innerContext) => movePlayer(FacingDirection.north),
          ),
          GameShortcut(
            title: 'Move east',
            shortcut: GameShortcutsShortcut.keyD,
            onStart: (final innerContext) => movePlayer(FacingDirection.east),
          ),
          GameShortcut(
            title: 'Move south',
            shortcut: GameShortcutsShortcut.keyS,
            onStart: (final innerContext) => movePlayer(FacingDirection.south),
          ),
          GameShortcut(
            title: 'Move west',
            shortcut: GameShortcutsShortcut.keyA,
            onStart: (final innerContext) => movePlayer(FacingDirection.west),
          ),
          GameShortcut(
            title: movingObject == null ? 'Change surface' : 'Place object',
            shortcut: GameShortcutsShortcut.enter,
            onStart: (final innerContext) {
              if (movingObject == null) {
                controller.toggle();
              } else {
                movingObject.coordinates = coordinates;
                _editorContext.save();
                // Make the engine reload the room.
                _engine.teleportPlayer(room.id, coordinates);
                setState(() {
                  _movingObject = null;
                });
              }
            },
          ),
          GameShortcut(
            title: 'Clear current coordinates',
            shortcut: GameShortcutsShortcut.delete,
            onStart: (final innerContext) {
              if (box == null) {
                final s = surface;
                if (s != null) {
                  s.points.removeWhere(
                    (final p) => p.coordinates == coordinates,
                  );
                  _editorContext.save();
                  _engine.movePlayer(coordinates);
                  setState(() {});
                }
                return;
              }
              final points = box.points;
              context.showConfirmMessage(
                message:
                    'Are you sure you want to clear ${points.length} tiles?',
                title: 'Clear Multiple Tiles',
                yesLabel: 'Clear ${points.length} tiles',
                yesCallback: () {
                  for (final point in points) {
                    getSurfaceAt(
                      point,
                    )?.points.removeWhere((final p) => p.coordinates == point);
                  }
                  _editorContext.save();
                  _engine.movePlayer(coordinates);
                  setState(() {});
                },
              );
            },
          ),
          GameShortcut(
            title: 'Add north to selection',
            shortcut: GameShortcutsShortcut.arrowUp,
            shiftKey: true,
            onStart: (final innerContext) =>
                changeSelection(FacingDirection.north),
          ),
          GameShortcut(
            title: 'Add east to selection',
            shortcut: GameShortcutsShortcut.arrowRight,
            shiftKey: true,
            onStart: (final innerContext) =>
                changeSelection(FacingDirection.east),
          ),
          GameShortcut(
            title: 'Add south to selection',
            shortcut: GameShortcutsShortcut.arrowDown,
            shiftKey: true,
            onStart: (final innerContext) =>
                changeSelection(FacingDirection.south),
          ),
          GameShortcut(
            title: 'Add west to selection',
            shortcut: GameShortcutsShortcut.arrowLeft,
            shiftKey: true,
            onStart: (final innerContext) =>
                changeSelection(FacingDirection.west),
          ),
          GameShortcut(
            title: 'Go to coordinates',
            shortcut: GameShortcutsShortcut.keyG,
            controlKey: useControlKey,
            metaKey: useMetaKey,
            onStart: (final innerContext) => innerContext.pushWidgetBuilder(
              (_) => GoToCoordinatesScreen(
                coordinates: coordinates,
                onChanged: _movePlayer,
              ),
            ),
          ),
          GameShortcut(
            title: 'Find tile to the north',
            shortcut: GameShortcutsShortcut.arrowUp,
            controlKey: useControlKey,
            metaKey: useMetaKey,
            onStart: (final innerContext) =>
                findTileInDirection(FacingDirection.north),
          ),
          GameShortcut(
            title: 'Find tile to the east',
            shortcut: GameShortcutsShortcut.arrowRight,
            controlKey: useControlKey,
            metaKey: useMetaKey,
            onStart: (final innerContext) =>
                findTileInDirection(FacingDirection.east),
          ),
          GameShortcut(
            title: 'Find tile to the south',
            shortcut: GameShortcutsShortcut.arrowDown,
            controlKey: useControlKey,
            metaKey: useMetaKey,
            onStart: (final innerContext) =>
                findTileInDirection(FacingDirection.south),
          ),
          GameShortcut(
            title: 'Find tile to the west',
            shortcut: GameShortcutsShortcut.arrowLeft,
            controlKey: useControlKey,
            metaKey: useMetaKey,
            onStart: (final innerContext) =>
                findTileInDirection(FacingDirection.west),
          ),
          GameShortcut(
            title: 'Focus next tile',
            shortcut: GameShortcutsShortcut.pageDown,
            onStart: (final innerContext) => focusTileInDirection(1),
          ),
          GameShortcut(
            title: 'Focus previous tile',
            shortcut: GameShortcutsShortcut.pageUp,
            onStart: (final innerContext) => focusTileInDirection(-1),
          ),
          GameShortcut(
            title: 'Focus next object',
            shortcut: GameShortcutsShortcut.pageDown,
            controlKey: useControlKey,
            metaKey: useMetaKey,
            onStart: (final innerContext) => focusObjectInDirection(1),
          ),
          GameShortcut(
            title: 'Focus previous object',
            shortcut: GameShortcutsShortcut.pageUp,
            controlKey: useControlKey,
            metaKey: useMetaKey,
            onStart: (final innerContext) => focusObjectInDirection(-1),
          ),
          GameShortcut(
            title: 'Move object',
            shortcut: GameShortcutsShortcut.period,
            controlKey: useControlKey,
            metaKey: useMetaKey,
            onStart: (final innerContext) {
              if (objects.isNotEmpty) {
                if (objects.length == 1) {
                  setState(() {
                    _movingObject = objects.single;
                  });
                } else {
                  innerContext.pushWidgetBuilder(
                    (_) => SelectObjectScreen(
                      objects: objects,
                      onChange: (final value) =>
                          setState(() => _movingObject = value),
                    ),
                  );
                }
              }
            },
          ),
          GameShortcut(
            title: 'Copy coordinates',
            shortcut: GameShortcutsShortcut.keyC,
            controlKey: useControlKey,
            metaKey: useMetaKey,
            shiftKey: true,
            onStart: (final innerContext) =>
                'Point(${coordinates.x}, ${coordinates.y})'.copyToClipboard(),
          ),
          GameShortcut(
            title: 'Show keyboard shortcuts',
            shortcut: GameShortcutsShortcut.slash,
            shiftKey: true,
            onStart: (final innerContext) {
              final inheritedShortcuts = GameShortcuts.of(
                innerContext,
              ).shortcuts;
              innerContext.pushWidgetBuilder(
                (_) => GameShortcutsHelpScreen(shortcuts: inheritedShortcuts),
              );
            },
          ),
        ];
        return GameShortcuts(shortcuts: shortcuts, child: text);
      },
    );
  }

  /// Get the surface at [coordinates].
  EditorRoomSurface? getSurfaceAt(final Point<int> coordinates) {
    for (final surface in room.editorRoom.surfaces) {
      for (final point in surface.points) {
        if (point.coordinates == coordinates) {
          return surface;
        }
      }
    }
    return null;
  }

  /// Move the player in [direction].
  void movePlayer(final FacingDirection direction) {
    _selectionBox = null;
    final newCoordinates = switch (direction) {
      FacingDirection.north => coordinates.north,
      FacingDirection.east => coordinates.east,
      FacingDirection.south => coordinates.south,
      FacingDirection.west => coordinates.west,
    };
    _movePlayer(newCoordinates);
  }

  /// Perform a move to the [newCoordinates].
  void _movePlayer(final Point<int> newCoordinates) {
    _engine.movePlayer(newCoordinates);
    editorRoom.coordinates = newCoordinates;
    _editorContext.save();
    final s = surface;
    if (s != null) {
      context.playRandomSound(
        s.contactSounds
            .map(
              (final path) => _editorContext.getSound(
                soundReference: path.asSoundReference(
                  volume: s.contactSoundsVolume,
                ),
                destroy: true,
              ),
            )
            .toList(),
      );
    }
    setState(() {});
  }

  /// Expand or contract the selection in [direction].
  void changeSelection(final FacingDirection direction) {
    final Point<int> startCoordinates;
    final int width;
    final int height;
    final box = _selectionBox;
    if (box == null) {
      switch (direction) {
        case FacingDirection.north:
          startCoordinates = coordinates;
          height = 2;
          width = 1;
          break;
        case FacingDirection.east:
          startCoordinates = coordinates;
          width = 2;
          height = 1;
          break;
        case FacingDirection.south:
          startCoordinates = coordinates.south;
          width = 1;
          height = 2;
          break;
        case FacingDirection.west:
          startCoordinates = coordinates.west;
          width = 2;
          height = 1;
          break;
      }
    } else {
      switch (direction) {
        case FacingDirection.north:
          if (box.start.y == coordinates.y) {
            startCoordinates = box.start;
            height = box.height + 1;
          } else {
            startCoordinates = box.start.north;
            height = box.height - 1;
          }
          width = box.width;
          break;
        case FacingDirection.east:
          if (box.start.x == coordinates.x) {
            startCoordinates = box.start;
            width = box.width + 1;
          } else {
            startCoordinates = box.start.east;
            width = box.width - 1;
          }
          height = box.height;
          break;
        case FacingDirection.south:
          if (box.northeast.y == coordinates.y) {
            startCoordinates = box.start.south;
            height = box.height + 1;
          } else {
            startCoordinates = box.start;
            height = box.height - 1;
          }
          width = box.width;
          break;
        case FacingDirection.west:
          if (box.northeast.x == coordinates.x) {
            startCoordinates = box.start.west;
            width = box.width + 1;
          } else {
            startCoordinates = box.start;
            width = box.width - 1;
          }
          height = box.height;
          break;
      }
    }
    if (width == 1 && height == 1) {
      setState(() {
        _selectionBox = null;
      });
    } else {
      setState(() {
        _selectionBox = PointBox(
          start: startCoordinates,
          width: width,
          height: height,
        );
      });
    }
  }

  /// Go to the next tile in the given [direction].
  void findTileInDirection(final FacingDirection direction) {
    var x = coordinates.x;
    var y = coordinates.y;
    for (final surface in editorRoom.surfaces) {
      for (final point in surface.points) {
        switch (direction) {
          case FacingDirection.north:
            if (point.x == x) {
              y = max(y, point.y);
            }
            break;
          case FacingDirection.east:
            if (point.y == y) {
              x = max(x, point.x);
            }
            break;
          case FacingDirection.south:
            if (point.x == x) {
              y = min(y, point.y);
            }
            break;
          case FacingDirection.west:
            if (point.y == y) {
              x = min(x, point.x);
            }
            break;
        }
      }
    }
    final newCoordinates = Point(x, y);
    if (newCoordinates != coordinates) {
      _movePlayer(newCoordinates);
    }
  }

  /// Focus the tile in [direction].
  void focusTileInDirection(final int direction) {
    final points =
        [
          for (final surface in editorRoom.surfaces)
            ...surface.points.map((final point) => point.coordinates),
        ]..sort((final a, final b) {
          if (a.x == b.x) {
            return a.y.compareTo(b.y);
          }
          return a.x.compareTo(b.x);
        });
    final index = (points.indexOf(coordinates) + direction) % points.length;
    if (index == -1) {
      // There is nowhere to go.
    } else {
      _movePlayer(points[index]);
    }
  }

  /// Focus the object in [direction].
  void focusObjectInDirection(final int direction) {
    for (final object in editorRoom.objects) {
      if ((direction > 0 &&
              (object.coordinates.x > coordinates.x ||
                  object.coordinates.y > coordinates.y)) ||
          (object.coordinates.x < coordinates.x ||
              object.coordinates.y < coordinates.y)) {
        _movePlayer(object.coordinates);
      }
    }
  }
}
