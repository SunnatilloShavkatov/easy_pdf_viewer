import 'dart:io';

import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const MethodChannel channel = MethodChannel('easy_pdf_viewer_plugin');

  TestWidgetsFlutterBinding.ensureInitialized();

  final List<MethodCall> log = <MethodCall>[];

  setUp(() {
    log.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'getNumberOfPages':
            return '5';
          case 'getPage':
            final int pageNumber = (methodCall.arguments as Map<dynamic, dynamic>)['pageNumber'] as int;
            return '/dummy/cache/path/EasyPdfViewer/test-$pageNumber.png';
          case 'clearCacheDir':
            return null;
          default:
            return null;
        }
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
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

  test('PDFDocument fromFile loads page count correctly via channel', () async {
    final PDFDocument doc = await PDFDocument.fromFile(File('/test/sample.pdf'));
    expect(doc.count, 5);
    expect(doc.filePath, '/test/sample.pdf');
    expect(log.length, 1);
    expect(log.first.method, 'getNumberOfPages');
  });

  test('PDFDocument get page returns valid PDFPage', () async {
    final PDFDocument doc = await PDFDocument.fromFile(File('/test/sample.pdf'));
    final PDFPage page = await doc.get();
    expect(page.num, 1);
    expect(page.imgPath, '/dummy/cache/path/EasyPdfViewer/test-1.png');
  });

  test('PDFDocument clearPreviewCache calls channel', () async {
    await PDFDocument.clearPreviewCache();
    expect(log.any((call) => call.method == 'clearCacheDir'), isTrue);
  });
}
