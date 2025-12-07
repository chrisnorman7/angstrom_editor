import 'package:angstrom/angstrom.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

/// A [Text] widget which displays a [soundReference].
class SoundReferenceText extends StatelessWidget {
  /// Create an instance.
  const SoundReferenceText({required this.soundReference, super.key});

  /// The sound reference to display.
  final SoundReference soundReference;

  /// Build the widget.
  @override
  Widget build(final BuildContext context) {
    final soundName = path.basename(soundReference.path);
    return Text('$soundName (${soundReference.volume.toStringAsFixed(1)})');
  }
}
