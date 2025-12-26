import 'package:angstrom/angstrom.dart';
import 'package:angstrom_editor/angstrom_editor.dart';
import 'package:backstreets_widgets/screens.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

/// A screen for selecting from all the sounds that the nearest [EditorContext]
/// knows about.
class CreateSoundReferenceScreen extends StatefulWidget {
  /// Create an instance.
  const CreateSoundReferenceScreen({
    required this.editorContext,
    required this.onChange,
    this.soundReference,
    super.key,
  });

  /// The editor context to use.
  final EditorContext editorContext;

  /// The function to call when [soundReference] changes.
  final ValueChanged<SoundReference> onChange;

  /// The sound to alter.
  final SoundReference? soundReference;

  /// Create state for this widget.
  @override
  CreateSoundReferenceScreenState createState() =>
      CreateSoundReferenceScreenState();
}

/// State for [CreateSoundReferenceScreen].
class CreateSoundReferenceScreenState
    extends State<CreateSoundReferenceScreen> {
  /// The sound paths to choose from.
  List<String>? _soundPaths;

  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final editorContext = widget.editorContext;
    final soundPaths = _soundPaths;
    if (soundPaths == null) {
      final soundReference = widget.soundReference;
      final paths = <FootstepsSounds>[
        FootstepsSounds(
          name: 'Ambiances',
          soundPaths: editorContext.ambianceSoundPaths,
        ),
        FootstepsSounds(name: 'Doors', soundPaths: editorContext.doorSounds),
        ...editorContext.footsteps.map(
          (final f) => FootstepsSounds(
            name: path.join('Footsteps', path.basename(f.name)),
            soundPaths: f.soundPaths,
          ),
        ),
        FootstepsSounds(
          name: 'Music',
          soundPaths: editorContext.musicSoundPaths,
        ),
      ];
      return Cancel(
        child: SimpleScaffold(
          title: 'Select Directory',
          body: ListView.builder(
            itemBuilder: (final context, final index) {
              final directory = paths[index];
              return ListTile(
                autofocus: soundReference == null
                    ? index == 0
                    : directory.soundPaths.contains(soundReference.path),
                title: Text(directory.name),
                subtitle: Text('${directory.soundPaths.length}'),
                onTap: () => setState(() => _soundPaths = directory.soundPaths),
              );
            },
            itemCount: paths.length,
            shrinkWrap: true,
          ),
        ),
      );
    }
    return SelectSoundScreen(
      soundPaths: soundPaths,
      getSound: editorContext.getSound,
      setSound: (final value) => widget.onChange(
        value.asSoundReference(volume: widget.soundReference?.volume ?? 0.7),
      ),
      soundPath: widget.soundReference?.path,
      volume: widget.soundReference?.volume ?? 0.7,
    );
  }
}
