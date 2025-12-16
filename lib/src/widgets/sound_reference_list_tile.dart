import 'package:angstrom/angstrom.dart';
import 'package:angstrom_editor/angstrom_editor.dart';
import 'package:backstreets_widgets/extensions.dart';
import 'package:backstreets_widgets/shortcuts.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_games/flutter_audio_games.dart';

/// A [ListTile] that allows changing the given [soundReference] to any sound
/// which [editorContext] knows about.
class SoundReferenceListTile extends StatelessWidget {
  /// Create an instance.
  const SoundReferenceListTile({
    required this.editorContext,
    required this.onChange,
    this.soundReference,
    this.title = 'Sound',
    this.autofocus = false,
    super.key,
  });

  /// The editor context to use.
  final EditorContext editorContext;

  /// The function to call when the current [soundReference] changes.
  final ValueChanged<SoundReference?> onChange;

  /// The current sound reference.
  final SoundReference? soundReference;

  /// The title of this [ListTile].
  final String title;

  /// Whether the [ListTile] should be autofocused.
  final bool autofocus;

  /// Build the widget.
  @override
  Widget build(final BuildContext context) {
    final reference = soundReference;
    if (reference == null) {
      return ListTile(
        autofocus: autofocus,
        title: Text(title),
        onTap: () => context.pushWidgetBuilder(
          (_) => CreateSoundReferenceScreen(
            editorContext: editorContext,
            onChange: onChange,
          ),
        ),
      );
    }
    final sound = editorContext.getSound(
      soundReference: reference,
      destroy: false,
    );
    return MaybePlaySoundSemantics(
      sound: sound,
      child: PerformableActionsListTile(
        actions: [
          ...SoundReferenceVolumeActions(
            soundReference: reference,
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
        subtitle: SoundReferenceText(soundReference: reference),
        onTap: () => context.pushWidgetBuilder(
          (_) => CreateSoundReferenceScreen(
            editorContext: editorContext,
            onChange: onChange,
            soundReference: reference,
          ),
        ),
      ),
    );
  }
}
