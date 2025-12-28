import 'package:angstrom_editor/angstrom_editor.dart';
import 'package:backstreets_widgets/screens.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';

/// A screen for selecting from [engineCommands].
class SelectEngineCommandScreen extends StatelessWidget {
  /// Create an instance.
  const SelectEngineCommandScreen({
    required this.engineCommands,
    required this.onChange,
    this.engineCommandId,
    super.key,
  });

  /// The engine commands to choose from.
  final List<EngineCommand> engineCommands;

  /// The function to call to set the new engine command.
  final ValueChanged<EngineCommand> onChange;

  /// The ID of the current engine command.
  final String? engineCommandId;

  /// Build the widget.
  @override
  Widget build(final BuildContext context) => Cancel(
    child: SimpleScaffold(
      title: 'Select Engine Command',
      body: ListView.builder(
        itemBuilder: (final context, final index) {
          final command = engineCommands[index];
          return ListTile(
            autofocus: engineCommandId == null
                ? index == 0
                : command.id == engineCommandId,
            title: Text(command.name),
            subtitle: Text(command.comment),
            onTap: () {
              Navigator.pop(context);
              onChange(command);
            },
          );
        },
        itemCount: engineCommands.length,
        shrinkWrap: true,
      ),
    ),
  );
}
