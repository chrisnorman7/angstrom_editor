import 'dart:convert';
import 'dart:io';

import 'package:angstrom/angstrom.dart';
import 'package:angstrom_editor/angstrom_editor.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart' as path;
import 'package:recase/recase.dart';

/// The suffix for all base classes.
const base = 'Base';

/// The generator for editor code.
class EditorCodeGenerator {
  /// Create an instance.
  EditorCodeGenerator({
    required this.rooms,
    required this.codeDirectory,
    required this.engineCodePath,
  }) : lineSplitter = const LineSplitter(),
       formatter = DartFormatter(
         languageVersion: DartFormatter.latestLanguageVersion,
       ),
       roomExportsFilename = '_rooms.dart';

  /// The rooms to write code for.
  final List<LoadedRoom> rooms;

  /// The directory where code should be written.
  final Directory codeDirectory;

  /// The path to the file where the engine code will be stored.
  final String engineCodePath;

  /// The line splitter to use.
  final LineSplitter lineSplitter;

  /// The code formatter to use.
  final DartFormatter formatter;

  /// The filename where the exports for rooms will be written.
  final String roomExportsFilename;

  /// Return a sound [reference] as code.
  Code _soundReferenceCode(final SoundReference reference) =>
      Code.scope((final allocate) {
        final soundReference = allocate(
          refer('SoundReference', 'package:angstrom/angstrom.dart'),
        );
        final buffer = StringBuffer()
          ..writeln('const $soundReference(')
          ..writeln('path: ${literalString(reference.path)},');
        if (reference.volume != 0.7) {
          buffer.writeln('volume: ${reference.volume},');
        }
        buffer.writeln(')');
        return buffer.toString();
      });

  /// Returns the code for the given [command].
  Code _editorEventCommandCode({
    required final AngstromEventType eventType,
    required final EditorEventCommand command,
  }) => Code.scope((final allocate) {
    final buffer = StringBuffer();
    final speakText = command.spokenText;
    if (speakText != null) {
      buffer.writeln('engine.speak(${literalString(speakText)});');
    }
    final interfaceSoundReference = command.interfaceSound;
    if (interfaceSoundReference != null) {
      buffer
        ..writeln('engine.playInterfaceSound(')
        ..write(_soundReferenceCode(interfaceSoundReference))
        ..writeln(',')
        ..writeln(');');
    }
    if (command.hasHandler) {
      buffer.writeln('${eventType.name}(engine);');
    }
    return buffer.toString();
  });

