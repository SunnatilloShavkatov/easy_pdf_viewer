/// A native call that completed with an error: the `(code, message, details)` of the native result callback.
class NativeFailure implements Exception {
  const new({required this.code, required this.message, this.details});

  final String code;
  final String message;
  final String? details;

  @override
  String toString() => 'NativeFailure(code: $code, message: $message, details: $details)';
}
