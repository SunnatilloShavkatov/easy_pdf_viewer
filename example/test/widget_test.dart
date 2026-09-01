// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:easy_pdf_viewer_example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Verify PDFViewer App loads', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const App());

    // Verify that the AppBar title is displayed.
    expect(find.text('PDFViewer'), findsOneWidget);
  });
}
