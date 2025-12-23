import 'dart:convert';

import 'package:angstrom/angstrom.dart';
import 'package:angstrom_editor/angstrom_editor.dart';
import 'package:backstreets_widgets/screens.dart';
import 'package:flutter/material.dart';

/// Provide the [engine] and [editorContext] to anyone who wants it.
class EditorContextProvider extends InheritedWidget {
  /// Create an instance.
  const EditorContextProvider({
    required this.engine,
    required this.editorContext,
    required super.child,
    super.key,
  });

  /// The engine to use.
  final EditorEngine engine;

  /// The editor context to use.
  final EditorContext editorContext;

  /// Ensure the [engine] and [editorContext] match.
  @override
  bool updateShouldNotify(final EditorContextProvider oldWidget) =>
      oldWidget.engine != engine ||
      oldWidget.editorContext != editorContext ||
      jsonEncode(oldWidget.editorContext.room.editorRoom) !=
          jsonEncode(editorContext.room.editorRoom);
}

/// A widget which wraps an [engine], and a [editorContext].
class EditorContextScope extends StatelessWidget {
  /// Create an instance.
  const EditorContextScope({
    required this.engine,
    required this.editorContext,
    required this.child,
    super.key,
  });

  /// Return the nearest [EditorContextProvider] or `null`.
  static EditorContextProvider? maybeOf(final BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<EditorContextProvider>();

  /// Ensure the nearest [EditorContextProvider] exists.
  static EditorContextProvider of(final BuildContext context) {
    final widget = maybeOf(context);
    if (widget == null) {
      throw StateError('No `EditorContextProvider` was found for $context.');
    }
    return widget;
  }

  /// The engine to use.
  final EditorEngine engine;

  /// The editor context to use.
  final EditorContext editorContext;

  /// The widget below this widget in the tree.
  final Widget child;

  /// Build the widget.
  @override
  Widget build(final BuildContext context) => EditorContextProvider(
    engine: engine,
    editorContext: editorContext,
    child: AngstromEventHandler(
      engine: engine,
      wallAttenuation: editorContext.wallAttenuation,
      wallFactor: editorContext.wallFactor,
      onExamineObject: editorContext.onExamineObject,
      onNoRoomObjects: editorContext.onNoRoomObjects,
      getSound: editorContext.getSound,
      error: ErrorScreen.withPositional,
      child: EngineTicker(engine: engine, child: child),
    ),
  );
}
