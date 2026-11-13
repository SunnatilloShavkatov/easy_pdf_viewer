package uz.plugin.easy_pdf_viewer

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding

/**
 * Registration only: Dart calls [EasyPdfViewerApi] through JNI, so there is no channel to set up. The plugin
 * hands the application context to the facade.
 */
class EasyPdfViewerPlugin : FlutterPlugin {
    override fun onAttachedToEngine(binding: FlutterPluginBinding) {
        EasyPdfViewerApi.attach(binding.applicationContext)
    }

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        EasyPdfViewerApi.detach()
    }
}
