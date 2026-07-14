/// Result of a repository read, tagged with where the data actually came from.
///
/// The desa office loses internet regularly, so a failed fetch falls back to the
/// last successful response instead of surfacing an error. Callers need to know
/// which happened so the UI can say the data is stale rather than pretend it is live.
class CachedResult<T> {
  final T data;

  /// True when the network failed and [data] came from the on-disk cache.
  final bool isFromCache;

  /// When the cached copy was fetched. Null unless [isFromCache].
  final DateTime? cachedAt;

  const CachedResult.fresh(this.data)
      : isFromCache = false,
        cachedAt = null;

  const CachedResult.fromCache(this.data, this.cachedAt) : isFromCache = true;
}
