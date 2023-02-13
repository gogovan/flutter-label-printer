package hk.gogovan.flutter_label_printer.util

class Log {
    companion object {
        const val LOG_TAG = "FlutterLabelPrinter"
    }

    enum class LogLevel {
        VERBOSE, DEBUG, INFO, WARN, ERROR, ASSERT
    }

    var logLevel: LogLevel = LogLevel.INFO

    fun setLogLevel(level: Int) {
        val maxLevel = LogLevel.values().size
        val aLevel = if (level < 0) 0 else if (level > maxLevel) maxLevel else level
        logLevel = LogLevel.values()[aLevel]
    }

    fun v(msg: String) {
        if (logLevel <= LogLevel.VERBOSE) {
            android.util.Log.v(LOG_TAG, msg)
        }
    }

    fun d(msg: String) {
        if (logLevel <= LogLevel.DEBUG) {
            android.util.Log.d(LOG_TAG, msg)
        }
    }

    fun i(msg: String) {
        if (logLevel <= LogLevel.INFO) {
            android.util.Log.i(LOG_TAG, msg)
        }
    }

    fun w(msg: String) {
        if (logLevel <= LogLevel.WARN) {
            android.util.Log.w(LOG_TAG, msg)
        }
    }

    fun e(msg: String) {
        if (logLevel <= LogLevel.ERROR) {
            android.util.Log.e(LOG_TAG, msg)
        }
    }

    fun wtf(msg: String) {
        if (logLevel <= LogLevel.ASSERT) {
            android.util.Log.wtf(LOG_TAG, msg)
        }
    }

}