import 'dart:convert';

import 'package:angstrom/angstrom.dart';
import 'package:angstrom_editor/angstrom_editor.dart';

/// The JSON encoder to use.
const encoder = JsonEncoder.withIndent('  ');

/// The file extension for room files.
const roomFileExtension = '.json';

/// The title of a delete confirmation dialogue.
const confirmDelete = 'Confirm Delete';

/// The type of an event commands map.
typedef EventsMap = Map<AngstromEventType, EditorEventCommand>;

/// The type of an [EngineCommand] handler.
typedef EngineCommandHandler =
    void Function(EngineCommandCaller caller, AngstromEngine engine);
