import 'package:angstrom_editor/angstrom_editor.dart';
import 'package:code_builder/code_builder.dart';
import 'package:recase/recase.dart';

/// A class for generating room builder code.
class RoomCodeBuilder {
  /// Create an instance.
  RoomCodeBuilder._({
    required this.room,
    required this.roomClass,
    required this.roomBuilderClass,
    required this.surfaceClasses,
    required this.surfaceBuilderClasses,
    required this.objectClasses,
    required this.objectBuilderClasses,
  });

  /// Generate the code for [room].
  factory RoomCodeBuilder.generate(final LoadedRoom room) {
    final angstromCallback = refer(
      'AngstromCallback',
      'package:angstrom/angstrom.dart',
    );
    final editorRoom = room.editorRoom;
    final roomClassName = editorRoom.name.pascalCase;
    final classNamePrefix = '$builderClassNamePrefix$roomClassName';
    final surfaceClasses = <Class>[];
    final surfaceBuilderClasses = <Class>[];
    for (final surface in editorRoom.surfaces) {
      if (surface.events.isNotEmpty) {
        final surfaceClass = Class((final c) {
          c
            ..name = '$classNamePrefix${surface.name.pascalCase}Surface'
            ..docs.add('/// Events for the ${surface.name} surface.')
            ..constructors.add(
              Constructor((final c) {
                c
                  ..constant = true
                  ..docs.add('/// Create an instance.')
                  ..optionalParameters.addAll(
                    surface.events.map(
                      (final event) => Parameter((final p) {
                        p
                          ..name = event.name
                          ..named = true
                          ..required = true
                          ..toThis = true;
                      }),
                    ),
                  );
              }),
            )
            ..fields.addAll(
              surface.events.map(
                (final event) => Field((final f) {
                  f
                    ..name = event.name
                    ..docs.add('/// The `${event.name}` event.')
                    ..modifier = FieldModifier.final$
                    ..type = angstromCallback;
                }),
              ),
            );
        });
        surfaceClasses.add(surfaceClass);
        surfaceBuilderClasses.add(
          Class((final c) {
            c
              ..name = '${surfaceClass.name}Builder'
              ..constructors.add(
                Constructor((final c) {
                  c
                    ..constant = true
                    ..docs.add('/// Create an instance.');
                }),
              )
              ..methods.add(
                Method((final m) {
                  m
                    ..name = 'call'
                    ..body = Code.scope((final allocate) {
                      final buffer = StringBuffer()
                        ..writeln('return ${surfaceClass.name}(');
                      for (final field in surfaceClass.fields) {
                        buffer.writeln('${field.name}: ${field.name},');
                      }
                      buffer.writeln(');');
                      return buffer.toString();
                    })
                    ..optionalParameters.addAll(
                      surfaceClass.fields.map(
                        (final f) => Parameter((final p) {
                          p
                            ..name = f.name
                            ..docs.addAll(f.docs)
                            ..named = true
                            ..required = true
                            ..type = f.type;
                        }),
                      ),
                    )
                    ..returns = refer(surfaceClass.name);
                }),
              );
          }),
        );
      }
    }
    final objectClasses = <Class>[];
    final objectBuilderClasses = <Class>[];
    for (final object in editorRoom.objects) {
      final events = object.events.where(
        (final e) => e != AngstromEventTypes.onActivate || object.door == null,
      );
      if (events.isNotEmpty) {
        final objectClass = Class((final c) {
          c
            ..name = '$classNamePrefix${object.name.pascalCase}Object'
            ..docs.add('/// Events for the ${object.name} object.')
            ..constructors.add(
              Constructor((final c) {
                c
                  ..constant = true
                  ..docs.add('/// Create an instance.')
                  ..optionalParameters.addAll(
                    events.map(
                      (final event) => Parameter((final p) {
                        p
                          ..name = event.name
                          ..named = true
                          ..required = true
                          ..toThis = true;
                      }),
                    ),
                  );
              }),
            )
            ..fields.addAll(
              events.map(
                (final event) => Field((final f) {
                  f
                    ..name = event.name
                    ..docs.add('/// The `${event.name}` event.')
                    ..modifier = FieldModifier.final$
                    ..type = angstromCallback;
                }),
              ),
            );
        });
        objectClasses.add(objectClass);
        objectBuilderClasses.add(
          Class((final c) {
            c
              ..name = '${objectClass.name}Builder'
              ..constructors.add(
                Constructor((final c) {
                  c
                    ..constant = true
                    ..docs.add('/// Create an instance.');
                }),
              )
              ..methods.add(
                Method((final m) {
                  m
                    ..name = 'call'
                    ..body = Code.scope((final allocate) {
                      final buffer = StringBuffer()
                        ..writeln('return ${objectClass.name}(');
                      for (final field in objectClass.fields) {
                        buffer.writeln('${field.name}: ${field.name},');
                      }
                      buffer.writeln(');');
                      return buffer.toString();
                    })
                    ..optionalParameters.addAll(
                      objectClass.fields.map(
                        (final f) => Parameter((final p) {
                          p
                            ..name = f.name
                            ..docs.addAll(f.docs)
                            ..named = true
                            ..required = true
                            ..type = f.type;
                        }),
                      ),
                    )
                    ..returns = refer(objectClass.name);
                }),
              );
          }),
        );
      }
    }
    final roomClass = Class((final c) {
      c
        ..name = classNamePrefix
        ..docs.addAll([
          '/// Holds metadata about the',
          '/// ${editorRoom.name} room.',
        ])
        ..constructors.add(
          Constructor((final c) {
            c
              ..constant = true
              ..docs.add('/// Create an instance.')
              ..optionalParameters.addAll(
                [...surfaceClasses, ...objectClasses].map(
                  (final c) => Parameter((final p) {
                    final friendlyName = c.name
                        .substring(classNamePrefix.length)
                        .camelCase;
                    p
                      ..name = friendlyName
                      ..named = true
                      ..required = true
                      ..toThis = true;
                  }),
                ),
              );
          }),
        )
        ..fields.addAll(
          [...surfaceClasses, ...objectClasses].map(
            (final c) => Field((final f) {
              final friendlyName = c.name
                  .substring(classNamePrefix.length)
                  .camelCase;
              f
                ..name = friendlyName
                ..docs.add('/// Metadata about a surface or object.')
                ..modifier = FieldModifier.final$
                ..type = refer(c.name);
            }),
          ),
        );
    });
    final roomBuilderClass = Class((final c) {
      c
        ..name = '${classNamePrefix}RoomBuilder'
        ..constructors.add(
          Constructor((final c) {
            c
              ..constant = true
              ..docs.add('/// Create an instance.');
          }),
        )
        ..methods.add(
          Method((final m) {
            m
              ..name = 'call'
              ..body = Code.scope((final allocate) {
                final buffer = StringBuffer()
                  ..writeln('return $classNamePrefix(');
                for (final field in roomClass.fields) {
                  buffer.writeln('${field.name}: ${field.name},');
                }
                buffer.writeln(');');
                return buffer.toString();
              })
              ..optionalParameters.addAll(
                [...surfaceClasses, ...objectClasses].map(
                  (final c) => Parameter((final p) {
                    final friendlyName = c.name
                        .substring(classNamePrefix.length)
                        .camelCase;
                    final classRefer = refer(c.name);
                    final builderRefer = refer('${c.name}Builder');
                    p
                      ..name = friendlyName
                      ..named = true
                      ..required = true
                      ..type = FunctionType((final f) {
                        f
                          ..returnType = classRefer
                          ..requiredParameters.add(builderRefer);
                      });
                  }),
                ),
              );
          }),
        );
    });
    return RoomCodeBuilder._(
      room: room,
      roomClass: roomClass,
      roomBuilderClass: roomBuilderClass,
      surfaceClasses: surfaceClasses,
      surfaceBuilderClasses: surfaceBuilderClasses,
      objectClasses: objectClasses,
      objectBuilderClasses: objectBuilderClasses,
    );
  }

  /// The prefix for all builder class names.
  static const builderClassNamePrefix = r'_$';

  /// The room to use.
  final LoadedRoom room;

  /// The [room] class.
  final Class roomClass;

  /// The [room] builder class.
  final Class roomBuilderClass;

  /// The name of parameters and fields of type [roomClass].
  String get roomBuilderParameterName =>
      roomBuilderClass.name.substring(builderClassNamePrefix.length).camelCase;

  /// The data classes for all [room] surfaces.
  final List<Class> surfaceClasses;

  /// The classes for all [room] surfaces surface builders.
  final List<Class> surfaceBuilderClasses;

  /// The data classes for all [room] classes.
  final List<Class> objectClasses;

  /// The classes for all [room] object builders.
  final List<Class> objectBuilderClasses;

  /// Get all the classes in this builder.
  Iterable<Class> get classes => [
    roomClass,
    roomBuilderClass,
    ...surfaceClasses,
    ...surfaceBuilderClasses,
    ...objectClasses,
    ...objectBuilderClasses,
  ];
}
