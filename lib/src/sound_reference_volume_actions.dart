import 'dart:math';

import 'package:angstrom/angstrom.dart';
import 'package:angstrom_editor/angstrom_editor.dart';
import 'package:backstreets_widgets/extensions.dart';
import 'package:backstreets_widgets/shortcuts.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';

/// A class which provides [PerformableActions] for editing the volume of
/// [soundReference].
class SoundReferenceVolumeActions {
  /// Create an instance.
  const SoundReferenceVolumeActions({
    required this.soundReference,
    required this.onChange,
    this.volumeAdjust = 0.0,
    this.minVolume = 0.1,
    this.maxVolume = 5.0,
    this.volumeUpShortcut = moveUpShortcut,
    this.volumeDownShortcut = moveDownShortcut,
  });

  /// The sound reference to use.
  final SoundReference soundReference;

  /// The function to call when the [soundReference] volume changes.
  final ValueChanged<SoundReference> onChange;

  /// How much to adjust the volume by.
  final double volumeAdjust;

  /// The minimum volume to use.
  final double minVolume;

  /// The maximum volume to use.
  final double maxVolume;

  /// The shortcut to increase volume.
  final SingleActivator? volumeUpShortcut;

  /// The shortcut to decrease volume.
  final SingleActivator? volumeDownShortcut;

  /// The actions for changing the volume.
  Iterable<PerformableAction> getActions(final BuildContext context) sync* {
    yield PerformableAction(
      name: 'Edit volume (${soundReference.volume})',
      invoke: () => context.pushWidgetBuilder(
        (_) => EditVolumeScreen(
          volume: soundReference.volume,
          onChanged: (final value) => onChange(
            soundReference.path.asSoundReference(
              volume: value.clamp(minVolume, maxVolume),
            ),
          ),
          minVolume: minVolume,
          maxVolume: maxVolume,
        ),
      ),
    );
    if (soundReference.volume > minVolume) {
      yield PerformableAction(
        name: 'Volume down',
        activator: volumeDownShortcut,
        invoke: () => onChange(
          soundReference.path.asSoundReference(
            volume: max(minVolume, soundReference.volume - volumeAdjust),
          ),
        ),
      );
    }
    if (soundReference.volume < maxVolume) {
      yield PerformableAction(
        name: 'Volume up',
        activator: volumeUpShortcut,
        invoke: () => onChange(
          soundReference.path.asSoundReference(
            volume: min(maxVolume, soundReference.volume + volumeAdjust),
          ),
        ),
      );
    }
  }
}
