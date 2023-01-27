package hk.gogovan.flutter_label_printer

import android.app.Activity
import androidx.annotation.NonNull
import hk.gogovan.flutter_label_printer.searcher.BluetoothSearcher
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

/** FlutterLabelPrinterPlugin */
class FlutterLabelPrinterPlugin : FlutterPlugin, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var bluetoothScanChannel: EventChannel

    private var bluetoothSearcher: BluetoothSearcher? = null
    private var bluetoothScanStreamHandler: BluetoothScanStreamHandler? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        val context = flutterPluginBinding.applicationContext

        bluetoothSearcher = BluetoothSearcher(context)
        bluetoothScanStreamHandler = BluetoothScanStreamHandler(bluetoothSearcher)

        channel =
            MethodChannel(flutterPluginBinding.binaryMessenger, "com.gogovan/flutter_label_printer")
        channel.setMethodCallHandler { call, result ->
            try {
                if (call.method == "com.gogovan/stopSearchHMA300L") {
                    val response = bluetoothSearcher?.stopScan()
                    result.success(response)
                } else {
                    result.notImplemented()
                }
            } catch (e: PluginException) {
                result.error(e.code.toString(), e.message, e.stackTraceToString())
            }
        }

        bluetoothScanChannel =
            EventChannel(flutterPluginBinding.binaryMessenger, "com.gogovan/bluetoothScan")
        bluetoothScanChannel.setStreamHandler(bluetoothScanStreamHandler)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)

        bluetoothSearcher?.close()
        bluetoothSearcher = null

        bluetoothScanStreamHandler?.close()
        bluetoothScanStreamHandler = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        bluetoothScanStreamHandler?.setCurrentActivity(binding.activity)

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
        bluetoothScanStreamHandler?.setCurrentActivity(null)
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        bluetoothScanStreamHandler?.setCurrentActivity(binding.activity)
    }

    override fun onDetachedFromActivity() {
        bluetoothScanStreamHandler?.setCurrentActivity(null)
    }

}
