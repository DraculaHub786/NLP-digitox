
extension ExtIterable on Iterable<dynamic> {
  /// Iterates over [this] and check if [other] contains any one of the element from [this]
  /// Returns TRUE if [other] contains any element of [this] otherwise false
  bool containsAnyOf(Iterable<dynamic> other) {
    for (final e in this) {
      if (other.contains(e)) return true;
    }
    return false;
  }
}
