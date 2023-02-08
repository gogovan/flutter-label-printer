package hk.gogovan.flutter_label_printer

import android.content.Context
import cpcl.PrinterHelper
import hk.gogovan.flutter_label_printer.searcher.BluetoothSearcher
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.lang.Integer.max
import java.lang.Integer.min

class FlutterLabelPrinterMethodHandler(
    private val context: Context,
    private val bluetoothSearcher: BluetoothSearcher?,
): MethodChannel.MethodCallHandler {
    companion object {
        const val SHARED_PREF_NAME = "hk.gogovan.label_printer.flutter_label_printer"
        const val SHARED_PREF_PAPER_TYPE = "paper_type"
    }

    private var currentPaperType: Int? = null

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (currentPaperType == null) {
            val pref = context.getSharedPreferences(SHARED_PREF_NAME, Context.MODE_PRIVATE)
            currentPaperType = pref.getInt(SHARED_PREF_PAPER_TYPE, 0)
        }

        try {
            when (call.method) {
                "hk.gogovan.label_printer.stopSearchHMA300L" -> {
                    val response = bluetoothSearcher?.stopScan()
                    result.success(response)
                }
                "hk.gogovan.label_printer.connectHMA300L" -> {
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
                "hk.gogovan.label_printer.disconnectHMA300L" -> {
                    result.success(PrinterHelper.portClose())
                }
                "hk.gogovan.label_printer.printTestPageHMA300L" -> {
                    printTestPage()
                    result.success(true)
                }
                "hk.gogovan.label_printer.setPrintAreaSizeHMA300L" -> {
                    try {
                        val offset = call.argument<Int>("offset")
                        val horizontalRes = call.argument<Int>("horizontalRes")
                        val verticalRes = call.argument<Int>("verticalRes")
                        val height = call.argument<Int>("height")
                        val quantity = call.argument<Int>("quantity")
                        val returnCode = PrinterHelper.printAreaSize(
                            offset?.toString() ?: "0",
                            horizontalRes?.toString() ?: "200",
                            verticalRes?.toString() ?: "200",
                            height?.toString() ?: "0",
                            quantity?.toString() ?: "1",
                        )
                        result.success(returnCode >= 0)
                    } catch (e: ClassCastException) {
                        result.error("1009", "Unable to extract arguments", Throwable().stackTraceToString())
                    }
                }
                "hk.gogovan.label_printer.addTextHMA300L" -> {
                    try {
                        PrinterHelper.LanguageEncode = "GB_2312"
                        PrinterHelper.Country("CHINA")

                        val rotate = call.argument<Int>("rotate")
                        val font = call.argument<Int>("font")
                        val x = call.argument<Int>("x")
                        val y = call.argument<Int>("y")
                        val text = call.argument<String>("text")

                        val rotateP = when (rotate) {
                            0 -> PrinterHelper.TEXT
                            90 -> PrinterHelper.TEXT90
                            180 -> PrinterHelper.TEXT180
                            270 -> PrinterHelper.TEXT270
                            else -> throw ClassCastException()
                        }

                        val returnCode = PrinterHelper.Text(rotateP, font.toString(), "0", x.toString(), y.toString(), text)
                        // val returnCode = PrinterHelper.PrintTextCPCL(rotateP, 16, x.toString(), y.toString(), text, 0, false, 100)
                        result.success(returnCode >= 0)
                    } catch (e: ClassCastException) {
                        result.error("1009", "Unable to extract arguments", Throwable().stackTraceToString())
                    }
                }
                "hk.gogovan.label_printer.printHMA300L" -> {
                    if (currentPaperType == 1) {
                        PrinterHelper.Form()
                    }
                    PrinterHelper.Print()
                    result.success(true)
                }
                "hk.gogovan.label_printer.setPaperTypeHMA300L" -> {
                    try {
                        val paperType = call.argument<Int>("paperType") ?: 0
                        val returnCode = PrinterHelper.setPaperFourInch(paperType)

                        currentPaperType = paperType
                        val pref = context.getSharedPreferences(SHARED_PREF_NAME, Context.MODE_PRIVATE)
                        pref.edit().putInt(SHARED_PREF_PAPER_TYPE, paperType).apply()

                        result.success(returnCode >= 0)
                    } catch (e: ClassCastException) {
                        result.error("1009", "Unable to extract arguments", Throwable().stackTraceToString())
                    }
                }
                "hk.gogovan.label_printer.setBoldHMA300L" -> {
                    try {
                        val size = max(0, min(5, call.argument<Int>("size") ?: 0))
                        val returnCode = PrinterHelper.SetBold(size.toString())

                        result.success(returnCode >= 0)
                    } catch (e: ClassCastException) {
                        result.error("1009", "Unable to extract arguments", Throwable().stackTraceToString())
                    }
                }
                "hk.gogovan.label_printer.setTextSizeHMA300L" -> {
                    try {
                        val width = max(1, min(16, call.argument<Int>("width") ?: 1))
                        val height = max(1, min(16, call.argument<Int>("height") ?: 1))
                        val returnCode = PrinterHelper.SetMag(width.toString(), height.toString())

                        result.success(returnCode >= 0)
                    } catch (e: ClassCastException) {
                        result.error("1009", "Unable to extract arguments", Throwable().stackTraceToString())
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        } catch (e: PluginException) {
            result.error(e.code.toString(), e.message, e.stackTraceToString())
        }
    }

    private fun printTestPage() {
        PrinterHelper.printAreaSize("0", "200", "200", "1400", "1")
        PrinterHelper.Align(PrinterHelper.CENTER)
        PrinterHelper.Text(
            PrinterHelper.TEXT,
            "8",
            "0",
            "50",
            "5",
            "Test Page"
        )
        PrinterHelper.Align(PrinterHelper.LEFT)
        PrinterHelper.Text(PrinterHelper.TEXT, "8", "0", "0", "66", "CODE128")
        PrinterHelper.Barcode(
            PrinterHelper.BARCODE,
            "128",
            "2",
            "1",
            "50",
            "0",
            "100",
            true,
            "7",
            "0",
            "5",
            "123456789"
        )
        PrinterHelper.Text(PrinterHelper.TEXT, "8", "0", "0", "180", "UPCA")
        PrinterHelper.Barcode(
            PrinterHelper.BARCODE,
            PrinterHelper.UPCA,
            "2",
            "1",
            "50",
            "0",
            "210",
            true,
            "7",
            "0",
            "5",
            "123456789012"
        )
        PrinterHelper.Text(PrinterHelper.TEXT, "8", "0", "0", "310", "UPCE")
        PrinterHelper.Barcode(
            PrinterHelper.BARCODE,
            PrinterHelper.code128,
            "2",
            "1",
            "50",
            "0",
            "340",
            true,
            "7",
            "0",
            "5",
            "0234565687"
        )
        PrinterHelper.Text(PrinterHelper.TEXT, "8", "0", "0", "440", "EAN8")
        PrinterHelper.Barcode(
            PrinterHelper.BARCODE,
            PrinterHelper.EAN8,
            "2",
            "1",
            "50",
            "0",
            "470",
            true,
            "7",
            "0",
            "5",
            "12345678"
        )
        PrinterHelper.Text(PrinterHelper.TEXT, "8", "0", "0", "570", "CODE93")
        PrinterHelper.Barcode(
            PrinterHelper.BARCODE,
            PrinterHelper.code93,
            "2",
            "1",
            "50",
            "0",
            "600",
            true,
            "7",
            "0",
            "5",
            "123456789"
        )
        PrinterHelper.Text(PrinterHelper.TEXT, "8", "0", "0", "700", "CODE39")
        PrinterHelper.Barcode(
            PrinterHelper.BARCODE,
            PrinterHelper.code39,
            "2",
            "1",
            "50",
            "0",
            "730",
            true,
            "7",
            "0",
            "5",
            "123456789"
        )
        PrinterHelper.Text(
            PrinterHelper.TEXT,
            "8",
            "0",
            "0",
            "830",
            "ESC function BTN QR Code"
        )
        PrinterHelper.PrintQR(PrinterHelper.BARCODE, "0", "870", "4", "6", "ABC123")
        PrinterHelper.PrintQR(PrinterHelper.BARCODE, "150", "870", "4", "6", "ABC123")
        PrinterHelper.Text(
            PrinterHelper.TEXT,
            "8",
            "0",
            "0",
            "1000",
            "Activity Test Line"
        )
        PrinterHelper.Line("0", "1030", "400", "1030", "1")
        PrinterHelper.Text(
            PrinterHelper.TEXT,
            "8",
            "0",
            "0",
            "1050",
            "Activity Test Box"
        )
        PrinterHelper.Box("10", "1080", "400", "1300", "1")
        if (currentPaperType == 1) {
            PrinterHelper.Form()
        }
        PrinterHelper.Form()
        PrinterHelper.Print()
    }
}