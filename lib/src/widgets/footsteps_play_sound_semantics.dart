import 'package:angstrom/angstrom.dart';
import 'package:angstrom_editor/src/constants.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_games/flutter_audio_games.dart';

/// A widget for playing [footstepSounds] at the given [interval].
class FootstepsPlaySoundSemantics extends StatefulWidget {
  /// Create an instance.
  const FootstepsPlaySoundSemantics({
    required this.footstepSounds,
    required this.interval,
    required this.getSound,
    required this.child,
    this.volume = 0.7,
    super.key,
  });

  /// The sounds to play.
  final List<String> footstepSounds;

  /// The interval at which [footstepSounds] should be played.
  final Duration interval;

  /// The function to convert one of the [footstepSounds] to a [Sound].
  final GetSound getSound;

  /// The widget below this widget in the tree.
  final Widget child;

  /// The volume that [footstepSounds] should play at.
  final double volume;

  @override
  State<FootstepsPlaySoundSemantics> createState() =>
      _FootstepsPlaySoundSemanticsState();
}

class _FootstepsPlaySoundSemanticsState
    extends State<FootstepsPlaySoundSemantics> {
  /// Whether we should be playing.
  late bool _shouldPlay;

  /// The sounds to play.
  late final List<Sound> sounds;

  /// Initialise state.
  @override
  void initState() {
    super.initState();
    _shouldPlay = false;
    sounds = widget.footstepSounds
        .map(
          (final path) => widget.getSound(
            soundReference: path.asSoundReference(volume: widget.volume),
            destroy: true,
          ),
        )
        .toList();
  }

  /// Build the widget.
  @override
  Widget build(final BuildContext context) => ProtectSounds(
    sounds: sounds,
    child: FocusableActionDetector(
      enabled: false,
      onFocusChange: (final value) {
        _shouldPlay = value;
      },
      child: MouseRegion(
        child: Ticking(
          duration: widget.interval,
          onTick: () {
            if (_shouldPlay) {
              context.playRandomSound(sounds);
            }
          },
          child: widget.child,
        ),
        onEnter: (final _) {
          _shouldPlay = true;
        },
        onExit: (final _) {
          _shouldPlay = false;
        },
      ),
    ),
  );
}
