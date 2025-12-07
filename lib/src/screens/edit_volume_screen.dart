import 'package:backstreets_widgets/extensions.dart';
import 'package:backstreets_widgets/screens.dart';
import 'package:flutter/material.dart';

/// A screen for editing [volume].
class EditVolumeScreen extends StatelessWidget {
  /// Create an instance.
  const EditVolumeScreen({
    required this.volume,
    required this.onChanged,
    this.minVolume = 0.0,
    this.maxVolume = 10.0,
    super.key,
  });

  /// The current volume.
  final double volume;

  /// The function to call when [volume] changes.
  final ValueChanged<double> onChanged;

  /// The minimum volume.
  final double minVolume;

  /// The maximum volume.
  final double maxVolume;

  /// Build the widget.
  @override
  Widget build(final BuildContext context) => GetText(
    onDone: (final value) {
      context.pop();
      onChanged(double.parse(value));
    },
    labelText: 'Volume',
    text: volume.toString(),
    title: 'Set Volume',
    validator: (final value) {
      if (value == null || double.tryParse(value) == null) {
        return 'Invalid number';
      }
      final newVolume = double.parse(value);
      if (newVolume < minVolume || newVolume > maxVolume) {
        return 'Volume must be between $minVolume and $maxVolume.';
      }
      return null;
    },
  );
}
