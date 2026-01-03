import 'package:angstrom_editor/angstrom_editor.dart';
import 'package:backstreets_widgets/extensions.dart';
import 'package:backstreets_widgets/shortcuts.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';

/// A page to show a list of [eventTypes] and their associated [commands].
class EventCommandsPage extends StatefulWidget {
  /// Create an instance.
  const EventCommandsPage({
    required this.editorContext,
    required this.eventTypes,
    required this.commands,
    required this.onChange,
    super.key,
  });

  /// The editor context to use.
  final EditorContext editorContext;

  /// The supported event types.
  final List<AngstromEventType> eventTypes;

  /// The commands map to work with.
  final EventsMap commands;

  /// The function to call when [commands] have changed.
  final VoidCallback onChange;

  /// Create state for this widget.
  @override
  EventCommandsPageState createState() => EventCommandsPageState();
}

/// State for [EventCommandsPage].
class EventCommandsPageState extends State<EventCommandsPage> {
  /// The type of event which was last touched.
  AngstromEventType? _lastEventType;

  /// Build a widget.
  @override
  Widget build(final BuildContext context) => ListView.builder(
    itemBuilder: (final context, final index) {
      final eventType = widget.eventTypes[index];
      final autofocus = _lastEventType == null
          ? index == 0
          : eventType == _lastEventType;
      final command = widget.commands[eventType];
      if (command == null) {
        return ListTile(
          autofocus: autofocus,
          title: Text(eventType.name),
          onTap: () {
            _lastEventType = eventType;
            final editorEventCommand = EditorEventCommand(
              comment: 'The ${eventType.name} event.',
            );
            widget.commands[eventType] = editorEventCommand;
            widget.onChange();
            setState(() {});
            context.pushWidgetBuilder(
              (_) => EditEditorEventCommandScreen(
                editorContext: widget.editorContext,
                command: editorEventCommand,
                onChange: widget.onChange,
              ),
            );
          },
        );
      }
      return PerformableActionsListTile(
        autofocus: autofocus,
        actions: [
          PerformableAction(
            name: 'Delete',
            activator: deleteShortcut,
            invoke: () {
              widget.commands.remove(eventType);
              widget.onChange();
              setState(() {});
            },
          ),
        ],
        title: Text(eventType.name),
        subtitle: Text(command.comment),
        onTap: () => context.pushWidgetBuilder(
          (_) => EditEditorEventCommandScreen(
            editorContext: widget.editorContext,
            command: command,
            onChange: () {
              _lastEventType = eventType;
              widget.onChange();
              setState(() {});
            },
          ),
        ),
      );
    },
    itemCount: widget.eventTypes.length,
    shrinkWrap: true,
  );
}
