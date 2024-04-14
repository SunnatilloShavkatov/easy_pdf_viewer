// ignore_for_file: discarded_futures

import "package:easy_pdf_viewer/easy_pdf_viewer.dart";
import "package:easy_pdf_viewer/src/page_picker.dart";
import "package:flutter/material.dart";

/// enum to describe indicator position
enum IndicatorPosition { topLeft, topRight, bottomLeft, bottomRight }

/// PDFViewer, a inbuild pdf viewer, you can create your own too.
/// [document] an instance of `PDFDocument`, document to be loaded
/// [indicatorText] color of indicator text
/// [indicatorBackground] color of indicator background
/// [pickerButtonColor] the picker button background color
/// [pickerIconColor] the picker button icon color
/// [indicatorPosition] position of the indicator position defined by
/// `IndicatorPosition` enum
/// [showIndicator] show,hide indicator
/// [showPicker] show hide picker
/// [showNavigation] show hide navigation bar
/// [toolTip] tooltip, instance of `PDFViewerTooltip`
/// [enableSwipeNavigation] enable,disable swipe navigation
/// [scrollDirection] scroll direction horizontal or vertical
/// [lazyLoad] lazy load pages or load all at once
/// [controller] page controller to control page viewer
/// [zoomSteps] zoom steps for pdf page
/// [minScale] minimum zoom scale for pdf page
/// [maxScale] maximum zoom scale for pdf page
/// [panLimit] pan limit for pdf page
/// [onPageChanged] function called when page changes
///
class PDFViewer extends StatefulWidget {
  const PDFViewer({
    super.key,
    required this.document,
    this.scrollDirection,
    this.lazyLoad = true,
    this.indicatorText = Colors.white,
    this.indicatorBackground = Colors.black54,
    this.numberPickerConfirmWidget = const Text("OK"),
    this.showIndicator = true,
    this.showPicker = true,
    this.showNavigation = true,
    this.enableSwipeNavigation = true,
    this.tooltip = const PDFViewerTooltip(),
    this.navigationBuilder,
    this.controller,
    this.indicatorPosition = IndicatorPosition.topRight,
    this.zoomSteps,
    this.minScale,
    this.maxScale,
    this.panLimit,
    this.progressIndicator,
    this.pickerButtonColor,
    this.pickerIconColor,
    this.onPageChanged,
    this.backgroundColor,
    this.indicatorBuilder,
    this.onZoomChanged,
    this.resizeToAvoidBottomInset = true,
  });

  final PDFDocument document;
  final Color indicatorText;
  final Color indicatorBackground;
  final Color? pickerButtonColor;
  final Color? pickerIconColor;
  final IndicatorPosition indicatorPosition;
  final Widget numberPickerConfirmWidget;
  final bool showIndicator;
  final bool showPicker;
  final bool showNavigation;
  final PDFViewerTooltip tooltip;
  final bool enableSwipeNavigation;
  final Axis? scrollDirection;
  final bool lazyLoad;
  final PageController? controller;
  final int? zoomSteps;
  final double? minScale;
  final double? maxScale;
  final double? panLimit;
  final ValueChanged<int>? onPageChanged;
  final Color? backgroundColor;
  final void Function(double)? onZoomChanged;
  final bool? resizeToAvoidBottomInset;

  final Widget Function(
    BuildContext,
    int? pageNumber,
    int? totalPages,
    void Function({int page}) jumpToPage,
    void Function({int? page}) animateToPage,
  )? navigationBuilder;

  final Widget? progressIndicator;

  final Widget Function(BuildContext, int? pageNumber, int? totalPages)?
      indicatorBuilder;

  @override
  State<PDFViewer> createState() => _PDFViewerState();
}

class _PDFViewerState extends State<PDFViewer> {
  bool _isLoading = true;
  late int _pageNumber;
  bool _swipeEnabled = true;
  List<PDFPage?>? _pages;
  late PageController _pageController;
  final Duration animationDuration = const Duration(milliseconds: 200);
  final Curve animationCurve = Curves.easeIn;

