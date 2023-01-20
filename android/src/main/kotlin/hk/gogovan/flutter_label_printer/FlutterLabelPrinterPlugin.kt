package hk.gogovan.flutter_label_printer

import android.app.Activity
import android.content.Context
import android.os.Handler
import android.os.Looper
import androidx.annotation.NonNull
import hk.gogovan.flutter_label_printer.searcher.BluetoothSearcher
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.cancel
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.launch

/** FlutterLabelPrinterPlugin */
class FlutterLabelPrinterPlugin : FlutterPlugin, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var bluetoothScanChannel: EventChannel

    private var context: Context? = null
    private var currentActivity: Activity? = null
    private lateinit var coroutineScope: CoroutineScope

    private var bluetoothSearcher: BluetoothSearcher? = null

    private val pluginExceptionFlow = MutableSharedFlow<PluginException>()

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        val context = flutterPluginBinding.applicationContext
        this.context = context

        coroutineScope = CoroutineScope(Dispatchers.IO)

        bluetoothSearcher = BluetoothSearcher(context)

        channel =
            MethodChannel(flutterPluginBinding.binaryMessenger, "com.gogovan/flutter_label_printer")
        channel.setMethodCallHandler { call, result ->
            result.notImplemented()
        }

        bluetoothScanChannel =
            EventChannel(flutterPluginBinding.binaryMessenger, "com.gogovan/bluetoothScan")
        bluetoothScanChannel.setStreamHandler(object : EventChannel.StreamHandler {
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
                                        events?.error("1004", valueOrError.error?.message, valueOrError.error?.stackTraceToString())
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

        })
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        context = null
        coroutineScope.cancel()
        bluetoothSearcher = null
        currentActivity = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        currentActivity = binding.activity
        binding.addActivityResultListener { requestCode, resultCode, _ ->
            bluetoothSearcher?.handleActivityResult(
                requestCode,
                resultCode
            )
            true
        }
        binding.addRequestPermissionsResultListener { requestCode, permissions, grantResults ->
            bluetoothSearcher?.handlePermissionResult(
                requestCode,
                permissions,
                grantResults
            )
            true
        }

    }

    override fun onDetachedFromActivityForConfigChanges() {
        currentActivity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        currentActivity = binding.activity
    }

    override fun onDetachedFromActivity() {
        currentActivity = null
    }

}
