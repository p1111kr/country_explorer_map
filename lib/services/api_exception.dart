class ApiException implements Exception {
  final String message;
  final int
      statusCode; // Made non-nullable to ensure we always show the code for non-200s

  const ApiException({
    required this.message,
    required this.statusCode, // Requirement: Show the HTTP status code
  });

  @override
  String toString() {
    // Explicitly formatting this to show both the code and message as requested
    return 'Status Code $statusCode: $message';
  }

  // A "human touch" helper for the UI layer
  String get userFriendlyMessage {
    if (statusCode == 404)
      return 'Country not found (404). Try a different search.';
    if (statusCode == 429)
      return 'Too many requests (429). Please wait a moment.';
    if (statusCode >= 500) {
      return 'Server Error ($statusCode). We are having trouble right now.';
    }
    return '$message ($statusCode)';
  }

  bool get isRetryable => statusCode >= 500 || statusCode == 429;
}
