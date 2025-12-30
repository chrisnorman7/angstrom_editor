/// No such room was found.
class InvalidRoomException implements Exception {
  /// Create an instance.
  const InvalidRoomException(this.roomId);

  /// The ID of the room that could not be found.
  final String roomId;

  /// Useful message.
  @override
  String toString() => 'There is no room with the id `$roomId`.';
}
