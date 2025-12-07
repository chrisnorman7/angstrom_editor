import 'package:angstrom/angstrom.dart';
import 'package:angstrom_editor/src/constants.dart';
import 'package:backstreets_widgets/extensions.dart';
import 'package:backstreets_widgets/screens.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_games/flutter_audio_games.dart';
import 'package:path/path.dart' as path;

/// A screen for selecting a new [soundPath] from [soundPaths].
class SelectSound extends StatelessWidget {
  /// Create an instance.
  const SelectSound({
    required this.soundPaths,
    required this.getSound,
    required this.setSound,
    this.soundPath,
    this.volume = 0.7,
    this.looping = false,
    this.title = 'Select Sound',
    super.key,
  });

  /// The list of sounds to choose from.
  final List<String> soundPaths;

  /// The function to call to get a [Sound] from a sound path.
  final GetSound getSound;

  /// The function to call with the new [soundPath].
  final ValueChanged<String> setSound;

  /// The current sound path.
  final String? soundPath;

  /// The volume to play previewed sounds at.
  final double volume;

  /// Whether the sound previews should loop.
  final bool looping;

  /// The title of the screen.
  final String title;

  /// Build the widget.
  @override
  Widget build(final BuildContext context) => Cancel(
    child: SimpleScaffold(
      title: title,
      body: ListView.builder(
        itemBuilder: (final context, final index) {
          final s = soundPaths[index];
          return PlaySoundSemantics(
            sound: getSound(
              soundReference: s.asSoundReference(volume: volume),
              destroy: false,
              looping: looping,
            ),
            child: ListTile(
              autofocus: soundPath == null ? index == 0 : s == soundPath,
              title: Text(path.basename(s)),
              onTap: () {
                context.pop();
                setSound(s);
              },
            ),
          );
        },
        itemCount: soundPaths.length,
        shrinkWrap: true,
      ),
    ),
  );
}
