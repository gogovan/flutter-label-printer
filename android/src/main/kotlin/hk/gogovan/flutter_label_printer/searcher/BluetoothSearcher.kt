package hk.gogovan.flutter_label_printer.searcher

import android.Manifest
import android.annotation.SuppressLint
import android.app.Activity
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothClass
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.os.Handler
import android.os.Looper
import androidx.core.app.ActivityCompat
import hk.gogovan.flutter_label_printer.PluginException
import hk.gogovan.flutter_label_printer.util.ResultOr
import hk.gogovan.flutter_label_printer.util.checkSelfPermissions
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.collect
import java.io.Closeable

/**
 * Search for devices using Classic Bluetooth.
 */
// Implementation note: Due to complexity of Bluetooth permissions across different Android versions
// we use a specialized method to store required permissions. Lint cannot pick that up and keep
// reporting MissingPermission. We are ignoring it and we should ensure that all permissions are
// requested correctly.
@SuppressLint("MissingPermission")
class BluetoothSearcher(private val context: Context) : Closeable {
    companion object {
        const val REQUEST_PERMISSION_CODE = 9031
        const val REQUEST_ENABLE_CODE = 4972
    }

    private val btManager: BluetoothManager =
        context.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
    private val onBluetoothFound = OnBluetoothFound()

    private val bluetoothPermissionGranted = MutableSharedFlow<Boolean>()
    private val bluetoothEnabled = MutableSharedFlow<Boolean>()

    private val coroutineScope = CoroutineScope(Dispatchers.Default)

    private val pluginExceptionFlow = MutableSharedFlow<PluginException>()
    private val foundDevice = MutableSharedFlow<BluetoothDevice>()

    private val discoveredBluetoothDevices = mutableSetOf<String>()

    inner class OnBluetoothFound : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            if (context == null) {
                coroutineScope.launch {
                    pluginExceptionFlow.emit(PluginException(1000, "Unexpected error occurred"))
                }
                return
            }

            val device = intent?.getParcelableExtra<BluetoothDevice>(BluetoothDevice.EXTRA_DEVICE)
            if (context.checkSelfPermissions(getScanningPermissions()) != PackageManager.PERMISSION_GRANTED) {
                coroutineScope.launch {
                    pluginExceptionFlow.emit(PluginException(1002, "Bluetooth permission denied"))
                }
                return
            }

