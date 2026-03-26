import 'dart:async';

import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:easy_pdf_viewer_example/with_progress.dart';
import 'package:flutter/material.dart';

const String _samplePdfUrl = 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf';

void main() {
  /// debugInvertOversizedImages
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(home: MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoading = true;
  String? _errorMessage;
  late PDFDocument document;

  @override
  void initState() {
    super.initState();
    unawaited(loadDocument());
  }

  Future<void> loadDocument() async {
    try {
      document = await PDFDocument.fromAsset('assets/sample.pdf');
      setState(() {
        _errorMessage = null;
        _isLoading = false;
      });
    } on Exception catch (error) {
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> changePDF(int value) async {
    setState(() => _isLoading = true);
    try {
      if (value == 1) {
        document = await PDFDocument.fromAsset('assets/sample2.pdf');
      } else if (value == 2) {
        document = await PDFDocument.fromURL(_samplePdfUrl);
      } else {
        document = await PDFDocument.fromAsset('assets/sample.pdf');
      }
      setState(() {
        _errorMessage = null;
        _isLoading = false;
      });
    } on Exception catch (error) {
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    drawer: Drawer(
      child: Column(
        children: <Widget>[
          const SizedBox(height: 36),
          ListTile(
            title: const Text('Load from Assets'),
            onTap: () async {
              await changePDF(1);
            },
          ),
          ListTile(
            title: const Text('Load from URL'),
            onTap: () async {
              await changePDF(2);
            },
          ),
          ListTile(
            title: const Text('Restore default'),
            onTap: () async {
              await changePDF(3);
            },
          ),
          ListTile(
            title: const Text('With Progress'),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (BuildContext context) => const WithProgress()),
              );
            },
          ),
        ],
      ),
    ),
    appBar: AppBar(title: const Text('PDFViewer')),
    body: Center(
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Padding(
              padding: const EdgeInsets.all(24),
              child: Text(_errorMessage!, textAlign: TextAlign.center),
            )
          : PDFViewer(
              document: document,
              lazyLoad: false,
              zoomSteps: 1,
              numberPickerConfirmWidget: const Text('Confirm'),
            ),
    ),
  );
}
