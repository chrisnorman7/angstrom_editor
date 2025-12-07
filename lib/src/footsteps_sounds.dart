/// A class which holds the [name] and [soundPaths] for a list of footstep
/// sounds.
class FootstepsSounds {
  /// Create an instance.
  const FootstepsSounds({required this.name, required this.soundPaths});

  /// The name of this collection.
  final String name;

  /// The paths of possible sound files.
  final List<String> soundPaths;
}
