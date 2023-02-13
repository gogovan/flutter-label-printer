package hk.gogovan.flutter_label_printer

import android.content.Context
import cpcl.PrinterHelper
import hk.gogovan.flutter_label_printer.searcher.BluetoothSearcher
import hk.gogovan.flutter_label_printer.util.Log
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.lang.Integer.max
import java.lang.Integer.min

class FlutterLabelPrinterMethodHandler(
    private val context: Context,
    private val bluetoothSearcher: BluetoothSearcher?,
) : MethodChannel.MethodCallHandler {
    companion object {
        const val SHARED_PREF_NAME = "hk.gogovan.label_printer.flutter_label_printer"
        const val SHARED_PREF_PAPER_TYPE = "paper_type"
    }

    private var currentPaperType: Int? = null

    private var paperTypeSet = false
    private var areaSizeSet = false

    private val log = Log()

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (currentPaperType == null) {
            val pref = context.getSharedPreferences(SHARED_PREF_NAME, Context.MODE_PRIVATE)
            currentPaperType = pref.getInt(SHARED_PREF_PAPER_TYPE, 0)
        }

        try {
            when (call.method) {
                "hk.gogovan.label_printer.setLogLevel" -> {
                    try {
                        val level = call.argument<Int>("level") ?: 2
                        log.setLogLevel(level)
                    } catch (e: ClassCastException) {
                        result.error(
                            "1009",
                            "Unable to extract arguments",
                            Throwable().stackTraceToString()
                        )
                    }
                }
                "hk.gogovan.label_printer.stopSearchHMA300L" -> {
                    val response = bluetoothSearcher?.stopScan()
                    result.success(response)
                }
                "hk.gogovan.label_printer.connectHMA300L" -> {
                    if (PrinterHelper.IsOpened()) {
                        result.error(
                            "1005",
                            "Printer already connected.",
                            Throwable().stackTraceToString()
                        )
                    } else {
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
                }
                "hk.gogovan.label_printer.disconnectHMA300L" -> {
                    if (!PrinterHelper.IsOpened()) {
                        result.error(
                            "1005",
                            "Printer not connected.",
                            Throwable().stackTraceToString()
                        )
                    } else {
                        result.success(PrinterHelper.portClose())
                    }
                }
                "hk.gogovan.label_printer.printTestPageHMA300L" -> {
                    if (!PrinterHelper.IsOpened()) {
                        result.error(
                            "1005",
                            "Printer not connected.",
                            Throwable().stackTraceToString()
                        )
                    } else {
                        printTestPage()
                        result.success(true)
                    }
                }
                "hk.gogovan.label_printer.setPrintAreaSizeHMA300L" -> {
                    if (!PrinterHelper.IsOpened()) {
                        result.error(
                            "1005",
                            "Printer not connected.",
                            Throwable().stackTraceToString()
                        )
                    } else {
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

                            areaSizeSet = true

                            result.success(returnCode >= 0)
                        } catch (e: ClassCastException) {
                            result.error(
                                "1009",
                                "Unable to extract arguments",
                                Throwable().stackTraceToString()
                            )
                        }
                    }
                }
                "hk.gogovan.label_printer.addTextHMA300L" -> {
                    if (!PrinterHelper.IsOpened()) {
                        result.error(
                            "1005",
                            "Printer not connected.",
                            Throwable().stackTraceToString()
                        )
                    } else {
                        try {
                            // TODO API for setting language and country
                            PrinterHelper.LanguageEncode = "gb2312"
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

                            val returnCode = PrinterHelper.Text(
                                rotateP,
                                font.toString(),
                                "0",
                                x.toString(),
                                y.toString(),
                                text
                            )

                            result.success(returnCode >= 0)
                        } catch (e: ClassCastException) {
                            result.error(
                                "1009",
                                "Unable to extract arguments",
                                Throwable().stackTraceToString()
                            )
                        }
                    }
                }
                "hk.gogovan.label_printer.printHMA300L" -> {
                    if (!PrinterHelper.IsOpened()) {
                        result.error(
                            "1005",
                            "Printer not connected.",
                            Throwable().stackTraceToString()
                        )
                    } else {
                        if (!paperTypeSet) {
                            log.w("Paper Type is not set. This may result in unexpected behavior in printing.")
                        }
                        if (!areaSizeSet) {
                            log.w("Print Area Size is not set. This may result in unexpected behavior in printing.")
                        }

                        if (currentPaperType == 1) {
                            PrinterHelper.Form()
                        }

                        PrinterHelper.Print()

                        areaSizeSet = false

                        result.success(true)
                    }
                }
                "hk.gogovan.label_printer.setPaperTypeHMA300L" -> {
                    if (!PrinterHelper.IsOpened()) {
                        result.error(
                            "1005",
                            "Printer not connected.",
                            Throwable().stackTraceToString()
                        )
                    } else {
                        try {
                            val paperType = call.argument<Int>("paperType") ?: 0
                            val returnCode = PrinterHelper.setPaperFourInch(paperType)

                            currentPaperType = paperType
                            val pref =
                                context.getSharedPreferences(SHARED_PREF_NAME, Context.MODE_PRIVATE)
                            pref.edit().putInt(SHARED_PREF_PAPER_TYPE, paperType).apply()
                            paperTypeSet = true

                            result.success(returnCode >= 0)
                        } catch (e: ClassCastException) {
                            result.error(
                                "1009",
                                "Unable to extract arguments",
                                Throwable().stackTraceToString()
                            )
                        }
                    }
                }
                "hk.gogovan.label_printer.setBoldHMA300L" -> {
                    if (!PrinterHelper.IsOpened()) {
                        result.error(
                            "1005",
                            "Printer not connected.",
                            Throwable().stackTraceToString()
                        )
                    } else {
                        try {
                            val size = max(0, min(5, call.argument<Int>("size") ?: 0))
                            val returnCode = PrinterHelper.SetBold(size.toString())

                            result.success(returnCode >= 0)
                        } catch (e: ClassCastException) {
                            result.error(
                                "1009",
                                "Unable to extract arguments",
                                Throwable().stackTraceToString()
                            )
                        }
                    }
                }
                "hk.gogovan.label_printer.setTextSizeHMA300L" -> {
                    if (!PrinterHelper.IsOpened()) {
                        result.error(
                            "1005",
                            "Printer not connected.",
                            Throwable().stackTraceToString()
                        )
                    } else {
                        try {
                            val width = max(1, min(16, call.argument<Int>("width") ?: 1))
                            val height = max(1, min(16, call.argument<Int>("height") ?: 1))
                            val returnCode =
                                PrinterHelper.SetMag(width.toString(), height.toString())

                            result.success(returnCode >= 0)
                        } catch (e: ClassCastException) {
                            result.error(
                                "1009",
                                "Unable to extract arguments",
                                Throwable().stackTraceToString()
                            )
                        }
                    }
                }
                "hk.gogovan.label_printer.getStatusHMA300L" -> {
                    if (!PrinterHelper.IsOpened()) {
                        result.error(
                            "1005",
                            "Printer not connected.",
                            Throwable().stackTraceToString()
                        )
                    } else {
                        val status = PrinterHelper.getstatus()
                        result.success(status)
                    }
                }
                "hk.gogovan.label_printer.prefeedHMA300L" -> {
                    if (!PrinterHelper.IsOpened()) {
                        result.error(
                            "1005",
                            "Printer not connected.",
                            Throwable().stackTraceToString()
                        )
                    } else {
                        try {
                            val dot = call.argument<Int>("dot") ?: 0
                            val returnCode = PrinterHelper.Prefeed(dot.toString())

                            result.success(returnCode >= 0)
                        } catch (e: ClassCastException) {
                            result.error(
                                "1009",
                                "Unable to extract arguments",
                                Throwable().stackTraceToString()
                            )
                        }
                    }
                }
                "hk.gogovan.label_printer.setPageWidthHMA300L" -> {
                    if (!PrinterHelper.IsOpened()) {
                        result.error(
                            "1005",
                            "Printer not connected.",
                            Throwable().stackTraceToString()
                        )
                    } else {
                        try {
                            val width = call.argument<Int>("width") ?: 0
                            val returnCode = PrinterHelper.PageWidth(width.toString())

                            result.success(returnCode >= 0)
                        } catch (e: ClassCastException) {
                            result.error(
                                "1009",
                                "Unable to extract arguments",
                                Throwable().stackTraceToString()
                            )
                        }
                    }
                }
                "hk.gogovan.label_printer.setAlignHMA300L" -> {
                    if (!PrinterHelper.IsOpened()) {
                        result.error(
                            "1005",
                            "Printer not connected.",
                            Throwable().stackTraceToString()
                        )
                    } else {
                        try {
                            val enum = when (val align = call.argument<Int>("align") ?: 0) {
                                0 -> PrinterHelper.LEFT
                                1 -> PrinterHelper.CENTER
                                2 -> PrinterHelper.RIGHT
                                else -> throw ClassCastException("Invalid align value $align")
                            }
                            val returnCode = PrinterHelper.Align(enum)

                            result.success(returnCode >= 0)
                        } catch (e: ClassCastException) {
                            result.error(
                                "1009",
                                "Unable to extract arguments",
                                Throwable().stackTraceToString()
                            )
                        }
                    }
                }
                "hk.gogovan.label_printer.addBarcode" -> {
                    if (!PrinterHelper.IsOpened()) {
                        result.error(
                            "1005",
                            "Printer not connected.",
                            Throwable().stackTraceToString()
                        )
                    } else {
                        try {
                            val orientation = call.argument<Int>("orientation") ?: 0
                            val type = call.argument<Int>("type") ?: 0
                            val width = call.argument<Int>("width") ?: 0
                            val ratio = call.argument<Int>("ratio") ?: 0
                            val height = call.argument<Int>("height") ?: 0
                            val x = call.argument<Int>("x") ?: 0
                            val y = call.argument<Int>("y") ?: 0
                            val data = call.argument<String>("data") ?: ""

                            val orientationEnum = when (orientation) {
                                0 -> PrinterHelper.BARCODE
                                1 -> PrinterHelper.VBARCODE
                                else -> throw ClassCastException("Invalid orientation value $orientation")
                            }
                            val typeEnum = when (type) {
                                0 -> PrinterHelper.UPCA
                                1 -> PrinterHelper.UPCE
                                2 -> PrinterHelper.EAN13
                                3 -> PrinterHelper.EAN8
                                4 -> PrinterHelper.code39
                                5 -> PrinterHelper.code93
                                6 -> PrinterHelper.code128
                                7 -> PrinterHelper.CODABAR
                                else -> throw ClassCastException("Invalid type value $type")
                            }
                            if (!((ratio in 0..4) || (ratio in 20..30))) {
                                throw ClassCastException("Invalid ratio value $ratio")
                            }

                            val returnCode = PrinterHelper.Barcode(
                                orientationEnum,
                                typeEnum,
                                width.toString(),
                                ratio.toString(),
                                height.toString(),
                                x.toString(),
                                y.toString(),
                                false,
                                "",
                                "",
                                "",
                                data
                            )

                            result.success(returnCode >= 0)
                        } catch (e: ClassCastException) {
                            result.error(
                                "1009",
                                "Unable to extract arguments",
                                Throwable().stackTraceToString()
                            )
                        }
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