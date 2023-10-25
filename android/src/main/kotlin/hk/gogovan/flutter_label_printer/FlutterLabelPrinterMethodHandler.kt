package hk.gogovan.flutter_label_printer

import android.content.Context
import android.graphics.BitmapFactory
import androidx.annotation.VisibleForTesting
import cpcl.PrinterHelper
import hk.gogovan.flutter_label_printer.searcher.BluetoothSearcher
import hk.gogovan.flutter_label_printer.util.Log
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import tspl.HPRTPrinterHelper
import java.lang.Integer.max
import java.lang.Integer.min
import java.util.Locale

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

    @VisibleForTesting
    var log = Log()

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
                            "Unable to extract arguments $e",
                            Throwable().stackTraceToString()
                        )
                    }
                }

                "hk.gogovan.label_printer.stopSearchBluetooth" -> {
                    val response = bluetoothSearcher?.stopScan()
                    result.success(response)
                }

                "hk.gogovan.label_printer.hanin.tspl.connect" -> {
                    if (HPRTPrinterHelper.IsOpened()) {
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
                            if (HPRTPrinterHelper.PortOpen(address) == 0) {
                                result.success(true)
                            } else {
                                result.error(
                                    "1006",
                                    "Connection error.",
                                    Throwable().stackTraceToString()
                                )
                            }
                        }
                    }
                }

                "hk.gogovan.label_printer.hanin.cpcl.connect" -> {
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

                "hk.gogovan.label_printer.hanin.tspl.disconnect" -> {
                    if (!HPRTPrinterHelper.IsOpened()) {
                        result.error(
                            "1005",
                            "Printer not connected.",
                            Throwable().stackTraceToString()
                        )
                    } else {
                        result.success(HPRTPrinterHelper.PortClose())
                    }
                }

                "hk.gogovan.label_printer.hanin.cpcl.disconnect" -> {
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

                "hk.gogovan.label_printer.hanin.tspl.clear" -> {
                    if (!HPRTPrinterHelper.IsOpened()) {
                        result.error(
                            "1005",
                            "Printer not connected.",
                            Throwable().stackTraceToString()
                        )
                    } else {
                        val returnCode = HPRTPrinterHelper.CLS()
                        result.success(returnCode > 0)
                    }
                }

                "hk.gogovan.label_printer.hanin.tspl.printTestPage" -> {
                    if (!HPRTPrinterHelper.IsOpened()) {
                        result.error(
                            "1005",
                            "Printer not connected.",
                            Throwable().stackTraceToString()
                        )
                    } else {
                        printTestPageN31()
                        result.success(true)
                    }
                }

                "hk.gogovan.label_printer.hanin.cpcl.printTestPage" -> {
                    if (!PrinterHelper.IsOpened()) {
                        result.error(
                            "1005",
                            "Printer not connected.",
                            Throwable().stackTraceToString()
                        )
                    } else {
                        printTestPageHMA300L()
                        result.success(true)
                    }
                }

                "hk.gogovan.label_printer.hanin.tspl.setPrintAreaSize" -> {
                    if (!PrinterHelper.IsOpened()) {
                        result.error(
                            "1005",
                            "Printer not connected.",
                            Throwable().stackTraceToString()
                        )
                    } else {
                        try {
                            val width = call.argument<Int>("width")
                            val height = call.argument<Int>("height")
                            val returnCode = HPRTPrinterHelper.printAreaSize(
                                width.toString(),
                                height.toString()
                            )

                            areaSizeSet = true

                            result.success(returnCode >= 0)
                        } catch (e: ClassCastException) {
                            result.error(
                                "1009",
                                "Unable to extract arguments $e",
                                Throwable().stackTraceToString()
                            )
                        }
                    }
                }

                "hk.gogovan.label_printer.hanin.cpcl.setPrintAreaSize" -> {
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
                                "Unable to extract arguments $e",
                                Throwable().stackTraceToString()
                            )
                        }
                    }
                }

                "hk.gogovan.label_printer.hanin.tspl.addText" -> {
                    if (!PrinterHelper.IsOpened()) {
                        result.error(
                            "1005",
                            "Printer not connected.",
                            Throwable().stackTraceToString()
                        )
                    } else {
                        try {
                            // TODO API for setting language and country
                            HPRTPrinterHelper.LanguageEncode = "gb2312"

                            val rotate = (call.argument<Int>("rotate") ?: 0).toString()
                            val font = call.argument<Int>("font").toString()
                            val x = call.argument<Int>("x").toString()
                            val y = call.argument<Int>("y").toString()
                            val text = call.argument<String>("text")
                            val charWidth = (call.argument<Int>("characterWidth") ?: 0).toString()
                            val charHeight = (call.argument<Int>("characterHeight") ?: 0).toString()

                            val returnCode = HPRTPrinterHelper.printText(
                                x,
                                y,
                                font,
                                rotate,
                                charWidth,
                                charHeight,
                                1,
                                text
                            )

                            result.success(returnCode >= 0)
                        } catch (e: ClassCastException) {
                            result.error(
                                "1009",
                                "Unable to extract arguments $e",
                                Throwable().stackTraceToString()
                            )
                        }
                    }
                }

                "hk.gogovan.label_printer.hanin.cpcl.addText" -> {
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
                                else -> throw ClassCastException("Invalid rotate value $rotate")
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
                                "Unable to extract arguments $e",
                                Throwable().stackTraceToString()
                            )
                        }
                    }
                }

                "hk.gogovan.label_printer.hanin.tspl.print" -> {
                    if (!PrinterHelper.IsOpened()) {
                        result.error(
                            "1005",
                            "Printer not connected.",
                            Throwable().stackTraceToString()
                        )
                    } else {
                        try {
                            if (!areaSizeSet) {
                                log.w("Print Area Size is not set. This may result in unexpected behavior in printing.")
                            }

                            val count = (call.argument<Int>("count") ?: 1).toString()

                            val returnCode = HPRTPrinterHelper.Print(count, "1")

                            areaSizeSet = false

                            result.success(returnCode >= 0)
                        } catch (e: ClassCastException) {
                            result.error(
                                "1009",
                                "Unable to extract arguments $e",
                                Throwable().stackTraceToString()
                            )
                        }
                    }
                }

                "hk.gogovan.label_printer.hanin.cpcl.print" -> {
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

                "hk.gogovan.label_printer.hanin.cpcl.setPaperType" -> {
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
                                "Unable to extract arguments $e",
                                Throwable().stackTraceToString()
                            )
                        }
                    }
                }

                "hk.gogovan.label_printer.hanin.cpcl.setBold" -> {
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
                                "Unable to extract arguments $e",
                                Throwable().stackTraceToString()
                            )
                        }
                    }
                }

                "hk.gogovan.label_printer.hanin.cpcl.setTextSize" -> {
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
                                "Unable to extract arguments $e",
                                Throwable().stackTraceToString()
                            )
                        }
                    }
                }

                "hk.gogovan.label_printer.hanin.tspl.getStatus" -> {
                    if (!HPRTPrinterHelper.IsOpened()) {
                        result.error(
                            "1005",
                            "Printer not connected.",
                            Throwable().stackTraceToString()
                        )
                    } else {
                        // For some insane reason status code are not aligned between Android and iOS SDK :facepalm: :facepalm: :facepalm:
                        // Here we convert the status code to match the one used in iOS SDK since the code there gives more information
                        val realStatus = when (HPRTPrinterHelper.getPrinterStatus()) {
                            HPRTPrinterHelper.STATUS_DISCONNECT -> -1
                            HPRTPrinterHelper.STATUS_TIMEOUT -> -2
                            HPRTPrinterHelper.STATUS_NOPAPER -> 4
                            HPRTPrinterHelper.STATUS_PRINTING -> 32
                            HPRTPrinterHelper.STATUS_COVER_OPENED -> 65
                            HPRTPrinterHelper.STATUS_OVER_HEATING -> 128
                            else -> 0
                        }

                        result.success(realStatus)
                    }
                }

                "hk.gogovan.label_printer.hanin.cpcl.getStatus" -> {
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

                "hk.gogovan.label_printer.hanin.tspl.space" -> {
                    if (!PrinterHelper.IsOpened()) {
                        result.error(
                            "1005",
                            "Printer not connected.",
                            Throwable().stackTraceToString()
                        )
                    } else {
                        try {
                            val distance = (call.argument<Int>("mm") ?: 0).toString()
                            val returnCode = HPRTPrinterHelper.Offset(distance)

                            result.success(returnCode >= 0)
                        } catch (e: ClassCastException) {
                            result.error(
                                "1009",
                                "Unable to extract arguments $e",
                                Throwable().stackTraceToString()
                            )
                        }
                    }
                }

                "hk.gogovan.label_printer.hanin.cpcl.space" -> {
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
                                "Unable to extract arguments $e",
                                Throwable().stackTraceToString()
                            )
                        }
                    }
                }

                "hk.gogovan.label_printer.hanin.cpcl.setPageWidth" -> {
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
                                "Unable to extract arguments $e",
                                Throwable().stackTraceToString()
                            )
                        }
                    }
                }

                "hk.gogovan.label_printer.hanin.cpcl.setAlign" -> {
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
                                "Unable to extract arguments $e",
                                Throwable().stackTraceToString()
                            )
                        }
                    }
                }

                "hk.gogovan.label_printer.hanin.tspl.addBarcode" -> {
                    if (!PrinterHelper.IsOpened()) {
                        result.error(
                            "1005",
                            "Printer not connected.",
                            Throwable().stackTraceToString()
                        )
                    } else {
                        try {
                            val x = (call.argument<Int>("x") ?: 0).toString()
                            val y = (call.argument<Int>("y") ?: 0).toString()
                            val type = call.argument<String>("type")
                            val height = (call.argument<Int>("height") ?: 0).toString()
                            val showData =
                                if (call.argument<Boolean>("showData") == true) "1" else "0"
                            val rotate = (call.argument<Int>("rotate") ?: 0).toString()
                            val data = call.argument<String>("data")

                            if (type !in listOf(
                                    "128",
                                    "128M",
                                    "EAN128",
                                    "39",
                                    "93",
                                    "UPCA",
                                    "MSI",
                                    "ITF14",
                                    "EAN13"
                                )
                            ) {
                                throw ClassCastException("Invalid type value $type")
                            }

                            val returnCode = HPRTPrinterHelper.printBarcode(
                                x,
                                y,
                                type,
                                height,
                                showData,
                                rotate,
                                "1",
                                "1",
                                data
                            )
                            result.success(returnCode >= 0)
                        } catch (e: ClassCastException) {
                            result.error(
                                "1009",
                                "Unable to extract arguments $e",
                                Throwable().stackTraceToString()
                            )
                        }
                    }
                }

                "hk.gogovan.label_printer.hanin.cpcl.addBarcode" -> {
                    if (!PrinterHelper.IsOpened()) {
                        result.error(
                            "1005",
                            "Printer not connected.",
                            Throwable().stackTraceToString()
                        )
                    } else {
                        try {
                            val orientation = call.argument<Int>("orientation") ?: 0
                            val type = call.argument<String>("type") ?: ""
                            val width = call.argument<Int>("width") ?: 0
                            val ratio = call.argument<Int>("ratio") ?: 0
                            val height = call.argument<Int>("height") ?: 0
                            val x = call.argument<Int>("x") ?: 0
                            val y = call.argument<Int>("y") ?: 0
                            val data = call.argument<String>("data") ?: ""
                            val showData = call.argument<Boolean>("showData") ?: false
                            val dataFont = call.argument<Int?>("dataFont")
                            val dataTextSize = call.argument<Int?>("dataTextSize")
                            val dataTextOffset = call.argument<Int?>("dataTextOffset")

                            val orientationEnum = when (orientation) {
                                0 -> PrinterHelper.BARCODE
                                1 -> PrinterHelper.VBARCODE
                                else -> throw ClassCastException("Invalid orientation value $orientation")
                            }
                            val typeEnum = when (type.uppercase(Locale.getDefault())) {
                                "UPCA" -> PrinterHelper.UPCA
                                "UPCE" -> PrinterHelper.UPCE
                                "EAN13" -> PrinterHelper.EAN13
                                "EAN8" -> PrinterHelper.EAN8
                                "CODE39" -> PrinterHelper.code39
                                "CODE93" -> PrinterHelper.code93
                                "CODE128" -> PrinterHelper.code128
                                "CODABAR" -> PrinterHelper.CODABAR
                                else -> throw ClassCastException("Invalid type value $type")
                            }
                            if (showData && (dataFont == null || dataTextSize == null || dataTextOffset == null)) {
                                throw ClassCastException("showData is requested but required params are not provided.")
                            }

                            val returnCode = PrinterHelper.Barcode(
                                orientationEnum,
                                typeEnum,
                                width.toString(),
                                ratio.toString(),
                                height.toString(),
                                x.toString(),
                                y.toString(),
                                showData,
                                dataFont.toString(),
                                dataTextSize.toString(),
                                dataTextOffset.toString(),
                                data
                            )

                            result.success(returnCode >= 0)
                        } catch (e: ClassCastException) {
                            result.error(
                                "1009",
                                "Unable to extract arguments $e",
                                Throwable().stackTraceToString()
                            )
                        }
                    }
                }

                "hk.gogovan.label_printer.hanin.tspl.addQRCode" -> {
                    if (!PrinterHelper.IsOpened()) {
                        result.error(
                            "1005",
                            "Printer not connected.",
                            Throwable().stackTraceToString()
                        )
                    } else {
                        try {
                            val x = call.argument<Int>("x").toString()
                            val y = call.argument<Int>("y").toString()
                            val eccLevel = call.argument<String>("eccLevel") ?: "L"
                            val unitSize = call.argument<Int>("unitSize").toString()
                            val mode = if ((call.argument<Int>("mode") ?: 0) == 0) "A" else "M"
                            val rotate = (call.argument<Int>("rotate") ?: 0).toString()
                            val data = call.argument<String>("data")

                            if (eccLevel !in listOf("L", "M", "Q", "H")) {
                                throw ClassCastException("Invalid eccLevel $eccLevel")
                            }

                            val returnCode = HPRTPrinterHelper.printQRcode(
                                x,
                                y,
                                eccLevel,
                                unitSize,
                                mode,
                                rotate,
                                data
                            )
                            result.success(returnCode >= 0)
                        } catch (e: ClassCastException) {
                            result.error(
                                "1009",
                                "Unable to extract arguments $e",
                                Throwable().stackTraceToString()
                            )
                        }
                    }
                }

                "hk.gogovan.label_printer.hanin.cpcl.addQRCode" -> {
                    if (!PrinterHelper.IsOpened()) {
                        result.error(
                            "1005",
                            "Printer not connected.",
                            Throwable().stackTraceToString()
                        )
                    } else {
                        try {
                            val orientation = call.argument<Int>("orientation") ?: 0
                            val x = call.argument<Int>("x") ?: 0
                            val y = call.argument<Int>("y") ?: 0
                            val model = call.argument<Int>("model") ?: 0
                            val unitSize = call.argument<Int>("unitSize") ?: 0
                            val data = call.argument<String>("data") ?: ""

                            val orientationEnum = when (orientation) {
                                0 -> PrinterHelper.BARCODE
                                1 -> PrinterHelper.VBARCODE
                                else -> throw ClassCastException("Invalid orientation value $orientation")
                            }

                            val returnCode = PrinterHelper.PrintQR(
                                orientationEnum,
                                x.toString(),
                                y.toString(),
                                model.toString(),
                                unitSize.toString(),
                                data
                            )

                            result.success(returnCode >= 0)
                        } catch (e: ClassCastException) {
                            result.error(
                                "1009",
                                "Unable to extract arguments $e",
                                Throwable().stackTraceToString()
                            )
                        }
                    }
                }

                "hk.gogovan.label_printer.hanin.tspl.addRectangle" -> {
                    if (!PrinterHelper.IsOpened()) {
                        result.error(
                            "1005",
                            "Printer not connected.",
                            Throwable().stackTraceToString()
                        )
                    } else {
                        try {
                            val x0 = call.argument<Int>("x0") ?: 0
                            val y0 = call.argument<Int>("y0") ?: 0
                            val x1 = call.argument<Int>("x1") ?: 0
                            val y1 = call.argument<Int>("y1") ?: 0
                            val width = call.argument<Int>("width") ?: 1

                            val returnCode = HPRTPrinterHelper.Box(
                                x0.toString(),
                                y0.toString(),
                                x1.toString(),
                                y1.toString(),
                                width.toString()
                            )

                            result.success(returnCode >= 0)
                        } catch (e: ClassCastException) {
                            result.error(
                                "1009",
                                "Unable to extract arguments $e",
                                Throwable().stackTraceToString()
                            )
                        }
                    }
                }

                "hk.gogovan.label_printer.hanin.cpcl.addRectangle" -> {
                    if (!PrinterHelper.IsOpened()) {
                        result.error(
                            "1005",
                            "Printer not connected.",
                            Throwable().stackTraceToString()
                        )
                    } else {
                        try {
                            val x0 = call.argument<Int>("x0") ?: 0
                            val y0 = call.argument<Int>("y0") ?: 0
                            val x1 = call.argument<Int>("x1") ?: 0
                            val y1 = call.argument<Int>("y1") ?: 0
                            val width = call.argument<Int>("width") ?: 1

                            val returnCode = PrinterHelper.Box(
                                x0.toString(),
                                y0.toString(),
                                x1.toString(),
                                y1.toString(),
                                width.toString()
                            )

                            result.success(returnCode >= 0)
                        } catch (e: ClassCastException) {
                            result.error(
                                "1009",
                                "Unable to extract arguments $e",
                                Throwable().stackTraceToString()
                            )
                        }
                    }
                }

                "hk.gogovan.label_printer.hanin.tspl.addLine" -> {
                    if (!PrinterHelper.IsOpened()) {
                        result.error(
                            "1005",
                            "Printer not connected.",
                            Throwable().stackTraceToString()
                        )
                    } else {
                        try {
                            val x0 = call.argument<Int>("x") ?: 0
                            val y0 = call.argument<Int>("y") ?: 0
                            val width = call.argument<Int>("width") ?: 0
                            val height = call.argument<Int>("height") ?: 0

                            val returnCode = HPRTPrinterHelper.Bar(
                                x0.toString(),
                                y0.toString(),
                                width.toString(),
                                height.toString()
                            )

                            result.success(returnCode >= 0)
                        } catch (e: ClassCastException) {
                            result.error(
                                "1009",
                                "Unable to extract arguments $e",
                                Throwable().stackTraceToString()
                            )
                        }
                    }
                }

                "hk.gogovan.label_printer.hanin.cpcl.addLine" -> {
                    if (!PrinterHelper.IsOpened()) {
                        result.error(
                            "1005",
                            "Printer not connected.",
                            Throwable().stackTraceToString()
                        )
                    } else {
                        try {
                            val x0 = call.argument<Int>("x0") ?: 0
                            val y0 = call.argument<Int>("y0") ?: 0
                            val x1 = call.argument<Int>("x1") ?: 0
                            val y1 = call.argument<Int>("y1") ?: 0
                            val width = call.argument<Int>("width") ?: 1

                            val returnCode = PrinterHelper.Line(
                                x0.toString(),
                                y0.toString(),
                                x1.toString(),
                                y1.toString(),
                                width.toString()
                            )

                            result.success(returnCode >= 0)
                        } catch (e: ClassCastException) {
                            result.error(
                                "1009",
                                "Unable to extract arguments $e",
                                Throwable().stackTraceToString()
                            )
                        }
                    }
                }

                "hk.gogovan.label_printer.hanin.tspl.addImage" -> {
                    if (!PrinterHelper.IsOpened()) {
                        result.error(
                            "1005",
                            "Printer not connected.",
                            Throwable().stackTraceToString()
                        )
                    } else {
                        try {
                            val imagePath = call.argument<String>("imagePath")
                            val x = call.argument<Int>("x").toString()
                            val y = call.argument<Int>("y").toString()
                            val type = call.argument<Int>("type") ?: 0

                            val image = BitmapFactory.decodeFile(imagePath)
                            if (image == null) {
                                result.error(
                                    "1010",
                                    "Unable to load the file $imagePath.",
                                    Throwable().stackTraceToString()
                                )
                                return
                            }

                            val returnCode =
                                HPRTPrinterHelper.printImage(x, y, image, true, false, type)

                            if (returnCode <= -1) {
                                result.error(
                                    "1010",
                                    "Unable to print the file $imagePath because the image is too large.",
                                    Throwable().stackTraceToString()
                                )
                                return
                            }
                            result.success(true)
                        } catch (e: ClassCastException) {
                            result.error(
                                "1009",
                                "Unable to extract arguments $e",
                                Throwable().stackTraceToString()
                            )
                        }
                    }
                }

                "hk.gogovan.label_printer.hanin.cpcl.addImage" -> {
                    if (!PrinterHelper.IsOpened()) {
                        result.error(
                            "1005",
                            "Printer not connected.",
                            Throwable().stackTraceToString()
                        )
                    } else {
                        try {
                            val imagePath = call.argument<String>("imagePath")
                            val x = call.argument<Int>("x") ?: 0
                            val y = call.argument<Int>("y") ?: 0
                            val mode = call.argument<Int>("mode") ?: 0

                            val image = BitmapFactory.decodeFile(imagePath)
                            if (image == null) {
                                result.error(
                                    "1010",
                                    "Unable to load the file $imagePath.",
                                    Throwable().stackTraceToString()
                                )
                                return
                            }

                            // compressType does not work and crashes the app if compressed.
                            val returnCode = PrinterHelper.printBitmapCPCL(image, x, y, mode, 0, 0)

                            if (returnCode <= -2) {
                                result.error(
                                    "1010",
                                    "Unable to print the file $imagePath. Code = $returnCode",
                                    Throwable().stackTraceToString()
                                )
                                return
                            }
                            result.success(returnCode >= 0)
                        } catch (e: ClassCastException) {
                            result.error(
                                "1009",
                                "Unable to extract arguments $e",
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
        } catch (e: Exception) {
            result.error("1000", e.message, e.stackTraceToString())
        }
    }

    private fun printTestPageHMA300L() {
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

    private fun printTestPageN31() {
        HPRTPrinterHelper.SelfTest()
    }
}