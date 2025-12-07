import 'dart:math';

import 'package:backstreets_widgets/extensions.dart';
import 'package:backstreets_widgets/screens.dart';
import 'package:flutter/material.dart';

/// A screen which allows jumping to different [coordinates].
class GoToCoordinatesScreen extends StatelessWidget {
  /// Create an instance.
  const GoToCoordinatesScreen({
    required this.coordinates,
    required this.onChanged,
    super.key,
  });

  /// The coordinates the user is currently at.
  final Point<int> coordinates;

  /// The function to call when the coordinates change.
  final ValueChanged<Point<int>> onChanged;

  /// Build the widget.
  @override
  Widget build(final BuildContext context) => GetText(
    onDone: (final value) {
      context.pop();
      onChanged(_pointFromString(value)!);
    },
    labelText: 'Coordinates',
    text: '${coordinates.x},${coordinates.y}',
    title: 'Enter Coordinates',
    validator: (final value) {
      if (value == null || _pointFromString(value) == null) {
        return 'Invalid coordinates';
      }
      return null;
    },
  );

  /// Return a [Point] from [string].
  Point<int>? _pointFromString(final String string) {
    final regExp = RegExp(r'^(\d+)[, ]+(\d+)$');
    final match = regExp.firstMatch(string);
    if (match == null) {
      return null;
    }
    return Point(int.parse(match.group(1)!), int.parse(match.group(2)!));
  }
}
