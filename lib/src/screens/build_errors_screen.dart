import 'package:angstrom_editor/angstrom_editor.dart';
import 'package:backstreets_widgets/screens.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';

/// A screen to show [buildErrors].
class BuildErrorsScreen extends StatelessWidget {
  /// Create an instance.
  const BuildErrorsScreen({
    required this.rooms,
    required this.buildErrors,
    super.key,
  });

  /// The rooms to use.
  final List<LoadedRoom> rooms;

  /// The build errors to show.
  final List<BuildError> buildErrors;

  /// Build the widget.
  @override
  Widget build(final BuildContext context) => Cancel(
    child: SimpleScaffold(
      title: 'Build Errors',
      body: ListView.builder(
        itemBuilder: (final context, final index) {
          final error = buildErrors[index];
          return ListTile(
            autofocus: index == 0,
            title: Text(error.severity.name),
            subtitle: Text(error.message),
            onTap: () => Navigator.pop(context),
          );
        },
        itemCount: buildErrors.length,
        shrinkWrap: true,
      ),
    ),
  );
}
