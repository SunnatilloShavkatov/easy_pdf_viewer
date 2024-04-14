package dev.kaichi.easy_pdf_viewer

import android.annotation.SuppressLint
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.pdf.PdfRenderer
import android.os.Handler
import android.os.HandlerThread
import android.os.Looper
import android.os.ParcelFileDescriptor
import android.os.Process
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import java.io.File
import java.io.FileOutputStream
import java.io.FilenameFilter
import java.util.Locale


/**
 * EasyPdfViewerPlugin
 */
class EasyPdfViewerPlugin : FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native
    /// Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine
    /// and unregister it
    /// when the Flutter Engine is detached from the Activity
    private var channel: MethodChannel? = null
    private var instance: FlutterPluginBinding? = null
    private var backgroundHandler: Handler? = null
    private val pluginLocker = Any()
    private val filePrefix = "FlutterEasyPdfViewerPlugin"
    override fun onAttachedToEngine(flutterPluginBinding: FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "easy_pdf_viewer_plugin")
        channel!!.setMethodCallHandler(this)
        instance = flutterPluginBinding
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        synchronized(pluginLocker) {
            if (backgroundHandler == null) {
                val handlerThread = HandlerThread(
                    "flutterEasyPdfViewer",
                    Process.THREAD_PRIORITY_BACKGROUND
                )
                handlerThread.start()
                backgroundHandler = Handler(handlerThread.looper)
            }
        }
        val mainLooper = Looper.getMainLooper()
        val mainThreadHandler = Handler(mainLooper)

        backgroundHandler!!.post {
            when (call.method) {
                "getNumberOfPages" -> {
                    val numResult = getNumberOfPages(
                        call.argument("filePath"),
                        call.argument("clearCacheDir")!!
                    )
                    mainThreadHandler.post { result.success(numResult) }
                }

                "getPage" -> {
                    val pageRes = getPage(
                        call.argument("filePath"),
                        call.argument("pageNumber")!!
                    )
                    mainThreadHandler.post { result.success(pageRes) }
                }

                "clearCacheDir" -> {
                    clearCacheDir()
                    mainThreadHandler.post { result.success(null) }
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun clearCacheDir() {
        try {
            val directory = instance!!.applicationContext.cacheDir
            val myFilter =
                FilenameFilter { _: File?, name: String ->
                    name.lowercase(
                        Locale.getDefault()
                    ).startsWith(filePrefix.lowercase(Locale.getDefault()))
                }
            val files = directory.listFiles(myFilter)!!
            for (file in files) {
                file.delete()
            }
        } catch (ex: Exception) {
            println("Error: " + ex.message)
        }
    }

    @SuppressLint("DefaultLocale")
    private fun getNumberOfPages(filePath: String?, clearCacheDir: Boolean): String? {
        val pdf = filePath?.let { File(it) }
        try {
            if (clearCacheDir) {
                clearCacheDir()
            }
            PdfRenderer(
                ParcelFileDescriptor.open(
                    pdf,
                    ParcelFileDescriptor.MODE_READ_ONLY
                )
            ).use { renderer ->
                val pageCount = renderer.getPageCount()
                return String.format("%d", pageCount)
            }
        } catch (ex: Exception) {
            println("Error: " + ex.message)
        }
        return null
    }

    private fun getFileNameFromPath(name: String?): String {
        var filePath = name!!.substring(name.lastIndexOf('/') + 1)
        filePath = filePath.substring(0, filePath.lastIndexOf('.'))
        return String.format("%s-%s", filePrefix, filePath)
    }

    private fun createTempPreview(bmp: Bitmap, name: String?, page: Int): String? {
        val fileNameOnly = getFileNameFromPath(name)
        val file: File
        try {
            @SuppressLint("DefaultLocale") val fileName =
                String.format("%s-%d.png", fileNameOnly, page)
            file = File.createTempFile(fileName, null, instance!!.applicationContext.cacheDir)
            val out = FileOutputStream(file)
            bmp.compress(Bitmap.CompressFormat.PNG, 100, out)
            out.flush()
            out.close()
        } catch (ex: Exception) {
            println("Error: " + ex.message)
            return null
        }
        return file.absolutePath
    }

    private fun getPage(filePath: String?, pageNumber: Int): String? {
        var pageNumber0 = pageNumber
        val pdf = filePath?.let { File(it) }
        try {
            val renderer =
                PdfRenderer(ParcelFileDescriptor.open(pdf, ParcelFileDescriptor.MODE_READ_ONLY))
            val pageCount = renderer.getPageCount()
            if (pageNumber > pageCount) {
                pageNumber0 = pageCount
            }
            val page = renderer.openPage(--pageNumber0)
            var width = page.width.toDouble()
            var height = page.height.toDouble()
            val docRatio = width / height
            width = 2048.0
            height = (width / docRatio).toInt().toDouble()
            val bitmap = Bitmap.createBitmap(width.toInt(), height.toInt(), Bitmap.Config.ARGB_8888)
            val canvas = Canvas(bitmap)
            canvas.drawColor(Color.WHITE)
            page.render(bitmap, null, null, PdfRenderer.Page.RENDER_MODE_FOR_DISPLAY)
            return try {
                createTempPreview(bitmap, filePath, pageNumber)
            } finally {
                page.close()
                renderer.close()
            }
        } catch (ex: Exception) {
            println(ex.message)
        }
        return null
    }

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        channel!!.setMethodCallHandler(null)
        instance = null
    }
}
