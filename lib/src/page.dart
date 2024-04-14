// ignore_for_file: unused_local_variable

import "dart:io";
import "package:easy_pdf_viewer/src/zoomable_widget.dart";
import "package:flutter/widgets.dart";

/// A class to represent PDF page
/// [imgPath], path of the image (pdf page)
/// [num], page number
/// [onZoomChanged], function called when zoom is changed
/// [zoomSteps], number of zoom steps on double tap
/// [minScale] minimum zoom scale
/// [maxScale] maximum zoom scale
/// [panLimit] limit for pan
class PDFPage extends StatefulWidget {
  const PDFPage(
    this.imgPath,
    this.num, {
    super.key,
    this.onZoomChanged,
    this.zoomSteps = 3,
    this.minScale = 1.0,
    this.maxScale = 5.0,
    this.panLimit = 1.0,
  });

  final String? imgPath;
  final int num;
  final void Function(double)? onZoomChanged;
  final int zoomSteps;
  final double minScale;
  final double maxScale;
  final double panLimit;

  @override
  State<PDFPage> createState() => _PDFPageState();
}

class _PDFPageState extends State<PDFPage> {
  late ImageProvider provider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _repaint();
  }

  @override
  void didUpdateWidget(PDFPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imgPath != widget.imgPath) {
      _repaint();
    }
  }

  void _repaint() {
    provider = FileImage(File(widget.imgPath!));
    final ImageStream resolver =
        provider.resolve(createLocalImageConfiguration(context))
          ..addListener(
            ImageStreamListener((ImageInfo imgInfo, bool alreadyPainted) {
              if (mounted && !alreadyPainted) {
                setState(() {});
              }
            }),
          );
  }

  @override
  Widget build(BuildContext context) => ZoomableWidget(
        onZoomChanged: widget.onZoomChanged,
        zoomSteps: widget.zoomSteps,
        minScale: widget.minScale,
        panLimit: widget.panLimit,
        maxScale: widget.maxScale,
        child: Image(image: provider),
      );
}
