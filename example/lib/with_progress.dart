import 'dart:async';

import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:material_ui/material_ui.dart';

const String _samplePdfUrl = 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf';

class WithProgress extends StatefulWidget {
  const new({super.key});

  @override
  State<WithProgress> createState() => _WithProgressState();
}

class _WithProgressState extends State<WithProgress> {
  bool _isLoading = true;
  String? _errorMessage;
  late PDFDocument document;
  DownloadProgress? downloadProgress;

  @override
  void initState() {
    super.initState();
    unawaited(loadDocument());
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future<void> loadDocument() async {
    /// Clears the cache before download, so
    /// [PDFDocument.fromURLWithDownloadProgress.downloadProgress()]
    /// is always executed (meant only for testing).
    await DefaultCacheManager().emptyCache();

    PDFDocument.fromURLWithDownloadProgress(
      _samplePdfUrl,
      downloadProgress: (DownloadProgress downloadProgress) => setState(() {
        this.downloadProgress = downloadProgress;
        _errorMessage = null;
      }),
      onDownloadComplete: (PDFDocument document) => setState(() {
        this.document = document;
        _errorMessage = null;
        _isLoading = false;
      }),
      onDownloadError: (Object error) => setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      }),
    );
  }

  Widget buildProgress() {
    if (downloadProgress == null) {
      return const SizedBox();
    }

    String parseBytesToKBs(int? bytes) {
      if (bytes == null) {
        return '0 KBs';
      }

      return '${(bytes / 1000).toStringAsFixed(2)} KBs';
    }

    String progressString = parseBytesToKBs(downloadProgress!.downloaded);
    if (downloadProgress!.totalSize != null) {
      progressString += '/ ${parseBytesToKBs(downloadProgress!.totalSize)}';
    }

    return Column(children: <Widget>[const SizedBox(height: 20), Text(progressString)]);
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
            onTap: () {
              unawaited(changePDF(1));
            },
          ),
          ListTile(
            title: const Text('Load from URL'),
            onTap: () {
              unawaited(changePDF(2));
            },
          ),
          ListTile(
            title: const Text('Restore default'),
            onTap: () {
              unawaited(changePDF(3));
            },
          ),
          ListTile(
            title: const Text('With Progress'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute<void>(builder: (BuildContext context) => const WithProgress()));
            },
          ),
        ],
      ),
    ),
    appBar: AppBar(title: const Text('PDFViewer')),
    body: SafeArea(
      child: _isLoading
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[const CircularProgressIndicator(), buildProgress()],
              ),
            )
          : _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(_errorMessage!, textAlign: TextAlign.center),
              ),
            )
          : PDFViewer(document: document, numberPickerConfirmWidget: const Text('Confirm')),
    ),
  );
}
