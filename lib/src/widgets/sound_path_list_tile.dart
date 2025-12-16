import 'package:angstrom/angstrom.dart';
import 'package:angstrom_editor/angstrom_editor.dart';
import 'package:backstreets_widgets/extensions.dart';
import 'package:backstreets_widgets/shortcuts.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_games/flutter_audio_games.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

/// A [ListTile] for selecting a new path for [soundReference].
class SoundPathListTile extends StatelessWidget {
  /// Create an instance.
  const SoundPathListTile({
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
          (_) => SelectSoundScreen(
            soundPaths: soundPaths,
            getSound: getSound,
            setSound: (final value) => onChange(value.asSoundReference()),
            looping: looping,
          ),
        ),
      );
    }
    return PlaySoundSemantics(
      sound: getSound(
        soundReference: sound,
        destroy: false,
        loadMode: looping ? LoadMode.disk : LoadMode.memory,
        looping: looping,
      ),
      child: PerformableActionsListTile(
        actions: [
          ...SoundReferenceVolumeActions(
            soundReference: sound,
            onChange: onChange,
          ).getActions(context),
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
          (_) => SelectSoundScreen(
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
