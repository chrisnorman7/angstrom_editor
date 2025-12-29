import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:angstrom/angstrom.dart';
import 'package:angstrom_editor/angstrom_editor.dart';
import 'package:backstreets_widgets/extensions.dart';
import 'package:backstreets_widgets/screens.dart';
import 'package:backstreets_widgets/shortcuts.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_games/flutter_audio_games.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

/// The main editor screen.
class AngstromEditor extends StatefulWidget {
  /// Create an instance.
  const AngstromEditor({
    required this.directory,
    required this.engineCommandsFile,
    required this.footsteps,
    required this.musicSoundPaths,
    required this.ambianceSoundPaths,
    required this.doorSoundPaths,
    this.codeDirectoryPath = 'lib/src/rooms',
    this.engineCodePath = 'lib/src/custom_engine.dart',
    this.getSound,
    this.title = 'Angstrom Editor',
    this.wallAttenuation = 0.4,
    this.wallFactor = 0.5,
    this.onExamineObject = defaultExamineRoomObject,
    this.getExamineObjectDistance = defaultGetExamineObjectDistance,
    this.getExamineObjectOrdering = defaultGetExamineObjectOrdering,
    this.onNoRoomObjects = defaultNoRoomObjects,
    this.volumeChangeAmount = 0.1,
    this.buildCompleteSound,
    this.buildFailSound,
    super.key,
  }) : assert(
         footsteps.length > 0,
         'You must provide at least 1 footstep sound.',
       ),
       assert(
         musicSoundPaths.length > 0,
         'You must include at least 1 music path.',
       ),
       assert(
         ambianceSoundPaths.length > 0,
         'You must include at least 1 ambiance path.',
       );

  /// The directory where room files are kept.
  final Directory directory;

  /// The file which contains engine commands.
  final File engineCommandsFile;

  /// The possible footstep sounds.
  final List<FootstepsSounds> footsteps;

  /// The list of possible music sound paths.
  final List<String> musicSoundPaths;

  /// The list of possible ambiance sound paths.
  final List<String> ambianceSoundPaths;

  /// The list of possible door sound paths.
  final List<String> doorSoundPaths;

  /// path of the The directory where generated code should be written.
  final String codeDirectoryPath;

  /// The path to the file where the engine code will be stored.
  final String engineCodePath;

  /// The function which converts paths to [Sound]s.
  final GetSound? getSound;

  /// The title of the editor.
  final String title;

  /// How much to attenuate [RoomObject] ambiances by when there are walls in
  /// the way.
  final double wallAttenuation;

  /// How far to cutoff frequencies when occluding sounds for walls.
  final double wallFactor;

  /// The function to use to examine [RoomObject]s.
  final ExamineObjectCallback onExamineObject;

  /// The function to determine how far away objects can be examined.
  final ExamineObjectDistance getExamineObjectDistance;

  /// The function to call to get the order of examined objects.
  final ExamineObjectOrdering getExamineObjectOrdering;

  /// The function to call to handle the [NoRoomObjects] event.
  final NoRoomObjectsCallback onNoRoomObjects;

  /// The amount to change sound volumes by.
  final double volumeChangeAmount;

  /// The sound to play when code generation is successful.
  final Sound? buildCompleteSound;

  /// The sound to play when code generation fails.
  final Sound? buildFailSound;

  /// Create state for this widget.
  @override
  AngstromEditorState createState() => AngstromEditorState();
}

/// State for [AngstromEditor].
class AngstromEditorState extends State<AngstromEditor> {
  /// The directory where code should be written.
  late final Directory codeDirectory;

  /// The last index to be clicked.
  late int _lastIndex;

  /// The UUID generator to use.
  late final Uuid uuid;

  /// Get a new ID.
  String newId() => uuid.v7();

  /// Initialise state.
  @override
  void initState() {
    super.initState();
    codeDirectory = Directory(widget.codeDirectoryPath);
    _lastIndex = 0;
    uuid = const Uuid();
  }

  /// Get get sound function.
  GetSound get getSound => widget.getSound ?? defaultGetSound;