  /// Write code for rooms and surfaces.
  Iterable<RoomCode> _writeRooms() sync* {
    final string = refer('String');
    final nonVirtualAnnotation = refer('nonVirtual', 'package:meta/meta.dart');
    const angstromPackage = 'package:angstrom/angstrom.dart';
    final angstromEngineRef = refer('AngstromEngine', angstromPackage);
    final engineParameter = Parameter((final p) {
      p
        ..name = 'engine'
        ..type = angstromEngineRef;
    });
    for (final room in rooms) {
      final roomClassName = room.editorRoom.name.pascalCase;
      final editorRoom = room.editorRoom;
      final soundReferenceRefer = refer('SoundReference', angstromPackage);
      final surfaceClasses = [
        for (final surface in editorRoom.surfaces)
          Class((final c) {
            final ambiance = surface.ambiance;
            c
              ..abstract = true
              ..name = '$roomClassName${surface.name.pascalCase}$base'
              ..docs.add('Events for ${surface.name}.'.asDocComment)
              ..methods.addAll([
                ...surface.eventCommands.entries.map(
                  (final entry) => Method((final m) {
                    final eventType = entry.key;
                    final command = entry.value;
                    m
                      ..name = eventType.name
                      ..docs.add(command.comment.asDocComment)
                      ..requiredParameters.add(engineParameter)
                      ..returns = refer('void')
                      ..body = _editorEventCommandCode(
                        eventType: eventType,
                        command: command,
                      );
                  }),
                ),
                Method((final m) {
                  m
                    ..name = 'id'
                    ..annotations.add(nonVirtualAnnotation)
                    ..docs.add('The ID of this surface.'.asDocComment)
                    ..body = Code('${literalString(surface.id)}')
                    ..lambda = true
                    ..returns = string
                    ..type = MethodType.getter;
                }),
                Method((final m) {
                  m
                    ..name = 'name'
                    ..annotations.add(nonVirtualAnnotation)
                    ..docs.add('The name of this surface.'.asDocComment)
                    ..body = Code('${literalString(surface.name)}')
                    ..lambda = true
                    ..returns = string
                    ..type = MethodType.getter;
                }),
                Method((final m) {
                  m
                    ..name = 'isWall'
                    ..annotations.add(nonVirtualAnnotation)
                    ..docs.add('Whether this surface is a wall.'.asDocComment)
                    ..body = Code('${literalBool(surface.isWall)}')
                    ..lambda = true
                    ..returns = refer('bool')
                    ..type = MethodType.getter;
                }),
                if (ambiance != null)
                  Method((final m) {
                    m
                      ..name = 'ambiance'
                      ..annotations.add(nonVirtualAnnotation)
                      ..docs.add(
                        'The sound which plays while on this surface.'
                            .asDocComment,
                      )
                      ..body = _soundReferenceCode(ambiance)
                      ..lambda = true
                      ..returns = soundReferenceRefer
                      ..type = MethodType.getter;
                  }),
              ])
              ..constructors.add(
                Constructor((final c) {
                  c
                    ..constant = true
                    ..docs.add('Create an instance.'.asDocComment);
                }),
              );
          }),
      ];
      final objectClasses = [
        for (final object in editorRoom.objects)
          Class((final c) {
            final ambiance = object.ambiance;
            c
              ..name = '${object.name.pascalCase}$base'
              ..abstract = true
              ..docs.add('Events for the ${object.name} object.'.asDocComment)
              ..constructors.add(
                Constructor((final c) {
                  c
                    ..constant = true
                    ..docs.add('Create an instance.'.asDocComment);
                }),
              )
              ..methods.addAll([
                Method((final m) {
                  m
                    ..annotations.add(nonVirtualAnnotation)
                    ..name = 'id'
                    ..docs.add('The ID of this object.'.asDocComment)
                    ..body = Code('${literalString(object.id)}')
                    ..type = MethodType.getter
                    ..lambda = true
                    ..returns = string;
                }),
                Method((final m) {
                  m
                    ..annotations.add(nonVirtualAnnotation)
                    ..name = 'name'
                    ..docs.add('The name of the object.'.asDocComment)
                    ..body = Code('${literalString(object.name)}')
                    ..lambda = true
                    ..returns = string
                    ..type = MethodType.getter;
                }),
                Method((final m) {
                  m
                    ..name = 'startCoordinates'
                    ..annotations.add(nonVirtualAnnotation)
                    ..docs.add(
                      'The point where this object will start out in the room.'
                          .asDocComment,
                    )
                    ..body = Code.scope((final allocate) {
                      final point = allocate(refer('Point', 'dart:math'));
                      return 'const $point(${object.x}, ${object.y})';
                    })
                    ..lambda = true
                    ..returns = TypeReference((final t) {
                      t
                        ..symbol = 'Point'
                        ..url = 'dart:math'
                        ..types.add(refer('int'));
                    })
                    ..type = MethodType.getter;
                }),
                Method((final m) {
                  m
                    ..name = 'ambianceMaxDistance'
                    ..annotations.add(nonVirtualAnnotation)
                    ..docs.add(
                      // ignore: lines_longer_than_80_chars
                      'The max distance at which the [ambiance] will play for this object.'
                          .asDocComment,
                    )
                    ..body = Code('${object.ambianceMaxDistance}')
                    ..lambda = true
                    ..returns = refer('int')
                    ..type = MethodType.getter;
                }),
                if (ambiance != null)
                  Method((final m) {
                    m
                      ..name = 'ambiance'
                      ..annotations.add(nonVirtualAnnotation)
                      ..docs.add('The ambiance for this object.'.asDocComment)
                      ..body = _soundReferenceCode(ambiance)
                      ..lambda = true
                      ..returns = soundReferenceRefer
                      ..type = MethodType.getter;
                  }),
              ]);
            for (final MapEntry(key: eventType, value: command)
                in object.eventCommands.entries) {
              c.methods.add(
                Method((final m) {
                  m
                    ..name = eventType.name
                    ..docs.add(command.comment.asDocComment)
                    ..returns = refer('void')
                    ..requiredParameters.add(engineParameter)
                    ..body = _editorEventCommandCode(
                      eventType: eventType,
                      command: command,
                    );
                }),
              );
            }
          }),
      ];
      final roomClass = Class(
        (final b) => b
          ..name = '$roomClassName$base'
          ..abstract = true
          ..docs.add(
            'Provides events for ${room.editorRoom.name}.'.asDocComment,
          )
          ..constructors.add(
            Constructor((final c) {
              c
                ..constant = true
                ..docs.add('Create an instance.'.asDocComment);
            }),
          )
          ..methods.addAll([
            for (var i = 0; i < surfaceClasses.length; i++)
              () {
                final surface = editorRoom.surfaces[i];
                final surfaceClass = surfaceClasses[i];
                return Method((final m) {
                  m
                    ..name = surface.name.camelCase
                    ..docs.add('${surface.name}.'.asDocComment)
                    ..returns = refer(surfaceClass.name)
                    ..type = MethodType.getter;
                });
              }(),
            for (var i = 0; i < objectClasses.length; i++)
              () {
                final object = editorRoom.objects[i];
                final objectClass = objectClasses[i];
                return Method((final m) {
                  m
                    ..name = object.name.camelCase
                    ..docs.add('${object.name}.'.asDocComment)
                    ..returns = refer(objectClass.name)
                    ..type = MethodType.getter;
                });
              }(),
            for (final MapEntry(key: eventType, value: command)
                in editorRoom.eventCommands.entries)
              Method((final m) {
                m
                  ..name = eventType.name
                  ..docs.add(command.comment.asDocComment)
                  ..requiredParameters.add(engineParameter)
                  ..returns = const Reference('void')
                  ..body = _editorEventCommandCode(
                    eventType: eventType,
                    command: command,
                  );
              }),
          ]),
      );
      final lib = Library((final lib) {
        lib
          ..body.add(roomClass)
          ..body.addAll(surfaceClasses)
          ..body.addAll(objectClasses);
      });
      final emitter = DartEmitter.scoped();
      final dart = lib.accept(emitter);
      if (!codeDirectory.existsSync()) {
        codeDirectory.createSync(recursive: true);
      }
      final dartFile = File(
        path.join(
          codeDirectory.path,
          '${path.basenameWithoutExtension(room.id)}.dart',
        ),
      );
      try {
        final code = formatter.format(dart.toString());
        dartFile.writeAsStringSync(code);
        yield RoomCode(
          room: room,
          roomClass: roomClass,
          surfaceClasses: surfaceClasses,
          objectClasses: objectClasses,
          filename: path.basename(dartFile.path),
        );
        // ignore: avoid_catches_without_on_clauses
      } catch (e, s) {
        final buffer = StringBuffer()
          ..writeln('/*')
          ..writeln(
            // ignore: lines_longer_than_80_chars
            'Failed to create code for the ${room.editorRoom.name} room (${room.id}):',
          );
        const lineSplitter = LineSplitter();
        lineSplitter.convert(e.toString()).forEach(buffer.writeln);
        lineSplitter.convert('$s').forEach(buffer.writeln);
        buffer.writeln('*/');
        dartFile.writeAsStringSync(buffer.toString());
      }
    }
  }

