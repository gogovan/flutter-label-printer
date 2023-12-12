package hk.gogovan.flutter_label_printer.searcher

import android.annotation.SuppressLint
import android.app.Activity
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.hardware.usb.UsbDevice
import android.hardware.usb.UsbManager
import android.os.Build

class UsbSearcher(private val context: Context) {
    companion object {
        private const val ACTION_USB_PERMISSION = "hk.gogovan.flutter_label_printer.USB_PERMISSION"
    }

    private val usbReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            if (ACTION_USB_PERMISSION == intent?.action) {
                val device = intent.getParcelableExtra<UsbDevice>(UsbManager.EXTRA_DEVICE)
                onPermission(
                    intent.getBooleanExtra(UsbManager.EXTRA_PERMISSION_GRANTED, false),
                    device
                )
            }
        }
    }

    private var currentActivity: Activity? = null
    private var permissionIntent: PendingIntent? = null

    private var onPermission: (Boolean, UsbDevice?) -> Unit = { _, _ -> }

    @SuppressLint("UnspecifiedRegisterReceiverFlag")
    fun setCurrentActivity(activity: Activity) {
        currentActivity = activity

        permissionIntent = PendingIntent.getBroadcast(
            activity, 0, Intent(ACTION_USB_PERMISSION),
            PendingIntent.FLAG_IMMUTABLE
        )
        val filter = IntentFilter(ACTION_USB_PERMISSION)
        if (Build.VERSION.SDK_INT >= 33) {
            activity.registerReceiver(usbReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            activity.registerReceiver(usbReceiver, filter)
        }
    }

    fun getUsbDevices(): Map<String, UsbDevice> {
        val manager = context.getSystemService(UsbManager::class.java)
        return manager.deviceList
    }

    fun getUsbDevice(name: String): UsbDevice? {
        val manager = context.getSystemService(UsbManager::class.java)
        return manager.deviceList[name]
    }

    fun checkPermission(device: UsbDevice, onPerm: (Boolean, UsbDevice?) -> Unit): Boolean {
        val manager = context.getSystemService(UsbManager::class.java)

        return if (manager.hasPermission(device)) {
            onPerm(true, device)
            true
        } else {
            onPermission = onPerm
            manager.requestPermission(device, permissionIntent)
            false
        }
    }

}