  /// The engine commands which have been created.
  List<EngineCommand> get engineCommands {
    if (widget.engineCommandsFile.existsSync()) {
      final json =
          jsonDecode(widget.engineCommandsFile.readAsStringSync())
              as Map<String, dynamic>;
      return EngineCommands.fromJson(json).engineCommands;
    }
    return [];
  }

  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    if (!widget.directory.existsSync()) {
      widget.directory.createSync(recursive: true);
    }
    final rooms = widget.directory.rooms.toList();
    final Widget child;
    if (rooms.isEmpty) {
      child = const CenterText(text: 'No rooms have been created yet.');
    } else {
      child = ListView.builder(
        itemBuilder: (final context, final index) {
          final room = rooms[index];
          final editorRoom = room.editorRoom;
          final editorContext = EditorContext(
            room: room,
            getSound: getSound,
            newId: newId,
            footsteps: widget.footsteps,
            musicSoundPaths: widget.musicSoundPaths,
            ambianceSoundPaths: widget.ambianceSoundPaths,
            doorSounds: widget.doorSoundPaths,
            wallAttenuation: widget.wallAttenuation,
            wallFactor: widget.wallFactor,
            onExamineObject: widget.onExamineObject,
            getExamineObjectDistance: widget.getExamineObjectDistance,
            getExamineObjectOrdering: widget.getExamineObjectOrdering,
            onNoRoomObjects: widget.onNoRoomObjects,
            engineCommands: engineCommands,
          );
          final musicReference = editorRoom.music;
          final sound = musicReference == null
              ? null
              : getSound(
                  soundReference: musicReference,
                  destroy: false,
                  loadMode: LoadMode.disk,
                  looping: true,
                );
          return MaybePlaySoundSemantics(
            sound: sound,
            child: PerformableActionsListTile(
              actions: [
                PerformableAction(
                  name: 'Rename',
                  activator: renameShortcut,
                  invoke: () {
                    _lastIndex = index;
                    context.pushWidgetBuilder(
                      (final innerContext) => GetText(
                        onDone: (final value) {
                          innerContext.pop();
                          editorRoom.name = value;
                          editorContext.save();
                          setState(() {});
                        },
                        labelText: 'Name',
                        text: editorRoom.name,
                        title: 'Rename room',
                      ),
                    );
                  },
                ),
                if (musicReference == null) ...[
                  PerformableAction(
                    name: 'Set music',
                    activator: editMusicShortcut,
                    invoke: () {
                      _lastIndex = index;
                      context.pushWidgetBuilder(
                        (_) => SelectSoundScreen(
                          soundPaths: widget.musicSoundPaths,
                          getSound: getSound,
                          setSound: (final value) {
                            editorRoom.music = SoundReference(
                              path: value,
                              volume: musicReference?.volume ?? 0.7,
                            );
                            editorContext.save();
                            setState(() {});
                          },
                          looping: true,
                          soundPath: musicReference?.path,
                          title: 'Select Music',
                          volume: musicReference?.volume ?? 0.7,
                        ),
                      );
                    },
                  ),
                ] else ...[
                  ...SoundReferenceVolumeActions(
                    soundReference: musicReference,
                    onChange: (final value) {
                      _lastIndex = index;
                      editorRoom.music = value;
                      editorContext.save();
                      setState(() {});
                    },
                  ).getActions(context),
                  PerformableAction(
                    name: 'Remove music',
                    activator: editMusicShortcut,
                    invoke: () {
                      _lastIndex = index;
                      editorRoom.music = null;
                      editorContext.save();
                      setState(() {});
                    },
                  ),
                ],
                ...EventCommandsPerformableActions(
                  editorContext: editorContext,
                  events: [AngstromEventType.onEnter, AngstromEventType.onExit],
                  map: editorRoom.eventCommands,
                  save: () {
                    editorContext.save();
                    setState(() {});
                  },
                ).getActions(context),
                PerformableAction(
                  name: 'Test room',
                  activator: testShortcut,
                  invoke: () {
                    context.pushWidgetBuilder(
                      (_) => RoomTestingScreen(editorContext: editorContext),
                    );
                  },
                ),
                PerformableAction(
                  name: 'Delete',
                  activator: deleteShortcut,
                  invoke: () {
                    _lastIndex = index;
                    for (final otherRoom in rooms) {
                      for (final object in otherRoom.editorRoom.objects) {
                        for (final command in object.eventCommands.values) {
                          if (command.door?.targetRoomId == room.id) {
                            context.showMessage(
                              message:
                                  // ignore: lines_longer_than_80_chars
                                  'You cannot delete ${room.editorRoom.name} because it is used as the target for the ${object.name} door.',
                            );
                            return;
                          }
                        }
                      }
                    }
                    context.showConfirmMessage(
                      message: 'Really delete ${editorRoom.name}?',
                      title: confirmDelete,
                      yesCallback: () {
                        _lastIndex = max(0, _lastIndex - 1);
                        editorContext.file.deleteSync();
                        setState(() {});
                      },
                      noLabel: 'Cancel',
                      yesLabel: 'Delete',
                    );
                  },
                ),
              ],
              autofocus: index == _lastIndex,
              title: Text(editorRoom.name),
              subtitle: musicReference == null
                  ? null
                  : SoundReferenceText(soundReference: musicReference),
              onTap: () {
                _lastIndex = index;
                final engine = EditorEngine(
                  playerCharacter: PlayerCharacter(
                    id: newId(),
                    name: 'Editor Player',
                    locationId: room.id,
                    x: editorRoom.x,
                    y: editorRoom.y,
                    statsMap: {},
                  ),
                );
                context.pushWidgetBuilder(
                  (_) => EditorContextScope(
                    engine: engine,
                    editorContext: editorContext,
                    child: const RoomEditor(),
                  ),
                );
              },
            ),
          );
        },
        itemCount: rooms.length,
        shrinkWrap: true,
      );
    }
    final actionsContext = PerformableActionsContext.fromActions([
      PerformableAction(
        name: 'Build code',
        activator: buildShortcut,
        invoke: () => _buildRoomsCode(rooms),
      ),
      PerformableAction(
        name: 'Edit engine commands',
        activator: editEngineCommands,
        invoke: () => context.pushWidgetBuilder(
          (_) => EngineCommandsScreen(
            roomsDirectory: widget.directory,
            engineCommands: engineCommands,
            newId: newId,
            saveEngineCommands: () {
              final json = encoder.convert(
                EngineCommands(engineCommands: engineCommands),
              );
              widget.engineCommandsFile.writeAsStringSync(json);
              setState(() {});
            },
          ),
        ),
      ),
    ]);
    return MenuAnchor(
      menuChildren: actionsContext.menuChildren,
      builder: (final context, final controller, _) => CallbackShortcuts(
        bindings: actionsContext.bindings,
        child: SimpleScaffold(
          title: widget.title,
          actions: [
            IconButton(
              onPressed: controller.toggle,
              icon: const Icon(Icons.more_vert),
              tooltip: 'More menu',
            ),
          ],
          body: CommonShortcuts(newCallback: _newRoom, child: child),
          floatingActionButton: FloatingActionButton(
            autofocus: rooms.isEmpty,
            onPressed: _newRoom,
            tooltip: 'New room',
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }

  /// Build the code for [rooms].
  void _buildRoomsCode(final List<LoadedRoom> rooms) {
    try {
      final editorCodeGenerator = EditorCodeGenerator(
        rooms: rooms,
        engineCommands: engineCommands,
        codeDirectory: codeDirectory,
        engineCodePath: widget.engineCodePath,
      );
      if (editorCodeGenerator.writeEngineCode()) {
        context.maybePlaySound(widget.buildCompleteSound);
      } else {
        context.maybePlaySound(widget.buildFailSound);
      }
    } catch (e) {
      context.maybePlaySound(widget.buildFailSound);
      rethrow;
    }
  }

  /// Create a new room.
  void _newRoom() {
    final room = EditorRoom(
      surfaces: [
        EditorRoomSurface(
          id: newId(),
          name: 'Untitled Surface',
          points: [const ObjectCoordinates(0, 0)],
          contactSounds: widget.footsteps.first.soundPaths,
        ),
      ],
      objects: [],
    );
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    final second = now.second.toString().padLeft(2, '0');
    final id = 'room_${now.year}$month$day$hour$minute$second';
    final file = File(
      path.join(widget.directory.path, '$id$roomFileExtension'),
    );
    final source = encoder.convert(room.toJson());
    file.writeAsStringSync(source);
    setState(() {});
  }
}
