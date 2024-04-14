// ignore_for_file: discarded_futures
// ignore_for_file: always_specify_types
// ignore_for_file: lines_longer_than_80_chars

import "dart:async";
import "dart:io";

import "package:easy_pdf_viewer/src/page.dart";
import "package:flutter/services.dart";
import "package:flutter_cache_manager/flutter_cache_manager.dart";
import "package:path_provider/path_provider.dart";

class PDFDocument {
  static const MethodChannel _channel = MethodChannel("easy_pdf_viewer_plugin");

  String? _filePath;
  late int count;
  final List<PDFPage> _pages = <PDFPage>[];
  bool _preloaded = false;

  /// expose file path for pdf sharing capabilities
  String? get filePath => _filePath;

  /// Load a PDF File from a given File
  /// [File file], file to be loaded
  ///
  /// Automatically clears the on-disk cache of previously rendered PDF previews
  /// unless [clearPreviewCache] is set to `false`. The option to disable it
  /// comes in handy when working with more than one document at the same time.
  /// If you do this, you are responsible for eventually clearing the cache by hand
  /// by calling [PDFDocument.clearPreviewCache].
  static Future<PDFDocument> fromFile(
    File file, {
    bool clearPreviewCache = true,
  }) async {
    final PDFDocument document = PDFDocument().._filePath = file.path;
    try {
      final pageCount = await _channel.invokeMethod(
        "getNumberOfPages",
        <String, Object>{
          "filePath": file.path,
          "clearCacheDir": clearPreviewCache,
        },
      );
      document.count = document.count = int.parse(pageCount);
    } on Exception catch (_) {
      throw Exception("Error reading PDF!");
    }
    return document;
  }

  /// Load a PDF File from a given URL.
  /// File is saved in cache
  ///
  /// [String url] url of the pdf file
  /// [Map<String,String headers] headers to pass for the [url]
  /// [CacheManager cacheManager] to provide configuration for
  /// cache management
  /// Automatically clears the on-disk cache of previously rendered PDF previews
  /// unless [clearPreviewCache] is set to `false`. The option to disable it
  /// comes in handy when working with more than one document at the same time.
  /// If you do this, you are responsible for eventually clearing the cache by hand
  /// by calling [PDFDocument.clearPreviewCache].
  static Future<PDFDocument> fromURL(
    String url, {
    Map<String, String>? headers,
    CacheManager? cacheManager,
    bool clearPreviewCache = true,
  }) async {
    // Download into cache
    final File f = await (cacheManager ?? DefaultCacheManager())
        .getSingleFile(url, headers: headers);
    final PDFDocument document = PDFDocument().._filePath = f.path;
    try {
      final pageCount = await _channel.invokeMethod(
        "getNumberOfPages",
        <String, dynamic>{
          "filePath": f.path,
          "clearCacheDir": clearPreviewCache,
        },
      );
      document.count = document.count = int.parse(pageCount);
    } on Exception catch (_) {
      throw Exception("Error reading PDF!");
    }
    return document;
  }

  /// Load a PDF File from a given URL, notifies download progress until completed
  /// File is saved in cache
  ///
  /// [String url] url of the pdf file
  /// [Map<String,String headers] headers to pass for the [url]
  /// [CacheManager cacheManager] to provide configuration for
  /// cache management
  /// Automatically clears the on-disk cache of previously rendered PDF previews
  /// unless [clearPreviewCache] is set to `false`. The option to disable it
  /// comes in handy when working with more than one document at the same time.
  /// If you do this, you are responsible for eventually clearing the cache by hand
  /// by calling [PDFDocument.clearPreviewCache].
  /// Use [downloadProgress] to get the download progress information. NOTE that
  /// [downloadProgress] is not called after [onDownloadComplete].
  /// Once the download is finished, [onDownloadComplete] is called. If the file
  /// is already available, [onDownloadComplete] is called directly.
  static void fromURLWithDownloadProgress(
    String url, {
    Map<String, String>? headers,
    CacheManager? cacheManager,
    bool clearPreviewCache = true,
    required void Function(DownloadProgress downloadProgress) downloadProgress,
    required void Function(PDFDocument document) onDownloadComplete,
  }) {
    StreamSubscription<FileResponse>? streamSubscription;
    final Stream<FileResponse> fileResponse =
        (cacheManager ?? DefaultCacheManager())
            .getFileStream(url, headers: headers, withProgress: true);

    streamSubscription = fileResponse.listen(
      (FileResponse event) async {
        if (event is DownloadProgress) {
          downloadProgress.call(event);
          return;
        }

        if (event is FileInfo) {
          final PDFDocument pdfDocument =
              await fromFile(event.file, clearPreviewCache: clearPreviewCache);
          onDownloadComplete.call(pdfDocument);
          unawaited(streamSubscription?.cancel());
          return;
        }
      },
    );
  }

