import 'package:angstrom/angstrom.dart';
import 'package:angstrom_editor/angstrom_editor.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_games/flutter_audio_games.dart';

/// A widget for playing [footstepSounds] at the given [interval].
class FootstepsPlaySoundSemantics extends StatefulWidget {
  /// Create an instance.
  const FootstepsPlaySoundSemantics({
    required this.editorContext,
    required this.footstepSounds,
    required this.interval,
    required this.child,
    this.volume = 0.7,
    super.key,
  });

  /// The editor context to use.
  final EditorContext editorContext;

  /// The sounds to play.
  final List<String> footstepSounds;

  /// The interval at which [footstepSounds] should be played.
  final Duration interval;

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

  /// Initialise state.
  @override
  void initState() {
    super.initState();
    _shouldPlay = false;
  }

  /// Build the widget.
  @override
  Widget build(final BuildContext context) {
    final editorContext = widget.editorContext;
    final sounds = widget.footstepSounds
        .map(
          (final path) => editorContext.getSound(
            soundReference: path.asSoundReference(volume: widget.volume),
            destroy: true,
          ),
        )
        .toList();
    return ProtectSounds(
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
}
