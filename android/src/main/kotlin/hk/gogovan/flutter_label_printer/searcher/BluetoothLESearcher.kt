package hk.gogovan.flutter_label_printer.searcher

import android.Manifest
import android.annotation.SuppressLint
import android.app.Activity
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothManager
import android.bluetooth.le.ScanCallback
import android.bluetooth.le.ScanResult
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Handler
import android.os.Looper
import androidx.core.app.ActivityCompat
import hk.gogovan.flutter_label_printer.PluginException
import hk.gogovan.flutter_label_printer.util.ResultOr
import hk.gogovan.flutter_label_printer.util.checkSelfPermissions
import hk.gogovan.flutter_label_printer.util.exception.BluetoothScanException
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.cancel
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.launch
import java.io.Closeable

/**
 * Search for devices using Bluetooth Low Energy (BLE).
 */
class BluetoothLESearcher(private val context: Context) : Closeable {
    private val btManager: BluetoothManager =
        context.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager

    companion object {
        const val REQUEST_PERMISSION_CODE = 834
        const val REQUEST_ENABLE_CODE = 923
    }

    private val bluetoothEnabled = MutableSharedFlow<Boolean>()
    private val coroutineScope = CoroutineScope(Dispatchers.Default)
    private val ioScope = CoroutineScope(Dispatchers.IO)

    private fun getScanningPermissions(): Array<String> {
        return if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.S) {
            arrayOf(
                Manifest.permission.BLUETOOTH_SCAN,
                Manifest.permission.BLUETOOTH,
            )
        } else {
            arrayOf(
                Manifest.permission.BLUETOOTH,
                Manifest.permission.ACCESS_COARSE_LOCATION,
                Manifest.permission.ACCESS_FINE_LOCATION
            )
        }
    }

    @SuppressLint("MissingPermission")
    suspend fun scan(activity: Activity?): Flow<ResultOr<List<String>>> {
        checkBluetoothCapability()

        if (activity == null) {
            throw PluginException(1003, "No current activity.")
        } else {
            requestBluetooth(activity)
        }

        val resultFlow = MutableSharedFlow<ResultOr<List<String>>>()
        ioScope.launch {
            bluetoothEnabled.collect {
                if (context.checkSelfPermissions(getScanningPermissions()) != PackageManager.PERMISSION_GRANTED) {
                    // This should not happen as we have just scanned for Bluetooth!
                    throw PluginException(1002, "Bluetooth permission denied.")
                } else {
                    btManager.adapter.bluetoothLeScanner.startScan(object : ScanCallback() {
                        val currentResult = mutableSetOf<String>()

                        override fun onScanResult(callbackType: Int, result: ScanResult?) {
                            if (result != null) {
                                val address = result.device?.address
                                if (address != null) {
                                    coroutineScope.launch {
                                        currentResult.add(address)
                                        resultFlow.emit(ResultOr(currentResult.toList()))
                                    }
                                }
                            }
                        }

                        override fun onBatchScanResults(results: MutableList<ScanResult>?) {
                            if (results != null) {
                                val addresses = results.mapNotNull { it.device?.address }
                                if (addresses.isNotEmpty()) {
                                    coroutineScope.launch {
                                        currentResult.addAll(addresses)
                                        resultFlow.emit(ResultOr(currentResult.toList()))
                                    }
                                }
                            }
                        }

                        override fun onScanFailed(errorCode: Int) {
                            coroutineScope.launch {
                                resultFlow.emit(ResultOr(BluetoothScanException(errorCode)))
                            }
                        }
                    })
                }
            }
        }

        return resultFlow
    }

    fun handleActivityResult(requestCode: Int, resultCode: Int) {
        if (requestCode == REQUEST_ENABLE_CODE) {
            if (resultCode == Activity.RESULT_OK) {
                coroutineScope.launch {
                    bluetoothEnabled.emit(true)
                }
            } else {
                throw PluginException(1004, "Unable to enable Bluetooth")
            }
            return
        }
        throw PluginException(1000, "Unexpected program flow occurred.")
    }

    fun handlePermissionResult(
        requestCode: Int,
        permissions: Array<String>,
        grantResult: IntArray
    ) {
        if (requestCode == REQUEST_PERMISSION_CODE) {
            if (permissions.isNotEmpty()) {
                if (grantResult[0] != PackageManager.PERMISSION_GRANTED) {
                    throw PluginException(1002, "Bluetooth permission denied.")
                }
            }
            return
        }
        throw PluginException(1000, "Unexpected program flow occurred.")
    }

    /**
     * Check whether the phone has BLE.
     */
    private fun checkBluetoothCapability() {
        if (!context.packageManager.hasSystemFeature(PackageManager.FEATURE_BLUETOOTH_LE)) {
            throw PluginException(1001, "Device does not support Bluetooth Low Energy.")
        }
        if (btManager.adapter == null) {
            throw PluginException(1001, "Device does not support Bluetooth Low Energy.")
        }
    }

    @SuppressLint("MissingPermission")
    private fun requestBluetooth(activity: Activity) {
        val permissions = getScanningPermissions()

        Handler(Looper.getMainLooper()).post {
            if (context.checkSelfPermissions(permissions) != PackageManager.PERMISSION_GRANTED) {
                ActivityCompat.requestPermissions(activity, permissions, REQUEST_PERMISSION_CODE)
            } else {
                activity.startActivityForResult(
                    Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE),
                    REQUEST_ENABLE_CODE
                )
            }
        }
    }

    override fun close() {
        coroutineScope.cancel()
    }
}