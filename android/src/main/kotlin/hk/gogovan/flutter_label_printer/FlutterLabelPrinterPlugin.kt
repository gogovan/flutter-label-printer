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

    private var currentActivity: Activity? = null

    private var bluetoothSearcher: BluetoothSearcher? = null
    private var bluetoothScanStreamHandler: BluetoothScanStreamHandler? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        val context = flutterPluginBinding.applicationContext

        bluetoothSearcher = BluetoothSearcher(context)
        bluetoothScanStreamHandler = BluetoothScanStreamHandler(bluetoothSearcher, currentActivity)

        channel =
            MethodChannel(flutterPluginBinding.binaryMessenger, "com.gogovan/flutter_label_printer")
        channel.setMethodCallHandler { call, result ->
            result.notImplemented()
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
