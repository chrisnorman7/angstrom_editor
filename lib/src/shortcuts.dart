import 'package:backstreets_widgets/shortcuts.dart';
import 'package:flutter/services.dart';

/// The rename shortcut.
final renameShortcut = CrossPlatformSingleActivator(LogicalKeyboardKey.keyR);

/// The copy extra information shortcut.
final copyExtraShortcut = CrossPlatformSingleActivator(LogicalKeyboardKey.keyC);

/// The shortcut to edit or clear music.
final editMusicShortcut = CrossPlatformSingleActivator(
  LogicalKeyboardKey.keyM,
  shift: true,
);

/// The shortcut for building code.
final buildShortcut = CrossPlatformSingleActivator(LogicalKeyboardKey.keyB);

/// The shortcut for moving a room object.
/// The shortcut for adding or editing doors.
final doorShortcut = CrossPlatformSingleActivator(LogicalKeyboardKey.keyD);

/// The shortcut for editing engine commands.
final editEngineCommands = CrossPlatformSingleActivator(
  LogicalKeyboardKey.keyC,
  shift: true,
);
