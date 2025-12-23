import 'package:angstrom_editor/angstrom_editor.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_games/flutter_audio_games.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

/// The room objects page.
class RoomObjectsPage extends StatelessWidget {
  /// Create an instance.
  const RoomObjectsPage({required this.onChange, super.key});

  /// The function to call when a surface has been edited.
  final VoidCallback onChange;

  /// Build the widget.
  @override
  Widget build(final BuildContext context) {
    final editorContext = context.editorContext;
    final room = editorContext.room.editorRoom;
    final objects = room.objects;
    if (objects.isEmpty) {
      return const CenterText(text: 'There are no objects in this room.');
    }
    return ListView.builder(
      itemBuilder: (final context, final index) {
        final object = objects[index];
        final ambiance = object.ambiance;
        final sound = ambiance == null
            ? null
            : editorContext.getSound(
                soundReference: ambiance,
                destroy: false,
                loadMode: LoadMode.disk,
                looping: true,
              );
        return MaybePlaySoundSemantics(
          sound: sound,
          child: RoomObjectListTile(
            object: object,
            onChange: onChange,
            autofocus: index == 0,
          ),
        );
      },
      itemCount: objects.length,
      shrinkWrap: true,
    );
  }
}
