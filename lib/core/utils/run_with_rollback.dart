Future<T> runWithRollBack<T>({
  required Future<T> Function() action,
  required Future<void> Function() rollback,
}) async {
  try {
    return await action();
  } catch (e) {
    try {
      await rollback();
    } catch (_) {}
    rethrow;
  }
}
