import 'dart:io';

import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:easy_pdf_viewer/src/easy_pdf_viewer_platform.dart';
import 'package:easy_pdf_viewer/src/native_bridge.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakePlatform implements EasyPdfViewerPlatform {
  final List<String> log = <String>[];

  @override
  Future<int> getNumberOfPages(String filePath, {required bool clearCacheDir}) async {
    log.add('getNumberOfPages $filePath clear=$clearCacheDir');
    return 5;
  }

  @override
  Future<String?> getPage(String filePath, int pageNumber) async {
    log.add('getPage $filePath $pageNumber');
    return '/dummy/cache/path/EasyPdfViewer/test-$pageNumber.png';
  }

  @override
  Future<void> clearCacheDir() async {
    log.add('clearCacheDir');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakePlatform fake;

  setUp(() {
    fake = _FakePlatform();
    EasyPdfViewerPlatform.instance = fake;
  });

  tearDown(() {
    EasyPdfViewerPlatform.instance = null;
  });

  test('PDFViewerTooltip has expected default strings', () {
    const PDFViewerTooltip tooltip = PDFViewerTooltip();
    expect(tooltip.first, 'First');
    expect(tooltip.previous, 'Previous');
    expect(tooltip.next, 'Next');
    expect(tooltip.last, 'Last');
    expect(tooltip.pick, 'Pick a page');
    expect(tooltip.jump, 'Jump');
  });

  test('PDFDocument fromFile loads page count correctly through the platform', () async {
    final PDFDocument doc = await PDFDocument.fromFile(File('/test/sample.pdf'));
    expect(doc.count, 5);
    expect(doc.filePath, '/test/sample.pdf');
    expect(fake.log, <String>['getNumberOfPages /test/sample.pdf clear=true']);
  });

  test('PDFDocument get page returns valid PDFPage', () async {
    final PDFDocument doc = await PDFDocument.fromFile(File('/test/sample.pdf'));
    final PDFPage page = await doc.get();
    expect(page.num, 1);
    expect(page.imgPath, '/dummy/cache/path/EasyPdfViewer/test-1.png');
  });

  test('PDFDocument clearPreviewCache calls the platform', () async {
    await PDFDocument.clearPreviewCache();
    expect(fake.log, <String>['clearCacheDir']);
  });

  test('PDFDocument getAll streams every page in order', () async {
    final PDFDocument doc = await PDFDocument.fromFile(File('/test/sample.pdf'));
    final List<PDFPage?> pages = await doc.getAll().toList();
    expect(pages.map((PDFPage? p) => p!.num), <int>[1, 2, 3, 4, 5]);
    expect(fake.log.last, 'getPage /test/sample.pdf 5');
  });

  test('PDFDocument fromFile maps a native failure to Exception', () async {
    EasyPdfViewerPlatform.instance = _FailingPlatform();
    await expectLater(PDFDocument.fromFile(File('/missing.pdf')), throwsA(isA<Exception>()));
  });
}

class _FailingPlatform extends _FakePlatform {
  @override
  Future<int> getNumberOfPages(String filePath, {required bool clearCacheDir}) =>
      Future<int>.error(const NativeFailure(code: 'IO_ERROR', message: 'x'));
}
