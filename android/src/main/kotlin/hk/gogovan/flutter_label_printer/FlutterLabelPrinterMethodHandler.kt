package hk.gogovan.flutter_label_printer

import android.content.Context
import cpcl.PrinterHelper
import hk.gogovan.flutter_label_printer.searcher.BluetoothSearcher
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class FlutterLabelPrinterMethodHandler(
    private val context: Context,
    private val bluetoothSearcher: BluetoothSearcher?,
): MethodChannel.MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "com.gogovan/stopSearchHMA300L" -> {
                    val response = bluetoothSearcher?.stopScan()
                    result.success(response)
                }
                "com.gogovan/connectHMA300L" -> {
                    val address = call.argument<String>("address")
                    if (address == null) {
                        result.error(
                            "1000",
                            "Unable to extract arguments.",
                            Throwable().stackTraceToString()
                        )
                    } else {
                        when (PrinterHelper.portOpenBT(context, address)) {
                            0 -> {
                                result.success(true)
                            }
                            -1 -> {
                                result.error(
                                    "1008",
                                    "Connection timed out.",
                                    Throwable().stackTraceToString()
                                )
                            }
                            -2 -> {
                                result.error(
                                    "1007",
                                    "Bluetooth address incorrect.",
                                    Throwable().stackTraceToString()
                                )
                            }
                            else -> {
                                result.error(
                                    "1006",
                                    "Connection error.",
                                    Throwable().stackTraceToString()
                                )
                            }
                        }
                    }
                }
                "com.gogovan/disconnectHMA300L" -> {
                    result.success(PrinterHelper.portClose())
                }
                "com.gogovan/printTestPageHMA300L" -> {
                    PrinterHelper.printAreaSize("0", "200", "200", "100", "1")
                    PrinterHelper.Text(PrinterHelper.TEXT, "4", "0", "0", "0", "This is a test.")
                    PrinterHelper.Form()
                    PrinterHelper.Print()
                    result.success(true)
                }
                "com.gogovan/setPrintAreaSizeHMA300L" -> {
                    val offset = call.argument<Int>("offset")
                    val horizontalRes = call.argument<Int>("horizontalRes")
                    val verticalRes = call.argument<Int>("verticalRes")
                    val height = call.argument<Int>("height")
                    val quantity = call.argument<Int>("quantity")
                    PrinterHelper.printAreaSize(
                        offset?.toString() ?: "0",
                        horizontalRes?.toString() ?: "200",
                        verticalRes?.toString() ?: "200",
                        height?.toString() ?: "0",
                        quantity?.toString() ?: "1",
                    )
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        } catch (e: PluginException) {
            result.error(e.code.toString(), e.message, e.stackTraceToString())
        }
    }
}