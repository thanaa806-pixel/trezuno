/// Base error class for Trezuno application.
abstract class AppError {
  final String message;
  final String? technicalDetails;

  AppError(this.message, [this.technicalDetails]);

  @override
  String toString() => 'AppError: $message';
}

/// Error thrown when product operations fail.
class ProductError extends AppError {
  ProductError(String message, [String? technicalDetails])
      : super(message, technicalDetails ?? 'Product operation failed');
}

/// Error thrown when database operations fail.
class DatabaseError extends AppError {
  DatabaseError(String message, [String? technicalDetails])
      : super(message, technicalDetails ?? 'Database operation failed');
}

/// Error thrown when notification operations fail.
class NotificationError extends AppError {
  NotificationError(String message)
      : super(message, 'Notification operation failed');
}

/// Error thrown when localization fails.
class LocalizationError extends AppError {
  LocalizationError(String message, [String? technicalDetails])
      : super(message, technicalDetails ?? 'Localization lookup failed');
}