  /// Load a PDF File from assets folder
  ///
  /// [String asset] path of the asset to be loaded
  /// Automatically clears the on-disk cache of previously rendered PDF previews
  /// unless [clearPreviewCache] is set to `false`. The option to disable it
  /// comes in handy when working with more than one document at the same time.
  /// If you do this, you are responsible for eventually clearing the cache by hand
  /// by calling [PDFDocument.clearPreviewCache].
  static Future<PDFDocument> fromAsset(
    String asset, {
    bool clearPreviewCache = true,
  }) async {
    // To open from assets, you can copy them to the app storage folder, and the access them "locally"
    File file;
    try {
      final Directory dir = await getApplicationDocumentsDirectory();
      file = File("${dir.path}/file.pdf");
      final ByteData data = await rootBundle.load(asset);
      final Uint8List bytes = data.buffer.asUint8List();
      await file.writeAsBytes(bytes, flush: true);
    } on Exception {
      throw Exception("Error parsing asset file!");
    }
    final PDFDocument document = PDFDocument().._filePath = file.path;
    try {
      final pageCount = await _channel.invokeMethod(
        "getNumberOfPages",
        <String, dynamic>{
          "filePath": file.path,
          "clearCacheDir": clearPreviewCache,
        },
      );
      document.count = document.count = int.parse(pageCount);
    } on Exception catch (_) {
      throw Exception("Error reading PDF!");
    }
    return document;
  }

  /// Clears an on-disk cache of previously rendered PDF previews.
  ///
  /// This is normally done automatically by methods such as [fromFile],
  /// [fromURL], and [fromAsset], unless they are run with the
  /// `clearPreviewCache` parameter set to `false`.
  static Future<void> clearPreviewCache() async {
    await _channel.invokeMethod("clearCacheDir");
  }

  /// Load specific page
  ///
  /// [page] defaults to `1` and must be equal or above it
  Future<PDFPage> get({
    int page = 1,
    void Function(double)? onZoomChanged,
    int? zoomSteps,
    double? minScale,
    double? maxScale,
    double? panLimit,
  }) async {
    assert(page > 0, "");
    if (_preloaded && _pages.isNotEmpty) {
      return _pages[page - 1];
    }
    final data = await _channel.invokeMethod(
      "getPage",
      <String, Object?>{"filePath": _filePath, "pageNumber": page},
    );
    return PDFPage(
      data,
      page,
      onZoomChanged: onZoomChanged,
      zoomSteps: zoomSteps ?? 3,
      minScale: minScale ?? 1.0,
      maxScale: maxScale ?? 5.0,
      panLimit: panLimit ?? 1.0,
    );
  }

  Future<void> preloadPages({
    void Function(double)? onZoomChanged,
    int? zoomSteps,
    double? minScale,
    double? maxScale,
    double? panLimit,
  }) async {
    int countvar = 1;
    for (final void _ in List.filled(count, null)) {
      final data = await _channel.invokeMethod(
        "getPage",
        <String, Object?>{"filePath": _filePath, "pageNumber": countvar},
      );
      _pages.add(
        PDFPage(
          data,
          countvar,
          onZoomChanged: onZoomChanged,
          zoomSteps: zoomSteps ?? 3,
          minScale: minScale ?? 1.0,
          maxScale: maxScale ?? 5.0,
          panLimit: panLimit ?? 1.0,
        ),
      );
      countvar++;
    }
    _preloaded = true;
  }

  // Stream all pages
  Stream<PDFPage?> getAll({void Function(double)? onZoomChanged}) =>
      Future.forEach<PDFPage?>(
        List<PDFPage?>.filled(count, null),
        (PDFPage? i) async {
          final data = await _channel.invokeMethod(
            "getPage",
            <String, Object?>{"filePath": _filePath, "pageNumber": i},
          );
          return PDFPage(
            data,
            1,
            onZoomChanged: onZoomChanged,
          );
        },
      ).asStream() as Stream<PDFPage?>;
}
