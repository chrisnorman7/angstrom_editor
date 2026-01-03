import 'package:backstreets_widgets/extensions.dart';
import 'package:backstreets_widgets/screens.dart';
import 'package:backstreets_widgets/shortcuts.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';

/// A [ListTile] to edit [duration].
class CustomDurationListTile extends StatelessWidget {
  /// Create an instance.
  const CustomDurationListTile({
    required this.duration,
    required this.onChange,
    this.title = 'Duration',
    this.autofocus = false,
    super.key,
  });

  /// The duration to edit.
  final Duration duration;

  /// The function to call when [duration] changes.
  final ValueChanged<Duration> onChange;

  /// The title of the [ListTile].
  final String title;

  /// Whether the [ListTile] should be autofocused.
  final bool autofocus;

  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    final milliseconds = duration.inMilliseconds % 1000;
    final parts = [
      if (days > 0) '${days}D',
      if (hours > 0) '${hours}H',
      if (minutes > 0) '${minutes}M',
      if (seconds > 0) '${seconds}S',
      if (milliseconds > 0) '${milliseconds}MS',
    ];
    return PerformableActionsListTile(
      actions: [
        if (duration.inMilliseconds > 100)
          PerformableAction(
            name: 'Decrease value',
            activator: moveDownShortcut,
            invoke: () =>
                onChange(Duration(milliseconds: duration.inMilliseconds - 100)),
          ),
        PerformableAction(
          name: 'Increase value',
          activator: moveUpShortcut,
          invoke: () =>
              onChange(Duration(milliseconds: duration.inMilliseconds + 100)),
        ),
      ],
      autofocus: autofocus,
      title: Text(title),
      subtitle: Text(parts.join(' ')),
      onTap: () => context.pushWidgetBuilder(
        (_) => GetText(
          onDone: (final value) {
            final ms = int.parse(value);
            onChange(Duration(milliseconds: ms));
          },
          labelText: 'Milliseconds',
          text: duration.inMilliseconds.toString(),
          title: 'Set $title',
          validator: (final value) {
            if (value == null || value.trim().isEmpty) {
              return 'You must enter a number';
            }
            final ms = int.tryParse(value);
            if (ms == null) {
              return 'Invalid number';
            } else if (ms < 0) {
              return 'Negative durations are now allowed';
            }
            return null;
          },
        ),
      ),
    );
  }
}