  /// Write room exports from [roomFiles].
  void _writeRoomExports(final Iterable<String> roomFiles) {
    final lib = Library((final lib) {
      lib.directives.addAll(roomFiles.map(Directive.export));
    });
    final emitter = DartEmitter.scoped();
    final source = lib.accept(emitter);
    final code = formatter.format(source.toString());
    File(
      path.join(codeDirectory.path, roomExportsFilename),
    ).writeAsStringSync(code);
  }

  /// Write the code for the custom engine.
  ///
  /// Returns `true` if the build succeeds.
  bool writeEngineCode() {
    const commandSuffix = 'Command';
    final string = refer('String');
    final roomCodeClasses = _writeRooms().toList();
    _writeRoomExports(
      roomCodeClasses.map((final roomCode) => roomCode.filename),
    );
    const angstromEditorPackage =
        'package:angstrom_editor/angstrom_editor.dart';
    final loadedRoomEvents = refer('LoadedRoomEvents', angstromEditorPackage);
    final roomEventsMap = TypeReference((final t) {
      t
        ..symbol = 'Map'
        ..types.addAll([string, loadedRoomEvents]);
    });
    final engineClassName = path
        .basenameWithoutExtension(engineCodePath)
        .pascalCase;
    final assetLoadingEngine = refer(
      'AssetLoadingAngstromEngine',
      angstromEditorPackage,
    );
    final dartFile = File(engineCodePath);
    try {
      final roomsWithEvents = roomCodeClasses
          .where((final roomCode) => roomCode.room.events.hasEvents)
          .toList();
      final engineClass = Class((final c) {
        c
          ..name = engineClassName
          ..docs.addAll([
            'The custom engine for your game.'.asDocComment,
            '///',
            // ignore: lines_longer_than_80_chars
            'This class will ensure that your custom callbacks can be loaded in a completely type safe manner.'
                .asDocComment,
          ])
          ..extend = assetLoadingEngine
          ..constructors.add(
            Constructor((final c) {
              c
                ..docs.add('Create an instance.'.asDocComment)
                ..optionalParameters.addAll([
                  ...['playerCharacter', 'assetBundle'].map(
                    (final name) => Parameter((final p) {
                      p
                        ..name = name
                        ..toSuper = true
                        ..required = true;
                    }),
                  ),
                  ...roomsWithEvents.map((final roomCode) {
                    final room = roomCode.room.editorRoom;
                    return Parameter((final p) {
                      p
                        ..name = room.name.camelCase
                        ..named = true
                        ..required = true
                        ..toThis = true;
                    });
                  }),
                ]);
            }),
          )
          ..fields.addAll(
            roomsWithEvents.map((final roomCode) {
              final room = roomCode.room.editorRoom;
              final roomClass = roomCode.roomClass;
              return Field((final f) {
                f
                  ..name = room.name.camelCase
                  ..docs.add(
                    'Events for ${room.name}. Used by [buildRoom].'
                        .asDocComment,
                  )
                  ..modifier = FieldModifier.final$
                  ..type = refer(
                    roomClass.name,
                    [
                      path.basename(codeDirectory.path),
                      roomExportsFilename,
                    ].join('/'),
                  );
              });
            }),
          )
          ..methods.add(
            Method((final m) {
              m
                ..annotations.add(refer('override'))
                ..name = 'roomEvents'
                ..docs.add(
                  'Provides the properties created by code gen.'.asDocComment,
                )
                ..returns = roomEventsMap
                ..lambda = true
                ..type = MethodType.getter
                ..body = Code.scope((final allocate) {
                  final buffer = StringBuffer()..writeln('{');
                  for (var i = 0; i < roomsWithEvents.length; i++) {
                    final roomCode = roomsWithEvents[i];
                    final room = roomCode.room;
                    final editorRoom = room.editorRoom;
                    final roomId = room.id.replaceAll(r'\', '/');
                    final roomClass = roomCode.roomClass;
                    final roomGetterName = roomClass.name.camelCase.substring(
                      0,
                      roomClass.name.length - base.length,
                    );
                    buffer
                      ..writeln('{editorRoom.name} events.'.asInlineComment)
                      ..writeln('${literalString(roomId)}:');
                    if (editorRoom.eventCommands.isEmpty) {
                      buffer.write('const ');
                    }
                    buffer
                      ..writeln('${allocate(loadedRoomEvents)}(')
                      ..writeln('surfaceEvents: {');
                    for (var j = 0; j < roomCode.surfaceClasses.length; j++) {
                      final surface = editorRoom.surfaces[j];
                      if (surface.eventCommands.isEmpty) {
                        continue;
                      }
                      buffer
                        ..writeln(
                          '${literalString(surface.id)}: // ${surface.name}',
                        )
                        ..writeln(
                          // ignore: lines_longer_than_80_chars
                          '${allocate(refer('EditorRoomSurfaceEvents', angstromEditorPackage))}(',
                        );
                      for (final event in surface.eventCommands.keys) {
                        buffer
                          ..write('${event.name}: ')
                          ..write(roomGetterName)
                          ..write('.')
                          ..writeln(surface.name.camelCase)
                          ..write('.')
                          ..write('${event.name}$commandSuffix');
                      }
                      buffer.writeln('),');
                    }
                    buffer
                      ..writeln('},')
                      ..writeln('objectEvents: {');
                    for (var j = 0; j < roomCode.objectClasses.length; j++) {
                      final object = editorRoom.objects[j];
                      if (object.eventCommands.isEmpty) {
                        continue;
                      }
                      buffer
                        ..writeln(
                          '${literalString(object.id)}: // ${object.name}',
                        )
                        ..writeln(
                          // ignore: lines_longer_than_80_chars
                          '${allocate(refer('EditorRoomObjectEvents', angstromEditorPackage))}(',
                        );
                      for (final event in object.eventCommands.keys) {
                        buffer
                          ..write('${event.name}: ')
                          ..write(roomGetterName)
                          ..write('.')
                          ..writeln(object.name.camelCase)
                          ..write('.')
                          ..write('${event.name}$commandSuffix');
                      }
                      buffer.writeln('),');
                    }
                    buffer.writeln('},');
                    for (final event in editorRoom.eventCommands.keys) {
                      final name = event.name;
                      buffer.writeln(
                        '$name: $roomGetterName.$name$commandSuffix,',
                      );
                    }
                    buffer.writeln('),');
                  }
                  buffer.writeln('}');
                  return buffer.toString();
                });
            }),
          );
      });
      final lib = Library((final lib) {
        lib.body.add(engineClass);
      });
      final emitter = DartEmitter.scoped();
      final dart = lib.accept(emitter);
      if (!dartFile.parent.existsSync()) {
        dartFile.parent.createSync(recursive: true);
      }
      final code = formatter.format(dart.toString());
      dartFile.writeAsStringSync(code);
      return true;
      // ignore: avoid_catches_without_on_clauses
    } catch (e, s) {
      final buffer = StringBuffer()
        ..writeln('/*')
        ..writeln(
          // ignore: lines_longer_than_80_chars
          'Failed to create code for the custom game engine:',
        );
      const lineSplitter = LineSplitter();
      lineSplitter.convert(e.toString()).forEach(buffer.writeln);
      lineSplitter.convert('$s').forEach(buffer.writeln);
      buffer.writeln('*/');
      dartFile.writeAsStringSync(buffer.toString());
      return false;
    }
  }
}
