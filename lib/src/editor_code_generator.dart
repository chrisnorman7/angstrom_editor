import 'dart:convert';
import 'dart:io';

import 'package:angstrom_editor/angstrom_editor.dart';
import 'package:angstrom_editor/src/room_code_builder.dart';
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

  /// Write code for rooms and surfaces.
  Iterable<RoomCode> _writeRooms() sync* {
    final angstromEngineRef = refer(
      'AngstromEngine',
      'package:angstrom/angstrom.dart',
    );
    final engineParameter = Parameter((final p) {
      p
        ..name = 'engine'
        ..type = angstromEngineRef;
    });
    for (final room in rooms) {
      final roomClassName = room.editorRoom.name.pascalCase;
      final editorRoom = room.editorRoom;
      final surfaceClasses = [
        for (final surface in editorRoom.surfaces)
          Class(
            (final c) => c
              ..abstract = true
              ..name = '$roomClassName${surface.name.pascalCase}$base'
              ..docs.add('/// Events for ${surface.name}.')
              ..methods.addAll(
                surface.events.map(
                  (final eventType) => Method(
                    (final m) => m
                      ..name = eventType.name
                      ..docs.add('/// The ${eventType.name} event.')
                      ..requiredParameters.add(engineParameter)
                      ..returns = refer('void'),
                  ),
                ),
              )
              ..constructors.add(
                Constructor((final c) {
                  c
                    ..constant = true
                    ..docs.add('/// Create an instance.');
                }),
              ),
          ),
      ];
      final objectClasses = [
        for (final object in editorRoom.objects)
          Class((final c) {
            final door = object.door;
            c
              ..name = '${object.name.pascalCase}$base'
              ..abstract = true
              ..docs.add('/// Events for the ${object.name} object.')
              ..constructors.add(
                Constructor((final c) {
                  c
                    ..constant = true
                    ..docs.add('/// Create an instance.');
                }),
              );
            for (final event in object.events) {
              if (event != AngstromEventTypes.onActivate || door == null) {
                c.methods.add(
                  Method((final m) {
                    m
                      ..name = event.name
                      ..docs.add('/// The ${event.name} event.')
                      ..returns = refer('void')
                      ..requiredParameters.add(engineParameter);
                  }),
                );
              }
            }
          }),
      ];
      final roomClass = Class(
        (final b) => b
          ..name = '$roomClassName$base'
          ..abstract = true
          ..docs.add('/// Provides events for ${room.editorRoom.name}.')
          ..constructors.add(
            Constructor((final c) {
              c
                ..constant = true
                ..docs.add('/// Create an instance.');
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
                    ..docs.add('/// ${surface.name}.')
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
                    ..docs.add('/// ${object.name}.')
                    ..returns = refer(objectClass.name)
                    ..type = MethodType.getter;
                });
              }(),
          ])
          ..methods.addAll(
            ['onEnter', 'onLeave'].map(
              (final name) => Method((final m) {
                m
                  ..name = name
                  ..body = const Code('')
                  ..docs.add('/// The `Room.$name` event.')
                  ..returns = const Reference('void')
                  ..requiredParameters.add(engineParameter);
              }),
            ),
          ),
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
  void writeEngineCode() {
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
        ..types.addAll([refer('String'), loadedRoomEvents]);
    });
    final engineClassName = path
        .basenameWithoutExtension(engineCodePath)
        .pascalCase;
    final assetLoadingEngine = refer(
      'AssetLoadingAngstromEngine',
      angstromEditorPackage,
    );
    final engineClass = Class((final c) {
      c
        ..name = engineClassName
        ..docs.addAll([
          '/// The custom engine for your game.',
          '///',
          '/// This class will ensure that your custom callbacks can be loaded in a',
          '/// completely type safe manner.',
        ])
        ..extend = assetLoadingEngine
        ..constructors.add(
          Constructor((final c) {
            c
              ..docs.add('/// Create an instance.')
              ..optionalParameters.addAll([
                ...['playerCharacter', 'assetBundle'].map(
                  (final name) => Parameter((final p) {
                    p
                      ..name = name
                      ..toSuper = true
                      ..required = true;
                  }),
                ),
                ...roomCodeClasses.map((final roomCode) {
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
          roomCodeClasses.map((final roomCode) {
            final room = roomCode.room.editorRoom;
            final roomClass = roomCode.roomClass;
            return Field((final f) {
              f
                ..name = room.name.camelCase
                ..docs.add('/// Events for ${room.name}. Used by [buildRoom].')
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
              ..docs.add('/// Provides the properties created by code gen.')
              ..returns = roomEventsMap
              ..type = MethodType.getter
              ..body = Code.scope((final allocate) {
                final buffer = StringBuffer()..writeln('return {');
                for (var i = 0; i < rooms.length; i++) {
                  final roomCode = roomCodeClasses[i];
                  final room = roomCode.room;
                  final editorRoom = room.editorRoom;
                  final roomId = room.id.replaceAll(r'\', '/');
                  final roomClass = roomCode.roomClass;
                  final roomGetterName = roomClass.name.camelCase.substring(
                    0,
                    roomClass.name.length - base.length,
                  );
                  buffer
                    ..writeln('${literalString(roomId)}: // ${editorRoom.name}')
                    ..writeln('${allocate(loadedRoomEvents)}(')
                    ..writeln('surfaceEvents: {');
                  for (var j = 0; j < roomCode.surfaceClasses.length; j++) {
                    final surface = editorRoom.surfaces[j];
                    if (surface.events.isEmpty) {
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
                    for (final event in surface.events) {
                      buffer
                        ..write('${event.name}: ')
                        ..write(roomGetterName)
                        ..write('.')
                        ..writeln(surface.name.camelCase)
                        ..write('.')
                        ..write(event.name);
                    }
                    buffer.writeln('),');
                  }
                  buffer
                    ..writeln('},')
                    ..writeln('objectEvents: {');
                  for (var j = 0; j < roomCode.objectClasses.length; j++) {
                    final object = editorRoom.objects[j];
                    final events = object.events.where(
                      (final e) =>
                          e != AngstromEventTypes.onActivate ||
                          object.door == null,
                    );
                    if (events.isEmpty) {
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
                    for (final event in events) {
                      buffer
                        ..write('${event.name}: ')
                        ..write(roomGetterName)
                        ..write('.')
                        ..writeln(object.name.camelCase)
                        ..write('.')
                        ..write(event.name);
                    }
                    buffer.writeln('),');
                  }
                  buffer.writeln('},');
                  for (final name in ['onEnter', 'onLeave']) {
                    buffer.writeln('$name: $roomGetterName.$name,');
                  }
                  buffer.writeln('),');
                }
                buffer.writeln('};');
                return buffer.toString();
              });
          }),
        );
    });
    final roomBuilders = roomCodeClasses.map(
      (final roomCode) => RoomCodeBuilder.generate(roomCode.room),
    );
    final engineBuilderClass = Class((final c) {
      c
        ..name = '${engineClassName}Builder'
        ..docs.addAll([
          '/// Build an engine for your game.',
          '///',
          '/// This class will ensure that your custom callbacks can be loaded in a',
          '/// completely type safe manner.',
        ])
        ..extend = assetLoadingEngine
        ..constructors.add(
          Constructor((final c) {
            c
              ..docs.add('/// Create an instance.')
              ..optionalParameters.addAll(
                roomBuilders.map(
                  (final builder) => Parameter((final p) {
                    final roomBuilderClass = builder.roomBuilderClass;
                    final roomClass = builder.roomClass;
                    final classRefer = refer(roomClass.name);
                    final builderRefer = refer(roomBuilderClass.name);
                    final builderType = FunctionType((final f) {
                      f
                        ..returnType = classRefer
                        ..requiredParameters.add(builderRefer);
                    });
                    p
                      ..name = roomClass.name
                          .substring(
                            RoomCodeBuilder.builderClassNamePrefix.length,
                          )
                          .camelCase
                      ..docs.addAll([
                        '/// Build metadata for the',
                        '/// ${builder.room.editorRoom.name} room.',
                      ])
                      ..type = FunctionType((final f) {
                        f
                          ..returnType = classRefer
                          ..requiredParameters.add(builderType);
                      });
                  }),
                ),
              );
          }),
        )
        ..fields.addAll([
          Field((final m) {
            m
              ..name = '_roomEvents'
              ..modifier = FieldModifier.final$
              ..type = roomEventsMap;
          }),
        ])
        ..methods.add(
          Method((final m) {
            m
              ..annotations.add(refer('override'))
              ..name = 'roomEvents'
              ..docs.add('/// The events which the engine knows about.')
              ..body = const Code('return _roomEvents;')
              ..returns = roomEventsMap
              ..type = MethodType.getter;
          }),
        );
    });
    final lib = Library((final lib) {
      lib.body.addAll([
        engineClass,
        for (final roomBuilder in roomBuilders) ...roomBuilder.classes,
        engineBuilderClass,
      ]);
    });
    final emitter = DartEmitter.scoped();
    final dart = lib.accept(emitter);
    final dartFile = File(engineCodePath);
    if (!dartFile.parent.existsSync()) {
      dartFile.parent.createSync(recursive: true);
    }
    try {
      final code = formatter.format(dart.toString());
      dartFile.writeAsStringSync(code);
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
    }
  }
}
