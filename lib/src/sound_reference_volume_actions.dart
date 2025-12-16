import 'dart:math';

import 'package:angstrom/angstrom.dart';
import 'package:backstreets_widgets/shortcuts.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/rendering.dart';

/// A class which provides [actions] for editing the volume of [soundReference].
class SoundReferenceVolumeActions {
  /// Create an instance.
  const SoundReferenceVolumeActions({
    required this.soundReference,
    required this.onChange,
    this.volumeAdjust = 0.1,
    this.minVolume = 0.1,
    this.maxVolume = 5.0,
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

  /// The actions for changing the volume.
  Iterable<PerformableAction> get actions sync* {
    if (soundReference.volume > minVolume) {
      yield PerformableAction(
        name: 'Volume down',
        activator: moveDownShortcut,
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
        activator: moveUpShortcut,
        invoke: () => onChange(
          soundReference.path.asSoundReference(
            volume: min(maxVolume, soundReference.volume + volumeAdjust),
          ),
        ),
      );
    }
  }
}
