import 'package:angstrom_editor/angstrom_editor.dart';
import 'package:code_builder/code_builder.dart';
import 'package:recase/recase.dart';

/// A class for generating room builder code.
class RoomCodeBuilder {
  /// Create an instance.
  RoomCodeBuilder({
    required this.room,
    required this.roomBuilderClass,
    required this.surfaceBuilderClasses,
    required this.objectBuilderClasses,
  });

  /// Build the code for [room].
  factory RoomCodeBuilder.build(final LoadedRoom room) {
    final angstromCallback = refer(
      'AngstromCallback',
      'package:angstrom/angstrom.dart',
    );
    final editorRoom = room.editorRoom;
    final roomClassName = editorRoom.name.pascalCase;
    final classNamePrefix = '$builderClassNamePrefix$roomClassName';
    final surfaceBuilderClasses = [
      for (var i = 0; i < editorRoom.surfaces.length; i++)
        if (editorRoom.surfaces[i].events.isNotEmpty)
          Class((final c) {
            final surface = editorRoom.surfaces[i];
            c
              ..name = '$classNamePrefix${surface.name.pascalCase}Surface'
              ..docs.add(
                '/// The events for the ${surface.name} surface of the ${editorRoom.name} room.',
              )
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
                      ..docs.add('/// The ${event.name} event.')
                      ..modifier = FieldModifier.final$
                      ..type = angstromCallback;
                  }),
                ),
              );
          }),
    ];
    final objectBuilderClasses = [
      for (var i = 0; i < editorRoom.objects.length; i++)
        if (editorRoom.objects[i].events
            .where(
              (final e) =>
                  e != AngstromEventTypes.onActivate ||
                  editorRoom.objects[i].door == null,
            )
            .isNotEmpty)
          Class((final c) {
            final object = editorRoom.objects[i];
            final door = object.door;
            final events = object.events.where(
              (final e) => e != AngstromEventTypes.onActivate || door == null,
            );
            c
              ..name = '$classNamePrefix${object.name.pascalCase}Object'
              ..docs.add(
                '/// Events for the ${object.name} object in the ${editorRoom.name} room.',
              )
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
                      ..docs.add('/// The ${event.name} event.')
                      ..modifier = FieldModifier.final$
                      ..type = angstromCallback;
                  }),
                ),
              );
          }),
    ];
    final roomBuilderClass = Class((final c) {
      c
        ..name = '${classNamePrefix}RoomBuilder'
        ..docs.addAll([
          '/// A class which will build object and surface events for the',
          '/// ${editorRoom.name} room.',
        ])
        ..constructors.add(
          Constructor((final c) {
            c
              ..constant = true
              ..docs.add('/// Create an instance.')
              ..optionalParameters.addAll(
                [...surfaceBuilderClasses, ...objectBuilderClasses].map(
                  (final builderClass) => Parameter((final p) {
                    p
                      ..name = builderClass.name
                          .substring(builderClassNamePrefix.length)
                          .camelCase
                      ..named = true
                      ..required = true
                      ..toThis = true;
                  }),
                ),
              );
          }),
        )
        ..fields.addAll(
          [...surfaceBuilderClasses, ...objectBuilderClasses].map(
            (final builderClass) => Field((final f) {
              f
                ..name = builderClass.name
                    .substring(builderClassNamePrefix.length)
                    .camelCase
                ..docs.add('/// Contains events for a surface or object.')
                ..modifier = FieldModifier.final$
                ..type = refer(builderClass.name);
            }),
          ),
        );
    });
    return RoomCodeBuilder(
      room: room,
      roomBuilderClass: roomBuilderClass,
      surfaceBuilderClasses: surfaceBuilderClasses,
      objectBuilderClasses: objectBuilderClasses,
    );
  }

  /// The prefix for all builder class names.
  static const builderClassNamePrefix = r'_$';

  /// The room to use.
  final LoadedRoom room;

  /// The [room] builder class.
  final Class roomBuilderClass;

  /// The type of [roomBuilderClass].
  Reference get _roomBuilderType => refer(roomBuilderClass.name);

  /// The name of parameters and fields of type [roomBuilderClass].
  String get roomBuilderParameterName =>
      roomBuilderClass.name.substring(builderClassNamePrefix.length).camelCase;

  /// The type of the [roomBuilderClass] builder.
  FunctionType get builderType => FunctionType((final f) {
    f
      ..requiredParameters.add(_roomBuilderType)
      ..returnType = _roomBuilderType;
  });

  /// The classes for all [room] surface builders.
  final List<Class> surfaceBuilderClasses;

  /// The classes for all [room] object builders.
  final List<Class> objectBuilderClasses;
}
