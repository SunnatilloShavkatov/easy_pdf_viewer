// ignore_for_file: avoid_annotating_with_dynamic, discarded_futures

import "package:easy_pdf_viewer/easy_pdf_viewer.dart";
import "package:easy_pdf_viewer_example/with_progress.dart";
import "package:flutter/material.dart";

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const MaterialApp(
        home: MyApp(),
      );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key, this.progressExample = false}) : super(key: key);

  final bool progressExample;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoading = true;
  late PDFDocument document;

  @override
  void initState() {
    super.initState();
    loadDocument();
  }

  Future<void> loadDocument() async {
    document = await PDFDocument.fromAsset("assets/sample.pdf");

    setState(() => _isLoading = false);
  }

  Future<void> changePDF(dynamic value) async {
    setState(() => _isLoading = true);
    if (value == 1) {
      document = await PDFDocument.fromAsset("assets/sample2.pdf");
    } else if (value == 2) {
      document = await PDFDocument.fromURL(
        "https://www.africau.edu/images/default/sample.pdf",

        /* cacheManager: CacheManager(
          Config(
            "customCacheKey",
            stalePeriod: const Duration(days: 2),
            maxNrOfCacheObjects: 10,
          ),
        ), */
      );
    } else {
      document = await PDFDocument.fromAsset("assets/sample.pdf");
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        drawer: Drawer(
          child: Column(
            children: <Widget>[
              const SizedBox(height: 36),
              ListTile(
                title: const Text("Load from Assets"),
                onTap: () {
                  changePDF(1);
                },
              ),
              ListTile(
                title: const Text("Load from URL"),
                onTap: () {
                  changePDF(2);
                },
              ),
              ListTile(
                title: const Text("Restore default"),
                onTap: () {
                  changePDF(3);
                },
              ),
              ListTile(
                title: const Text("With Progress"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => const WithProgress(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        appBar: AppBar(
          title: const Text("PDFViewer"),
        ),
        body: Center(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : PDFViewer(
                  document: document,
                  lazyLoad: false,
                  zoomSteps: 1,
                  numberPickerConfirmWidget: const Text(
                    "Confirm",
                  ),
                ),
        ),
      );
}
