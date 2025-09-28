import 'dart:async';

/// 🚀 Adaptive Debouncer - Intelligently adjusts delay for blazing fast UX
///
/// This smart debouncer reduces delay for fast typers and increases for slow typers,
/// providing the optimal balance between performance and user experience.
class AdaptiveDebouncer {
  Timer? _timer;
  late Duration _currentDelay;
  DateTime? _lastAction;
  int _actionCount = 0;

  // Performance tuned defaults
  final Duration _minDelay;
  final Duration _maxDelay;
  final Duration _fastTypingThreshold;

  AdaptiveDebouncer({
    Duration minDelay = const Duration(milliseconds: 50),    // Ultra fast for rapid typing
    Duration maxDelay = const Duration(milliseconds: 300),   // Standard for slow typing
    Duration fastTypingThreshold = const Duration(milliseconds: 150), // Detect fast typing
  }) : _minDelay = minDelay,
       _maxDelay = maxDelay,
       _fastTypingThreshold = fastTypingThreshold,
       _currentDelay = maxDelay;

  /// Execute action with smart delay adaptation
  void call(void Function() action) {
    final now = DateTime.now();

    // Adaptive delay calculation based on typing speed
    if (_lastAction != null) {
      final timeBetweenActions = now.difference(_lastAction!);

      if (timeBetweenActions <= _fastTypingThreshold) {
        // User is typing fast - use minimal delay for instant feedback
        _actionCount++;
        final adaptedDelay = Duration(
          milliseconds: (_minDelay.inMilliseconds +
                        (_maxDelay.inMilliseconds - _minDelay.inMilliseconds) /
                        (_actionCount.clamp(1, 10))).round()
        );
        _currentDelay = adaptedDelay;
      } else {
        // User is typing slowly - use standard delay and reset counter
        _currentDelay = _maxDelay;
        _actionCount = 0;
      }
    }

    _lastAction = now;

    // Cancel previous timer and start new one
    _timer?.cancel();
    _timer = Timer(_currentDelay, () {
      action();
      _actionCount = 0; // Reset after execution
    });
  }

  /// Cancel any pending action
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Dispose resources
  void dispose() {
    cancel();
  }

  /// Get current adaptive delay (for debugging/monitoring)
  Duration get currentDelay => _currentDelay;

  /// Check if fast typing is detected
  bool get isFastTyping => _actionCount > 0;
}

/// 🎯 Smart Search Debouncer - Specialized for search/autocomplete scenarios
class SearchDebouncer extends AdaptiveDebouncer {
  final Map<String, DateTime> _queryHistory = {};
  static const int _maxHistorySize = 100;

  SearchDebouncer({
    super.minDelay = const Duration(milliseconds: 30),   // Even faster for search
    super.maxDelay = const Duration(milliseconds: 250),  // Shorter max for search
    super.fastTypingThreshold = const Duration(milliseconds: 120),
  });

  /// Execute search with query-specific optimizations
  void search(String query, Function(String) searchAction) {
    // Skip debouncing for very short queries (instant results)
    if (query.length <= 1) {
      cancel();
      searchAction(query);
      return;
    }

    // Check if we've seen this query recently (cache hit)
    final now = DateTime.now();
    if (_queryHistory.containsKey(query)) {
      final lastSeen = _queryHistory[query]!;
      if (now.difference(lastSeen) < const Duration(seconds: 10)) {
        // Recent query - execute immediately
        cancel();
        searchAction(query);
        return;
      }
    }

    // Use adaptive debouncing for new/old queries
    call(() {
      searchAction(query);
      _updateQueryHistory(query, now);
    });
  }

  void _updateQueryHistory(String query, DateTime timestamp) {
    _queryHistory[query] = timestamp;

    // Maintain cache size
    if (_queryHistory.length > _maxHistorySize) {
      final oldestKey = _queryHistory.entries
          .reduce((a, b) => a.value.isBefore(b.value) ? a : b)
          .key;
      _queryHistory.remove(oldestKey);
    }
  }

  @override
  void dispose() {
    _queryHistory.clear();
    super.dispose();
  }
}