  @override
  void initState() {
    super.initState();
    _pages = List<PDFPage?>.filled(widget.document.count, null);
    _pageController = widget.controller ?? PageController();
    _pageNumber = _pageController.initialPage + 1;
    if (!widget.lazyLoad) {
      _preloadPages();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pageNumber = _pageController.initialPage + 1;
    _isLoading = true;
    _pages = List<PDFPage?>.filled(widget.document.count, null);
    // _loadAllPages();
    _loadPage();
  }

  @override
  void didUpdateWidget(PDFViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  void onZoomChanged(double scale) {
    widget.onZoomChanged?.call(scale);

    if (scale != 1.0) {
      setState(() {
        _swipeEnabled = false;
      });
    } else {
      setState(() {
        _swipeEnabled = true;
      });
    }
  }

  Future<void> _preloadPages() async {
    int countvar = 1;
    for (final void _ in List<PDFPage?>.filled(widget.document.count, null)) {
      final PDFPage data = await widget.document.get(
        page: countvar,
        onZoomChanged: onZoomChanged,
        zoomSteps: widget.zoomSteps,
        minScale: widget.minScale,
        maxScale: widget.maxScale,
        panLimit: widget.panLimit,
      );
      _pages![countvar - 1] = data;

      countvar++;
    }
  }

  Future<void> _loadPage() async {
    if (_pages![_pageNumber - 1] != null) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    final PDFPage data = await widget.document.get(
      page: _pageNumber,
      onZoomChanged: onZoomChanged,
      zoomSteps: widget.zoomSteps,
      minScale: widget.minScale,
      maxScale: widget.maxScale,
      panLimit: widget.panLimit,
    );
    _pages![_pageNumber - 1] = data;
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _animateToPage({int? page}) {
    _pageController.animateToPage(
      page ?? _pageNumber - 1,
      duration: animationDuration,
      curve: animationCurve,
    );
  }

  void _jumpToPage({int? page}) {
    _pageController.jumpToPage(page ?? _pageNumber - 1);
  }

  Widget _drawIndicator() {
    if (widget.indicatorBuilder != null) {
      return widget.indicatorBuilder!(
        context,
        _pageNumber,
        widget.document.count,
      );
    }

    final Widget child = GestureDetector(
      onTap: widget.showPicker && widget.document.count > 1 ? _pickPage : null,
      child: Container(
        padding: const EdgeInsets.only(top: 4, left: 16, bottom: 4, right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: widget.indicatorBackground,
        ),
        child: Text(
          "$_pageNumber/${widget.document.count}",
          style: TextStyle(
            color: widget.indicatorText,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );

    switch (widget.indicatorPosition) {
      case IndicatorPosition.topLeft:
        return Positioned(top: 20, left: 20, child: child);
      case IndicatorPosition.topRight:
        return Positioned(top: 20, right: 20, child: child);
      case IndicatorPosition.bottomLeft:
        return Positioned(bottom: 20, left: 20, child: child);
      case IndicatorPosition.bottomRight:
        return Positioned(bottom: 20, right: 20, child: child);
    }
  }

  void _pickPage() {
    showDialog<int>(
      context: context,
      builder: (BuildContext context) => PagePicker(
        title: widget.tooltip.pick,
        maxValue: widget.document.count,
        initialValue: _pageNumber,
        numberPickerConfirmWidget: widget.numberPickerConfirmWidget,
      ),
    ).then((int? value) {
      if (value != null) {
        _pageNumber = value;
        _jumpToPage();
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
        backgroundColor: widget.backgroundColor,
        body: Stack(
          children: <Widget>[
            PageView.builder(
              physics:
                  _swipeEnabled && widget.enableSwipeNavigation && !_isLoading
                      ? null
                      : const NeverScrollableScrollPhysics(),
              onPageChanged: (int page) {
                setState(() {
                  _pageNumber = page + 1;
                });
                _loadPage();
                widget.onPageChanged?.call(page);
              },
              scrollDirection: widget.scrollDirection ?? Axis.horizontal,
              controller: _pageController,
              itemCount: _pages?.length ?? 0,
              itemBuilder: (BuildContext context, int index) =>
                  _pages![index] == null
                      ? Center(
                          child: widget.progressIndicator ??
                              const CircularProgressIndicator(),
                        )
                      : _pages![index]!,
            ),
            if (widget.showIndicator && !_isLoading)
              _drawIndicator()
            else
              const SizedBox.shrink(),
          ],
        ),
        floatingActionButton: widget.showPicker && widget.document.count > 1
            ? FloatingActionButton(
                elevation: 4,
                tooltip: widget.tooltip.jump,
                backgroundColor: widget.pickerButtonColor ?? Colors.blue,
                onPressed: _pickPage,
                child: Icon(
                  Icons.view_carousel,
                  color: widget.pickerIconColor ?? Colors.white,
                ),
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: (widget.showNavigation &&
                widget.document.count > 1)
            ? widget.navigationBuilder != null
                ? widget.navigationBuilder!(
                    context,
                    _pageNumber,
                    widget.document.count,
                    _jumpToPage,
                    _animateToPage,
                  )
                : BottomAppBar(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: IconButton(
                            icon: const Icon(Icons.first_page),
                            tooltip: widget.tooltip.first,
                            onPressed: _pageNumber == 1 || _isLoading
                                ? null
                                : () {
                                    _pageNumber = 1;
                                    _jumpToPage();
                                  },
                          ),
                        ),
                        Expanded(
                          child: IconButton(
                            icon: const Icon(Icons.chevron_left),
                            tooltip: widget.tooltip.previous,
                            onPressed: _pageNumber == 1 || _isLoading
                                ? null
                                : () {
                                    _pageNumber--;
                                    if (1 > _pageNumber) {
                                      _pageNumber = 1;
                                    }
                                    _animateToPage();
                                  },
                          ),
                        ),
                        if (widget.showPicker)
                          const Expanded(child: Text(""))
                        else
                          const SizedBox(width: 1),
                        Expanded(
                          child: IconButton(
                            icon: const Icon(Icons.chevron_right),
                            tooltip: widget.tooltip.next,
                            onPressed: _pageNumber == widget.document.count ||
                                    _isLoading
                                ? null
                                : () {
                                    _pageNumber++;
                                    if (widget.document.count < _pageNumber) {
                                      _pageNumber = widget.document.count;
                                    }
                                    _animateToPage();
                                  },
                          ),
                        ),
                        Expanded(
                          child: IconButton(
                            icon: const Icon(Icons.last_page),
                            tooltip: widget.tooltip.last,
                            onPressed: _pageNumber == widget.document.count ||
                                    _isLoading
                                ? null
                                : () {
                                    _pageNumber = widget.document.count;
                                    _jumpToPage();
                                  },
                          ),
                        ),
                      ],
                    ),
                  )
            : const SizedBox.shrink(),
      );
}
