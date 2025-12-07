import 'package:angstrom/typedefs.dart';
import 'package:angstrom_editor/angstrom_editor.dart' show EditorRoomObject;
import 'package:angstrom_editor/src/json/editor_room_object.dart';

/// Events for [EditorRoomObject]s.
class EditorRoomObjectEvents {
  /// Create an instance.
  const EditorRoomObjectEvents({
    this.onApproach,
    this.onActivate,
    this.onLeave,
  });

  /// The `onApproach` event.
  final AngstromCallback? onApproach;

  /// The `onActivate` method.
  final AngstromCallback? onActivate;

  /// The `onLeave` method.
  final AngstromCallback? onLeave;
}
