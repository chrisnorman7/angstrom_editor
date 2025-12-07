import 'package:angstrom_editor/angstrom_editor.dart';
import 'package:code_builder/code_builder.dart';

/// A class which holds code for a [room].
class RoomCode {
  /// Create an instance.
  const RoomCode({
    required this.room,
    required this.roomClass,
    required this.surfaceClasses,
    required this.objectClasses,
    required this.filename,
  });

  /// The room which has been codified.
  final LoadedRoom room;

  /// The class which has been generated.
  final Class roomClass;

  /// The surface classes which have been generated.
  final List<Class> surfaceClasses;

  /// The object classes which have been generated.
  final List<Class> objectClasses;

  /// The file where [roomClass] has been written.
  final String filename;
}
