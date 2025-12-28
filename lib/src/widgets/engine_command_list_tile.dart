import 'package:angstrom_editor/angstrom_editor.dart';
import 'package:backstreets_widgets/extensions.dart';
import 'package:backstreets_widgets/shortcuts.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';

/// A [ListTile] which allows selecting from [engineCommands].
class EngineCommandListTile extends StatelessWidget {
  /// Create an instance.
  const EngineCommandListTile({
    required this.engineCommands,
    required this.onChange,
    this.engineCommandId,
    this.title = 'Engine command',
    this.notSetText = '<Not Set>',
    this.autofocus = false,
    super.key,
  });

  /// The engine commands to choose from.
  final List<EngineCommand> engineCommands;

  /// The function to call when an engine command is selected.
  final ValueChanged<EngineCommand?> onChange;

  /// The ID of the current engine command.
  final String? engineCommandId;

  /// The title of the [ListTile].
  final String title;

  /// The [String] to show when [engineCommandId] is `null`.
  final String notSetText;

  /// Whether the [ListTile] should be autofocused.
  final bool autofocus;

  /// Build the widget.
  @override
  Widget build(final BuildContext context) {
    final id = engineCommandId;
    if (id == null) {
      return ListTile(
        autofocus: autofocus,
        title: Text(title),
        subtitle: Text(notSetText),
        onTap: () => context.pushWidgetBuilder(
          (_) => SelectEngineCommandScreen(
            engineCommands: engineCommands,
            onChange: onChange,
          ),
        ),
      );
    }
    final command = engineCommands.firstWhere(
      (final c) => c.id == id,
      orElse: () => engineCommands.first,
    );
    return PerformableActionsListTile(
      actions: [
        PerformableAction(
          name: 'Clear',
          activator: deleteShortcut,
          invoke: () => onChange(null),
        ),
      ],
      autofocus: autofocus,
      title: Text(title),
      subtitle: Text(command.name),
      onTap: () => context.pushWidgetBuilder(
        (_) => SelectEngineCommandScreen(
          engineCommands: engineCommands,
          onChange: onChange,
          engineCommandId: id,
        ),
      ),
    );
  }
}
