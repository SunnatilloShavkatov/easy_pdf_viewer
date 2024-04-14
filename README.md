# easy_pdf_viewer

A flutter plugin for handling PDF files. Works on both Android & iOS. Originally forked from (https://github.com/lohanidamodar/pdf_viewer).

[![Pub Package](https://img.shields.io/pub/v/easy_pdf_viewer.svg?style=flat-square)](https://pub.dartlang.org/packages/easy_pdf_viewer)


## Installation

```
> flutter pub add easy_pdf_viewer
```

---

## Android
No permissions required. Uses application cache directory.

## iOS
No permissions required.

## How-to:

#### Load PDF
```
// Load from assets
PDFDocument doc = await PDFDocument.fromAsset('assets/test.pdf');
 
// Load from URL
PDFDocument doc = await PDFDocument.fromURL('https://www.ecma-international.org/wp-content/uploads/ECMA-262_12th_edition_june_2021.pdf');

// Load from file
File file  = File('...');
PDFDocument doc = await PDFDocument.fromFile(file);
```

#### Load pages
```
// Load specific page
PDFPage pageOne = await doc.get(page: _number);
```

#### Pre-built viewer
Use the pre-built PDF Viewer
```
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Example'),
      ),
      body: Center(
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : PDFViewer(document: document)),
    );
  }
```

#### Third-party packages used

| Name                                                                                             | Description                                                                                                                               |
| ------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------- |
| [path_provider](https://pub.dartlang.org/packages/path_provider)                                 | A Flutter plugin for finding commonly used locations on the filesystem. Supports iOS and Android.                                         |
| [flutter_cache_manager](https://pub.dartlang.org/packages/flutter_cache_manager)                 | A CacheManager to download and cache files in the cache directory of the app. Various settings on how long to keep a file can be changed. |
| [numberpicker](https://pub.dartlang.org/packages/numberpicker)                                   | NumberPicker is a custom widget designed for choosing an integer or decimal number by scrolling spinners.                                 |
