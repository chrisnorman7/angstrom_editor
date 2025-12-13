import 'package:angstrom_editor/angstrom_editor.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';

/// A class which builds a list of performable [actions] from a [map] of
/// [events] and [EditorEventCommand]s.
class EventCommandsPerformableActions {
  /// Create an instance.
  const EventCommandsPerformableActions({
    required this.events,
    required this.map,
    required this.save,
  });

  /// The events which will be looked for in [map].
  final Iterable<AngstromEventType> events;

  /// The map of events and commands.
  final EventsMap map;

  /// The function to call when [map] changes.
  final VoidCallback save;

  /// The actions for this map.
  Iterable<PerformableAction> get actions sync* {
    for (final event in events) {
      final command = map[event];
      if (command == null) {
        yield PerformableAction(
          name: 'Add ${event.name}',
          invoke: () {
            map[event] = EditorEventCommand(
              comment: 'The ${event.name} event.',
            );
            save();
          },
        );
      } else {
        yield PerformableAction(
          name: 'Edit ${event.name} (${command.comment})',
        );
        yield PerformableAction(
          name: 'Delete ${event.name}',
          invoke: () {
            map.remove(event);
            save();
          },
        );
      }
    }
  }
}
