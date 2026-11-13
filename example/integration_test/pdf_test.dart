import 'dart:io';

import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('opens a bundled PDF, renders a page to a PNG and clears the cache', (WidgetTester tester) async {
    final PDFDocument document = await PDFDocument.fromAsset('assets/sample.pdf');
    expect(document.count, greaterThan(0));

    final PDFPage first = await document.get();
    final File png = File(first.imgPath!);
    expect(png.existsSync(), isTrue);
    expect(png.lengthSync(), greaterThan(1000));
    expect(png.readAsBytesSync().sublist(1, 4), <int>[0x50, 0x4E, 0x47]);

    // A page number past the end is clamped to the last page.
    final PDFPage last = await document.get(page: document.count + 5);
    expect(File(last.imgPath!).existsSync(), isTrue);

    await PDFDocument.clearPreviewCache();
    expect(png.existsSync(), isFalse);
  });

  testWidgets('a missing file fails with an Exception', (WidgetTester tester) async {
    await expectLater(PDFDocument.fromFile(File('/definitely/missing.pdf')), throwsA(isA<Exception>()));
  });

  testWidgets('many calls in a row all complete (callbacks are answered once)', (WidgetTester tester) async {
    final PDFDocument document = await PDFDocument.fromAsset('assets/sample.pdf');
    for (int i = 0; i < 30; i++) {
      final PDFPage page = await document.get();
      expect(File(page.imgPath!).existsSync(), isTrue);
    }
  });
}
