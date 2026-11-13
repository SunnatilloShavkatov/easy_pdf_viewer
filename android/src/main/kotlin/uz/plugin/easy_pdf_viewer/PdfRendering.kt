package uz.plugin.easy_pdf_viewer

import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.pdf.PdfRenderer
import android.os.ParcelFileDescriptor
import java.io.File
import java.io.FileOutputStream

/** The blocking PDF work behind [EasyPdfViewerApi]; callers keep it off the platform thread. */
internal class PdfRendering(private val cacheDir: File) {

    fun pageCount(filePath: String): Int = open(filePath) { it.pageCount }

    fun renderPage(filePath: String, pageNumber: Int): String = open(filePath) { renderer ->
        val index = pageNumber.coerceIn(1, renderer.pageCount) - 1
        renderer.openPage(index).use { page ->
            val ratio = page.width.toDouble() / page.height
            val bitmap = Bitmap.createBitmap(TARGET_WIDTH, (TARGET_WIDTH / ratio).toInt(), Bitmap.Config.ARGB_8888)
            try {
                Canvas(bitmap).drawColor(Color.WHITE)
                page.render(bitmap, null, null, PdfRenderer.Page.RENDER_MODE_FOR_DISPLAY)
                writePng(bitmap, filePath, index + 1)
            } finally {
                bitmap.recycle()
            }
        }
    }

    fun clearCache() {
        cacheDir.listFiles { _, name -> name.startsWith(FILE_PREFIX, ignoreCase = true) }
            ?.forEach { it.delete() }
    }

    private fun writePng(bitmap: Bitmap, sourcePath: String, page: Int): String {
        val name = sourcePath.substringAfterLast('/').substringBeforeLast('.')
        val file = File.createTempFile("$FILE_PREFIX-$name-$page.png", null, cacheDir)
        FileOutputStream(file).use { out ->
            check(bitmap.compress(Bitmap.CompressFormat.PNG, 100, out)) { "PNG encoding failed" }
        }
        return file.absolutePath
    }

    private fun <T> open(filePath: String, block: (PdfRenderer) -> T): T =
        ParcelFileDescriptor.open(File(filePath), ParcelFileDescriptor.MODE_READ_ONLY).use { descriptor ->
            PdfRenderer(descriptor).use(block)
        }

    private companion object {
        const val FILE_PREFIX = "FlutterEasyPdfViewerPlugin"
        const val TARGET_WIDTH = 2048
    }
}
