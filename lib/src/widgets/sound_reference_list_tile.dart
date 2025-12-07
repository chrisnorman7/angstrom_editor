import 'dart:math';

import 'package:angstrom/angstrom.dart';
import 'package:angstrom_editor/angstrom_editor.dart';
import 'package:backstreets_widgets/extensions.dart';
import 'package:backstreets_widgets/shortcuts.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_games/flutter_audio_games.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

/// A [ListTile] for editing a possible [soundReference].
class SoundReferenceListTile extends StatelessWidget {
  /// Create an instance.
  const SoundReferenceListTile({
    required this.soundPaths,
    required this.getSound,
    required this.title,
    required this.onChange,
    this.soundReference,
    this.autofocus = false,
    this.looping = false,
    super.key,
  });

  /// The list of sound paths to pick from.
  final List<String> soundPaths;

  /// The function to get sounds.
  final GetSound getSound;

  /// The title for the [ListTile].
  final String title;

  /// The function to use to set the new sound.
  final ValueChanged<SoundReference?> onChange;

  /// The current sound.
  final SoundReference? soundReference;

  /// Whether the [ListTile] should be autofocused.
  final bool autofocus;

  /// Whether the resulting sound should loop.
  final bool looping;

  /// Build the widget.
  @override
  Widget build(final BuildContext context) {
    final sound = soundReference;
    if (sound == null) {
      return ListTile(
        autofocus: autofocus,
        title: Text(title),
        onTap: () => context.pushWidgetBuilder(
          (_) => SelectSound(
            soundPaths: soundPaths,
            getSound: getSound,
            setSound: (final value) => onChange(value.asSoundReference()),
            looping: looping,
          ),
        ),
      );
    }
    const minVolume = 0.0;
    const maxVolume = 10.0;
    return PlaySoundSemantics(
      sound: getSound(
        soundReference: sound,
        destroy: false,
        loadMode: looping ? LoadMode.disk : LoadMode.memory,
        looping: looping,
      ),
      child: PerformableActionsListTile(
        actions: [
          PerformableAction(
            name: 'Edit volume',
            invoke: () => context.pushWidgetBuilder(
              (_) => EditVolumeScreen(
                volume: sound.volume,
                onChanged: (final value) =>
                    onChange(SoundReference(path: sound.path, volume: value)),
              ),
            ),
          ),
          PerformableAction(
            name: 'Increase volume',
            activator: moveUpShortcut,
            invoke: () => onChange(
              SoundReference(
                path: sound.path,
                volume: min(maxVolume, sound.volume + 0.1),
              ),
            ),
          ),
          PerformableAction(
            name: 'Decrease volume',
            activator: moveDownShortcut,
            invoke: () => onChange(
              SoundReference(
                path: sound.path,
                volume: max(minVolume, sound.volume - 0.1),
              ),
            ),
          ),
          PerformableAction(
            name: 'Delete',
            activator: deleteShortcut,
            invoke: () => onChange(null),
          ),
        ],
        autofocus: autofocus,
        title: Text(title),
        subtitle: SoundReferenceText(soundReference: sound),
        onTap: () => context.pushWidgetBuilder(
          (_) => SelectSound(
            soundPaths: soundPaths,
            getSound: getSound,
            setSound: (final value) =>
                onChange(value.asSoundReference(volume: sound.volume)),
            looping: looping,
            soundPath: sound.path,
            volume: sound.volume,
          ),
        ),
      ),
    );
  }
}
