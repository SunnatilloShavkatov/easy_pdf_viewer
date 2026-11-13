package uz.plugin.easy_pdf_viewer

import kotlin.test.Test
import kotlin.test.assertEquals

class EasyPdfViewerApiTest {
    private class Recorder : ResultCallback {
        val codes = mutableListOf<String>()

        override fun success(value: String?) {
            codes += "success"
        }

        override fun error(code: String, message: String, details: String?) {
            codes += code
        }
    }

    @Test
    fun answersNotAttachedBeforeAnEngineAttaches() {
        val callback = Recorder()
        EasyPdfViewerApi.getNumberOfPages("/missing.pdf", false, callback)
        EasyPdfViewerApi.getPage("/missing.pdf", 1, callback)
        EasyPdfViewerApi.clearCacheDir(callback)
        assertEquals(listOf("NOT_ATTACHED", "NOT_ATTACHED", "NOT_ATTACHED"), callback.codes)
    }
}
