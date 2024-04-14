import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  const MethodChannel channel = MethodChannel("easy_pdf_viewer");

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async => "42");
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test("getPlatformVersion", () async {
    // expect(await EasyPdfViewer.platformVersion, '42');
  });
}
