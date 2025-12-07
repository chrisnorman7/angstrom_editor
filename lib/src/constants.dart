import 'dart:convert';

import 'package:angstrom/angstrom.dart';
import 'package:flutter_audio_games/flutter_audio_games.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

/// The JSON encoder to use.
const encoder = JsonEncoder.withIndent('  ');

/// The file extension for room files.
const roomFileExtension = '.json';

/// The title of a delete confirmation dialogue.
const confirmDelete = 'Confirm Delete';

/// The type of a function which converts a [SoundReference] path to a [Sound]
/// instance.
typedef GetSound =
    Sound Function({
      required SoundReference soundReference,
      required bool destroy,
      LoadMode loadMode,
      bool looping,
      SoundPosition position,
    });
