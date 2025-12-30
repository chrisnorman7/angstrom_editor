/// The severity of a [BuildError].
enum BuildErrorSeverity {
  /// Just a warning.
  warning,

  /// An error.
  error,
}

/// A problem with a build.
class BuildError {
  /// Create an instance.
  const BuildError({required this.severity, required this.message});

  /// The severity of this warning.
  final BuildErrorSeverity severity;

  /// THe message to show.
  final String message;
}
