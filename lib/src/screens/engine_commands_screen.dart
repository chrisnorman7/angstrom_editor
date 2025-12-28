import 'dart:io';

import 'package:angstrom_editor/angstrom_editor.dart';
import 'package:backstreets_widgets/extensions.dart';
import 'package:backstreets_widgets/screens.dart';
import 'package:backstreets_widgets/shortcuts.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';

/// A screen for editing [engineCommands].
class EngineCommandsScreen extends StatefulWidget {
  /// Create an instance.
  const EngineCommandsScreen({
    required this.roomsDirectory,
    required this.engineCommands,
    required this.newId,
    required this.saveEngineCommands,
    super.key,
  });

  /// The directory where rooms reside.
  final Directory roomsDirectory;

  /// The engine commands to use.
  final List<EngineCommand> engineCommands;

  /// A function to call to get a new ID.
  final String Function() newId;

  /// The function to call to save the [engineCommands].
  final VoidCallback saveEngineCommands;

  /// Create state for this widget.
  @override
  EngineCommandsScreenState createState() => EngineCommandsScreenState();
}

/// State for [EngineCommandsScreen].
class EngineCommandsScreenState extends State<EngineCommandsScreen> {
  /// The engine commands to use.
  List<EngineCommand> get engineCommands => widget.engineCommands;

  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final Widget child;
    if (engineCommands.isEmpty) {
      child = const CenterText(
        text: 'No commands have been created.',
        autofocus: true,
      );
    } else {
      child = ListView.builder(
        itemBuilder: (final context, final index) {
          final command = engineCommands[index];
          return PerformableActionsListTile(
            autofocus: index == 0,
            actions: [
              PerformableAction(
                name: 'Rename',
                activator: renameShortcut,
                invoke: () => context.pushWidgetBuilder(
                  (_) => GetText(
                    onDone: (final value) {
                      Navigator.pop(context);
                      command.name = value;
                      save();
                    },
                    labelText: 'Name',
                    text: command.name,
                    title: 'Rename Command',
                  ),
                ),
              ),
              PerformableAction(
                name: 'delete',
                activator: deleteShortcut,
                invoke: () async {
                  for (final room in widget.roomsDirectory.rooms) {
                    final editorRoom = room.editorRoom;
                    for (final MapEntry(key: eventType, value: eventCommand)
                        in editorRoom.eventCommands.entries) {
                      if (eventCommand.engineCommandId == command.id) {
                        return context.showMessage(
                          message:
                              // ignore: lines_longer_than_80_chars
                              'This command is used by ${eventType.name} on the room ${editorRoom.name}.',
                        );
                      }
                    }
                    for (final surface in editorRoom.surfaces) {
                      for (final MapEntry(key: eventType, value: eventCommand)
                          in surface.eventCommands.entries) {
                        if (eventCommand.engineCommandId == command.id) {
                          return context.showMessage(
                            message:
                                // ignore: lines_longer_than_80_chars
                                'This command is used by ${eventType.name} on the surface ${surface.name} in the room ${editorRoom.name}.',
                          );
                        }
                      }
                    }
                    for (final object in editorRoom.objects) {
                      for (final MapEntry(key: eventType, value: eventCommand)
                          in object.eventCommands.entries) {
                        if (eventCommand.engineCommandId == command.id) {
                          return context.showMessage(
                            message:
                                // ignore: lines_longer_than_80_chars
                                'This command is used by ${eventType.name} on the object ${object.name} in the room ${editorRoom.name}.',
                          );
                        }
                      }
                    }
                  }
                  engineCommands.removeWhere(
                    (final engineCommand) => engineCommand.id == command.id,
                  );
                  save();
                },
              ),
            ],
            title: Text(command.name),
            subtitle: Text(command.comment),
            onTap: () => context.pushWidgetBuilder(
              (_) => EditCommentScreen(
                onChange: (final value) {
                  command.comment = value ?? command.comment;
                  save();
                },
                comment: command.comment,
                title: 'Command Comment',
              ),
            ),
          );
        },
        itemCount: engineCommands.length,
        shrinkWrap: true,
      );
    }
    return CommonShortcuts(
      newCallback: _newCommand,
      child: Cancel(
        child: SimpleScaffold(
          title: 'Engine Commands',
          body: child,
          floatingActionButton: NewButton(
            onPressed: _newCommand,
            tooltip: 'New command',
          ),
        ),
      ),
    );
  }

  /// Save the [engineCommands].
  void save() {
    widget.saveEngineCommands();
    setState(() {});
  }

  /// Create a new command.
  void _newCommand() {
    int? i;
    String name;
    do {
      name = 'untitledCommand${i ?? ""}';
      if (i == null) {
        i = 2;
      } else {
        i++;
      }
    } while (engineCommands
        .where((final command) => command.name == name)
        .isNotEmpty);
    engineCommands.add(
      EngineCommand(
        id: widget.newId(),
        name: name,
        comment: 'A command which must be coded.',
      ),
    );
    save();
  }
}
