# Dart reaches these classes only through JNI (lib/src/bindings), so R8 must keep their names and members.
-keep class uz.plugin.easy_pdf_viewer.EasyPdfViewerApi { *; }
-keep interface uz.plugin.easy_pdf_viewer.ResultCallback { *; }