            if (device?.bluetoothClass?.majorDeviceClass == BluetoothClass.Device.Major.IMAGING) {
                coroutineScope.launch {
                    foundDevice.emit(device)
                }
            }
        }
    }

    private fun getScanningPermissions(): Array<String> {
        return if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.S) {
            arrayOf(
                Manifest.permission.BLUETOOTH_SCAN,
                Manifest.permission.BLUETOOTH_CONNECT
            )
        } else {
            arrayOf(
                Manifest.permission.BLUETOOTH,
                Manifest.permission.BLUETOOTH_ADMIN,
                Manifest.permission.ACCESS_COARSE_LOCATION,
                Manifest.permission.ACCESS_FINE_LOCATION
            )
        }
    }

    suspend fun scan(activity: Activity?): Flow<ResultOr<List<String>>> {
        try {
            checkBluetoothCapability()

            val resultFlow = MutableSharedFlow<ResultOr<List<String>>>()

            if (activity == null) {
                throw PluginException(1003, "No current activity")
            } else {
                requestBluetooth(activity)
            }

            coroutineScope.launch {
                pluginExceptionFlow.collect {
                    resultFlow.emit(ResultOr(it))
                }
            }

            coroutineScope.launch {
                bluetoothEnabled.collect {
                    if (context.checkSelfPermissions(getScanningPermissions()) != PackageManager.PERMISSION_GRANTED) {
                        resultFlow.emit(
                            ResultOr(
                                PluginException(
                                    1002,
                                    "Bluetooth permission denied"
                                )
                            )
                        )
                    } else {
                        btManager.adapter?.cancelDiscovery()

                        val intentFilter = IntentFilter()
                        intentFilter.addAction(BluetoothDevice.ACTION_FOUND)
                        activity.registerReceiver(onBluetoothFound, intentFilter)

                        if (btManager.adapter?.startDiscovery() != true) {
                            resultFlow.emit(
                                ResultOr(
                                    PluginException(
                                        1004,
                                        "Unable to initiate Bluetooth discover process"
                                    )
                                )
                            )
                        }
                    }
                }
            }

            coroutineScope.launch {
                foundDevice.collect {
                    val result = it.address
                    if (result != null) {
                        discoveredBluetoothDevices.add(result)
                        val toSend = discoveredBluetoothDevices.toList()
                        resultFlow.emit(ResultOr(toSend))
                    }
                }
            }

            return resultFlow
        } catch (ex: Throwable) {
            val resultFlow = MutableSharedFlow<ResultOr<List<String>>>()
            coroutineScope.launch {
                resultFlow.emit(ResultOr(ex))
            }
            return resultFlow
        }
    }

    private fun requestBluetooth(activity: Activity) {
        val permissions = getScanningPermissions()

        Handler(Looper.getMainLooper()).post {
            if (context.checkSelfPermissions(permissions) != PackageManager.PERMISSION_GRANTED) {
                ActivityCompat.requestPermissions(
                    activity, permissions,
                    REQUEST_PERMISSION_CODE
                )
                coroutineScope.launch {
                    bluetoothPermissionGranted.collect {
                        if (btManager.adapter.state != BluetoothAdapter.STATE_ON) {
                            activity.startActivityForResult(
                                Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE),
                                REQUEST_ENABLE_CODE
                            )
                        } else {
                            coroutineScope.launch {
                                bluetoothEnabled.emit(true)
                            }
                        }
                    }
                }
            } else {
                if (btManager.adapter.state != BluetoothAdapter.STATE_ON) {
                    activity.startActivityForResult(
                        Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE),
                        REQUEST_ENABLE_CODE
                    )
                } else {
                    coroutineScope.launch {
                        bluetoothEnabled.emit(true)
                    }
                }
            }
        }
    }

    fun stopScan(): Boolean {
        return if (context.checkSelfPermissions(getScanningPermissions()) != PackageManager.PERMISSION_GRANTED) {
            throw PluginException(1002, "Bluetooth permission denied")
        } else {
            if (btManager.adapter?.state == BluetoothAdapter.STATE_ON) {
                btManager.adapter?.cancelDiscovery() ?: false
            } else {
                throw PluginException(1005, "Bluetooth is not turned on.")
            }
        }
    }

    fun handleActivityResult(requestCode: Int, resultCode: Int) {
        if (requestCode == REQUEST_ENABLE_CODE) {
            if (resultCode == Activity.RESULT_OK) {
                coroutineScope.launch {
                    bluetoothEnabled.emit(true)
                }
            } else {
                coroutineScope.launch {
                    pluginExceptionFlow.emit(PluginException(1004, "Unable to enable Bluetooth"))
                }
            }
            return
        }
    }

    fun handlePermissionResult(
        requestCode: Int,
        permissions: Array<String>,
        grantResult: IntArray
    ) {
        if (requestCode == REQUEST_PERMISSION_CODE) {
            if (permissions.isNotEmpty()) {
                if (grantResult.any { it != PackageManager.PERMISSION_GRANTED }) {
                    coroutineScope.launch {
                        pluginExceptionFlow.emit(
                            PluginException(
                                1002,
                                "Bluetooth permission denied"
                            )
                        )
                    }
                } else {
                    coroutineScope.launch {
                        bluetoothPermissionGranted.emit(true)
                    }
                }
            }
            return
        }
        coroutineScope.launch {
            pluginExceptionFlow.emit(PluginException(1000, "Unexpected error occurred"))
        }
    }

    private fun checkBluetoothCapability() {
        if (!context.packageManager.hasSystemFeature(PackageManager.FEATURE_BLUETOOTH)) {
            throw PluginException(1001, "Device does not support Bluetooth")
        }
        if (btManager.adapter == null) {
            throw PluginException(1001, "Device does not support Bluetooth")
        }
    }

    override fun close() {
        coroutineScope.cancel()
    }
}