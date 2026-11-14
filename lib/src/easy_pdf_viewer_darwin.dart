import 'dart:async';
import 'dart:ffi' as ffi;

import 'package:easy_pdf_viewer/src/bindings/easy_pdf_viewer_darwin.g.dart';
import 'package:easy_pdf_viewer/src/easy_pdf_viewer_platform.dart';
import 'package:easy_pdf_viewer/src/native_bridge.dart';
import 'package:objective_c/objective_c.dart' as objc;

/// [EasyPdfViewerPlatform] over the Objective-C runtime: Dart calls `EasyPdfViewerApi` (Swift, `@objc`) directly,
/// with no method channel. Results are listener blocks, which may fire on any thread and are delivered to this
/// isolate.
class DarwinEasyPdfViewer implements EasyPdfViewerPlatform {
  @override
  Future<int> getNumberOfPages(String filePath, {required bool clearCacheDir}) async {
    final String? count = await callNative(
      (ResultBlock callback) =>
          EasyPdfViewerApi.getNumberOfPages(filePath.toNSString(), clearCacheDir: clearCacheDir, callback: callback),
    );
    return int.parse(count!);
  }

  @override
  Future<String?> getPage(String filePath, int pageNumber) => callNative(
    (ResultBlock callback) =>
        EasyPdfViewerApi.getPage(filePath.toNSString(), pageNumber: pageNumber, callback: callback),
  );

  @override
  Future<void> clearCacheDir() async {
    await callNative(EasyPdfViewerApi.clearCacheDir);
  }
}

/// The block type every native completion uses: `(value, errorCode, errorMessage, errorDetails)`.
typedef ResultBlock = objc.ObjCBlock<ffi.Void Function(objc.NSString?, objc.NSString?, objc.NSString?, objc.NSString?)>;

/// Starts one native call and completes with its result.
Future<String?> callNative(void Function(ResultBlock callback) start) {
  final Completer<String?> completer = Completer<String?>();
  try {
    start(
      ObjCBlock_ffiVoid_NSString_NSString_NSString_NSString.listener((
        objc.NSString? value,
        objc.NSString? code,
        objc.NSString? message,
        objc.NSString? details,
      ) {
        if (completer.isCompleted) {
          return;
        }
        if (code == null) {
          completer.complete(value?.toDartString());
        } else {
          completer.completeError(
            NativeFailure(
              code: code.toDartString(),
              message: message?.toDartString() ?? '',
              details: details?.toDartString(),
            ),
          );
        }
      }),
    );
  } on Object catch (e) {
    return Future<String?>.error(NativeFailure(code: 'OBJC_ERROR', message: e.toString()));
  }
  return completer.future;
}
