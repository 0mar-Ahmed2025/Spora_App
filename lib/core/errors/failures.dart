abstract class Failure implements Exception {
  final String code;
  final String? message;

  const Failure(this.code, [this.message]);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.code = 'network_unavailable', super.message]);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure([super.code = 'timeout', super.message]);
}

class ServerFailure extends Failure {
  const ServerFailure([super.code = 'server_error', super.message]);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.code = 'validation_error', super.message]);
}

class FileMissingFailure extends Failure {
  const FileMissingFailure([super.code = 'file_missing', super.message]);
}

class StorageFailure extends Failure {
  const StorageFailure([super.code = 'storage_error', super.message]);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.code = 'unknown_error', super.message]);
}
