import 'package:angstrom_editor/angstrom_editor.dart';
import 'package:backstreets_widgets/extensions.dart';
import 'package:backstreets_widgets/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_games/flutter_audio_games.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

/// A screen to select from a list of [objects].
class SelectObjectScreen extends StatelessWidget {
  /// Create an instance.
  const SelectObjectScreen({
    required this.objects,
    required this.onChange,
    this.title = 'Select Object',
    this.objectId,
    super.key,
  });

  /// The objects to select from.
  final List<EditorRoomObject> objects;

  /// The function to call when a new object is selected.
  final ValueChanged<EditorRoomObject> onChange;

  /// The title of the [SimpleScaffold].
  final String title;

  /// The ID of the currently-selected object.
  final String? objectId;

  /// Build the widget.
  @override
  Widget build(final BuildContext context) {
    final getSound = context.getSound;
    return SimpleScaffold(
      title: title,
      body: ListView.builder(
        itemBuilder: (final context, final index) {
          final object = objects[index];
          final ambiance = object.ambiance;
          final sound = ambiance == null
              ? null
              : getSound(
                  soundReference: ambiance,
                  destroy: false,
                  loadMode: LoadMode.disk,
                  looping: true,
                );
          return MaybePlaySoundSemantics(
            sound: sound,
            child: ListTile(
              autofocus: objectId == null ? index == 0 : object.id == objectId,
              title: Text(object.name),
              onTap: () {
                context.pop();
                onChange(object);
              },
            ),
          );
        },
      ),
    );
  }
}
