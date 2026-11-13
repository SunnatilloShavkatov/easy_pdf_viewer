package uz.plugin.easy_pdf_viewer

/**
 * Completion of one facade call, delivered from any thread. Dart implements it through JNI with `$async` handlers,
 * so native code never waits on Dart. Values are encoded as [String].
 */
interface ResultCallback {
    fun success(value: String?)

    fun error(code: String, message: String, details: String?)
}
