import 'package:angstrom/angstrom.dart';
import 'package:angstrom_editor/angstrom_editor.dart';
import 'package:backstreets_widgets/screens.dart';
import 'package:flutter/material.dart';

/// A widget which wraps an [engine], and a [editorContext].
class EditorContextWrapper extends StatelessWidget {
  /// Create an instance.
  const EditorContextWrapper({
    required this.engine,
    required this.editorContext,
    required this.child,
    super.key,
  });

  /// The engine to use.
  final EditorEngine engine;

  /// The editor context to use.
  final EditorContext editorContext;

  /// The widget below this widget in the tree.
  final Widget child;

  /// Build the widget.
  @override
  Widget build(final BuildContext context) => AngstromEventHandler(
    engine: engine,
    wallAttenuation: editorContext.wallAttenuation,
    wallFactor: editorContext.wallFactor,
    onExamineObject: editorContext.onExamineObject,
    onNoRoomObjects: editorContext.onNoRoomObjects,
    error: ErrorScreen.withPositional,
    child: EngineTicker(engine: engine, child: child),
  );
}
