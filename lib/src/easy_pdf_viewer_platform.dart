import 'package:easy_pdf_viewer/src/easy_pdf_viewer_android.dart';
import 'package:easy_pdf_viewer/src/easy_pdf_viewer_darwin.dart';
import 'package:flutter/foundation.dart';

/// The native PDF API. Implemented over JNI on Android ([AndroidEasyPdfViewer]) and over the Objective-C runtime on
/// iOS and macOS ([DarwinEasyPdfViewer]); a call fails with `NativeFailure`. Tests install a fake via [instance].
abstract interface class EasyPdfViewerPlatform {
  /// The platform implementation, created on first use unless a test has set one.
  static EasyPdfViewerPlatform get instance => _instance ??= _createDefault();

  @visibleForTesting
  static set instance(EasyPdfViewerPlatform? value) => _instance = value;

  static EasyPdfViewerPlatform? _instance;

  static EasyPdfViewerPlatform _createDefault() => switch (defaultTargetPlatform) {
    TargetPlatform.android => AndroidEasyPdfViewer(),
    TargetPlatform.iOS || TargetPlatform.macOS => DarwinEasyPdfViewer(),
    _ => throw UnsupportedError('easy_pdf_viewer does not support $defaultTargetPlatform'),
  };

  /// Page count of the PDF at [filePath]; optionally clears the rendered-page cache first.
  Future<int> getNumberOfPages(String filePath, {required bool clearCacheDir});

  /// Renders [pageNumber] (1-based) of the PDF at [filePath] to a PNG and returns its path.
  Future<String?> getPage(String filePath, int pageNumber);

  /// Deletes the rendered-page cache.
  Future<void> clearCacheDir();
}
