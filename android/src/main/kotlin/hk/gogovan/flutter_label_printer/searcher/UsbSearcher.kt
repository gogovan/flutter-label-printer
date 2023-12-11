package hk.gogovan.flutter_label_printer.searcher

import android.content.Context
import android.hardware.usb.UsbDevice
import android.hardware.usb.UsbManager

class UsbSearcher(private val context: Context) {
    fun getUsbDevices(): Map<String, UsbDevice> {
        val manager = context.getSystemService(UsbManager::class.java)
        return manager.deviceList
    }
}
