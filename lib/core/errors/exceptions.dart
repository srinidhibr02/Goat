/// Thrown when an API / server request fails.
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => 'ServerException($statusCode): $message';
}

/// Thrown when a local cache operation fails.
class CacheException implements Exception {
  final String message;

  const CacheException({required this.message});

  @override
  String toString() => 'CacheException: $message';
}

/// Thrown when the device has no network connectivity.
class NetworkException implements Exception {
  final String message;

  const NetworkException({
    this.message = 'No internet connection',
  });

  @override
  String toString() => 'NetworkException: $message';
}
