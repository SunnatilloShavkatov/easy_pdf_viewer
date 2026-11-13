import 'dart:async';

import 'package:easy_pdf_viewer/src/bindings/easy_pdf_viewer_api.g.dart';
import 'package:easy_pdf_viewer/src/easy_pdf_viewer_platform.dart';
import 'package:easy_pdf_viewer/src/native_bridge.dart';
import 'package:jni/jni.dart';

/// [EasyPdfViewerPlatform] over JNI: Dart calls `EasyPdfViewerApi` directly, with no method channel. Results arrive
/// through `$async` callbacks, so Kotlin never blocks on Dart.
class AndroidEasyPdfViewer implements EasyPdfViewerPlatform {
  @override
  Future<int> getNumberOfPages(String filePath, {required bool clearCacheDir}) async {
    final String? count = await callNative(
      (ResultCallback callback) => using(
        (Arena arena) =>
            EasyPdfViewerApi.getNumberOfPages(filePath.toJString()..releasedBy(arena), clearCacheDir, callback),
      ),
    );
    return int.parse(count!);
  }

  @override
  Future<String?> getPage(String filePath, int pageNumber) => callNative(
    (ResultCallback callback) =>
        using((Arena arena) => EasyPdfViewerApi.getPage(filePath.toJString()..releasedBy(arena), pageNumber, callback)),
  );

  @override
  Future<void> clearCacheDir() async {
    await callNative(EasyPdfViewerApi.clearCacheDir);
  }
}

/// Starts one native call and completes with its result.
Future<String?> callNative(void Function(ResultCallback callback) start) {
  final Completer<String?> completer = Completer<String?>();
  try {
    final ResultCallback callback = ResultCallback.implement(
      $ResultCallback(
        success: (JString? value) {
          final String? decoded = value?.toDartString(releaseOriginal: true);
          if (!completer.isCompleted) {
            completer.complete(decoded);
          }
        },
        success$async: true,
        error: (JString code, JString message, JString? details) {
          final NativeFailure failure = NativeFailure(
            code: code.toDartString(releaseOriginal: true),
            message: message.toDartString(releaseOriginal: true),
            details: details?.toDartString(releaseOriginal: true),
          );
          if (!completer.isCompleted) {
            completer.completeError(failure);
          }
        },
        error$async: true,
      ),
    );
    handOver(callback, start);
  } on JThrowable catch (e) {
    return Future<String?>.error(NativeFailure(code: 'JNI_ERROR', message: e.toString()));
  }
  return completer.future;
}

/// Passes a Dart-implemented [proxy] to native code and drops Dart's own reference to it. Kotlin keeps the proxy
/// alive for as long as it needs it, and its port closes when Java collects it; without the release every call
/// would pin a JNI global reference until the next Dart GC.
void handOver<T extends JObject>(T proxy, void Function(T proxy) pass) {
  try {
    pass(proxy);
  } finally {
    proxy.release();
  }
}
