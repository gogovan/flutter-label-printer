package hk.gogovan.flutter_label_printer

import android.app.Activity
import android.os.Handler
import android.os.Looper
import hk.gogovan.flutter_label_printer.searcher.BluetoothSearcher
import io.flutter.plugin.common.EventChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.cancel
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.launch

class BluetoothScanStreamHandler(
    private val bluetoothSearcher: BluetoothSearcher?,
    private val currentActivity: Activity?
) : EventChannel.StreamHandler {
    private val pluginExceptionFlow = MutableSharedFlow<PluginException>()
    private val coroutineScope: CoroutineScope = CoroutineScope(Dispatchers.IO)

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        coroutineScope.launch {
            try {
                bluetoothSearcher?.scan(currentActivity)?.collect { valueOrError ->
                    Handler(Looper.getMainLooper()).post {
                        if (valueOrError.value != null) {
                            events?.success(valueOrError.value)
                        } else {
                            if (valueOrError.error is PluginException) {
                                events?.error(
                                    valueOrError.error.code.toString(),
                                    valueOrError.error.message,
                                    valueOrError.error.stackTraceToString()
                                )
                            } else {
                                events?.error(
                                    "1004",
                                    valueOrError.error?.message,
                                    valueOrError.error?.stackTraceToString()
                                )
                            }
                        }
                    }
                }
            } catch (ex: PluginException) {
                Handler(Looper.getMainLooper()).post {
                    events?.error(ex.code.toString(), ex.message, ex.stackTraceToString())
                }
            }
        }

        coroutineScope.launch {
            pluginExceptionFlow.collect { ex ->
                Handler(Looper.getMainLooper()).post {
                    events?.error(ex.code.toString(), ex.message, ex.stackTraceToString())
                }
            }
        }
    }

    override fun onCancel(arguments: Any?) {

    }

    fun close() {
        coroutineScope.cancel()
    }
}