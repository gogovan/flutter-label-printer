package hk.gogovan.flutter_label_printer

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.text.TextUtils
import cpcl.PrinterHelper
import hk.gogovan.flutter_label_printer.searcher.BluetoothSearcher
import hk.gogovan.flutter_label_printer.util.Log
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.kotest.core.spec.style.DescribeSpec
import io.mockk.Runs
import io.mockk.every
import io.mockk.just
import io.mockk.mockk
import io.mockk.mockkStatic
import io.mockk.unmockkStatic
import io.mockk.verify
import tspl.HPRTPrinterHelper

class FlutterLabelPrinterMethodHandlerTest : DescribeSpec({
    val context = mockk<Context> {
        every {
            getSharedPreferences("hk.gogovan.label_printer.flutter_label_printer", 0)
                .getInt("paper_type", 0)
        } returns 0
    }
    val bluetoothSearcher = mockk<BluetoothSearcher>()

    beforeEach {
        mockkStatic(PrinterHelper::class)
        mockkStatic(HPRTPrinterHelper::class)
    }

    afterEach {
        unmockkStatic(PrinterHelper::class)
        unmockkStatic(HPRTPrinterHelper::class)
    }

    describe("setLogLevel") {
        it("success") {
            val log = mockk<Log>(relaxed = true)

            val methodHandler = FlutterLabelPrinterMethodHandler(context, bluetoothSearcher)
            methodHandler.log = log

            val result = mockk<MethodChannel.Result>(relaxed = true)

            methodHandler.onMethodCall(
                MethodCall(
                    "hk.gogovan.label_printer.setLogLevel",
                    mapOf("level" to 1),
                ), result
            )
            verify { log.setLogLevel(1) }
        }
    }

    describe("stopSearchBluetooth") {
        it("success") {
            every { bluetoothSearcher.stopScan() }.returns(true)
            val methodHandler = FlutterLabelPrinterMethodHandler(context, bluetoothSearcher)

            val result = mockk<MethodChannel.Result>(relaxed = true)

            methodHandler.onMethodCall(
                MethodCall(
                    "hk.gogovan.label_printer.stopSearchBluetooth", null
                ), result
            )
            verify { bluetoothSearcher.stopScan() }
            verify { result.success(true) }
        }
    }

    data class ConnectTestEntry(
        val methodName: String,
        val sdkMethod: () -> Int,
        val isOpenedMethod: () -> Boolean
    )

    val connectTests = listOf(
        ConnectTestEntry(
            "hk.gogovan.label_printer.hanin.cpcl.connect",
            { PrinterHelper.portOpenBT(context, "abcd1234") },
            { PrinterHelper.IsOpened() }),
        ConnectTestEntry(
            "hk.gogovan.label_printer.hanin.tspl.connect",
            { HPRTPrinterHelper.PortOpen("abcd1234") },
            { HPRTPrinterHelper.IsOpened() }),
    )

    describe("connect") {
        connectTests.forEach { entry ->
            it("success ${entry.methodName}") {
                every { entry.sdkMethod() }.returns(0)
                val methodHandler = FlutterLabelPrinterMethodHandler(context, bluetoothSearcher)

                val result = mockk<MethodChannel.Result>(relaxed = true)

                methodHandler.onMethodCall(
                    MethodCall(
                        entry.methodName,
                        mapOf("address" to "abcd1234"),
                    ), result
                )
                verify { entry.sdkMethod() }
                verify { result.success(true) }
            }

            it("failure ${entry.methodName}") {
                every { entry.sdkMethod() }.returns(-5)
                val methodHandler = FlutterLabelPrinterMethodHandler(context, bluetoothSearcher)

                val result = mockk<MethodChannel.Result>(relaxed = true)

                methodHandler.onMethodCall(
                    MethodCall(
                        entry.methodName,
                        mapOf("address" to "abcd1234"),
                    ), result
                )
                verify { entry.sdkMethod() }
                verify { result.error("1006", "Connection error.", any()) }
            }

            it("fail because IsOpened ${entry.methodName}") {
                every { entry.isOpenedMethod() }.returns(true)
                val methodHandler = FlutterLabelPrinterMethodHandler(context, bluetoothSearcher)

                val result = mockk<MethodChannel.Result>(relaxed = true)

                methodHandler.onMethodCall(
                    MethodCall(
                        entry.methodName,
                        mapOf("address" to "abcd1234"),
                    ), result
                )
                verify { result.error("1005", "Printer already connected.", any()) }
            }

            it("fail because address null ${entry.methodName}") {
                val methodHandler = FlutterLabelPrinterMethodHandler(context, bluetoothSearcher)

                val result = mockk<MethodChannel.Result>(relaxed = true)

                methodHandler.onMethodCall(
                    MethodCall(
                        entry.methodName, null
                    ), result
                )
                verify { result.error("1000", "Unable to extract arguments.", any()) }
            }
        }
    }

    data class TestEntry<SRT>(
        val methodName: String,
        val arguments: Map<String, Any>?,
        val sdkCall: () -> SRT,
        val sdkCallReturn: SRT,
    )

    val testList = listOf(
        TestEntry(
            "hk.gogovan.label_printer.hanin.cpcl.disconnect",
            null,
            { PrinterHelper.portClose() },
            true
        ),
        TestEntry(
            "hk.gogovan.label_printer.hanin.cpcl.setPrintAreaSize", mapOf(
                "offset" to 5,
                "height" to 480,
            ), { PrinterHelper.printAreaSize("5", "200", "200", "480", "1") }, 1
        ),
        TestEntry(
            "hk.gogovan.label_printer.hanin.cpcl.addText",
            mapOf("rotate" to 0, "font" to 1, "x" to 240, "y" to 160, "text" to "Hello World!"),
            { PrinterHelper.Text(PrinterHelper.TEXT, "1", "0", "240", "160", "Hello World!") }, 1
        ),
        TestEntry("hk.gogovan.label_printer.hanin.cpcl.print", null, { PrinterHelper.Print() }, 1),
        TestEntry(
            "hk.gogovan.label_printer.hanin.cpcl.setPaperType",
            mapOf("paperType" to 1),
            { PrinterHelper.setPaperFourInch(1) },
            1
        ),
        TestEntry(
            "hk.gogovan.label_printer.hanin.cpcl.setBold",
            mapOf("size" to 2),
            { PrinterHelper.SetBold("2") },
            1
        ),
        TestEntry(
            "hk.gogovan.label_printer.hanin.cpcl.setBold",
            mapOf("size" to 6),
            { PrinterHelper.SetBold("5") },
            1
        ),
        TestEntry(
            "hk.gogovan.label_printer.hanin.cpcl.setTextSize",
            mapOf("width" to 2, "height" to 3),
            { PrinterHelper.SetMag("2", "3") },
            1
        ),
        TestEntry(
            "hk.gogovan.label_printer.hanin.cpcl.setTextSize",
            mapOf("width" to 0, "height" to 24),
            { PrinterHelper.SetMag("1", "16") },
            1
        ),
        // TestEntry("hk.gogovan.label_printer.hanin.cpcl.getStatus"),
        TestEntry(
            "hk.gogovan.label_printer.hanin.cpcl.space",
            mapOf("dot" to 80),
            { PrinterHelper.Prefeed("80") },
            1
        ),
        TestEntry(
            "hk.gogovan.label_printer.hanin.cpcl.setPageWidth",
            mapOf("width" to 80),
            { PrinterHelper.PageWidth("80") },
            1
        ),
        TestEntry(
            "hk.gogovan.label_printer.hanin.cpcl.setAlign",
            mapOf("align" to 1),
            { PrinterHelper.Align(PrinterHelper.CENTER) },
            1
        ),
        TestEntry(
            "hk.gogovan.label_printer.hanin.cpcl.addBarcode",
            mapOf(
                "type" to "code39",
                "data" to "https://example.com",
                "width" to 3,
                "height" to 2,
                "x" to 100,
                "y" to 120
            ),
            {
                PrinterHelper.Barcode(
                    PrinterHelper.BARCODE,
                    PrinterHelper.code39,
                    "3",
                    "0",
                    "2",
                    "100",
                    "120",
                    false,
                    "null",
                    "null",
                    "null",
                    "https://example.com"
                )
            }, 1
        ),
        TestEntry(
            "hk.gogovan.label_printer.hanin.cpcl.addBarcode", mapOf(
                "type" to "CODE39",
                "data" to "https://example.com",
                "width" to 3,
                "height" to 2,
                "x" to 100,
                "y" to 120,
                "showData" to true,
                "dataFont" to 6,
                "dataTextSize" to 2,
                "dataTextOffset" to 0,
            ), {
                PrinterHelper.Barcode(
                    PrinterHelper.BARCODE,
                    PrinterHelper.code39,
                    "3",
                    "0",
                    "2",
                    "100",
                    "120",
                    true,
                    "6",
                    "2",
                    "0",
                    "https://example.com"
                )
            }, 1
        ),
        TestEntry(
            "hk.gogovan.label_printer.hanin.cpcl.addQRCode",
            mapOf("data" to "https://example.com", "x" to 100, "y" to 120, "unitSize" to 5),
            {
                PrinterHelper.PrintQR(
                    PrinterHelper.BARCODE,
                    "100",
                    "120",
                    "0",
                    "5",
                    "https://example.com"
                )
            }, 1
        ),
        TestEntry(
            "hk.gogovan.label_printer.hanin.cpcl.addRectangle",
            mapOf("x0" to 10, "y0" to 20, "x1" to 30, "y1" to 40, "width" to 3),
            { PrinterHelper.Box("10", "20", "30", "40", "3") },
            1
        ),
        TestEntry(
            "hk.gogovan.label_printer.hanin.cpcl.addLine",
            mapOf("x0" to 10, "y0" to 20, "x1" to 30, "y1" to 40, "width" to 3),
            { PrinterHelper.Line("10", "20", "30", "40", "3") },
            1
        ),
        TestEntry(
            "hk.gogovan.label_printer.hanin.tspl.disconnect",
            null,
            { HPRTPrinterHelper.PortClose() },
            true
        ),
        TestEntry(
            "hk.gogovan.label_printer.hanin.tspl.setPrintAreaSize",
            mapOf("width" to 80, "height" to 60),
            { HPRTPrinterHelper.printAreaSize("80", "60") }, 1
        ),
        TestEntry(
            "hk.gogovan.label_printer.hanin.tspl.addText",
            mapOf("font" to 9, "x" to 40, "y" to 20, "text" to "Hello World!"),
            { HPRTPrinterHelper.printText("40", "20", "9", "0", "0", "0", 1, "Hello World!") }, 1
        ),
        TestEntry(
            "hk.gogovan.label_printer.hanin.tspl.print",
            null, { HPRTPrinterHelper.Print("1", "1") }, 1
        ),
        TestEntry(
            "hk.gogovan.label_printer.hanin.tspl.clear",
            null, { HPRTPrinterHelper.CLS() }, 1
        ),
        TestEntry(
            "hk.gogovan.label_printer.hanin.tspl.space",
            mapOf("mm" to 30), { HPRTPrinterHelper.Offset("30") }, 1
        ),
        TestEntry(
            "hk.gogovan.label_printer.hanin.tspl.addBarcode",
            mapOf("x" to 40, "y" to 20, "type" to "39", "height" to 50, "data" to "APV92"),
            { HPRTPrinterHelper.printBarcode("40", "20", "39", "50", "0", "0", "1", "1", "APV92") },
            1
        ),
        TestEntry(
            "hk.gogovan.label_printer.hanin.tspl.addQRCode",
            mapOf("x" to 40, "y" to 20, "unitSize" to 6, "data" to "https://example.com"),
            {
                HPRTPrinterHelper.printQRcode(
                    "40",
                    "20",
                    "L",
                    "6",
                    "A",
                    "0",
                    "https://example.com"
                )
            }, 1
        ),
        TestEntry(
            "hk.gogovan.label_printer.hanin.tspl.addRectangle",
            mapOf("x0" to 10, "y0" to 20, "x1" to 30, "y1" to 40, "width" to 3),
            { HPRTPrinterHelper.Box("10", "20", "30", "40", "3") },
            1
        ),
        TestEntry(
            "hk.gogovan.label_printer.hanin.tspl.addLine",
            mapOf("x0" to 10, "y0" to 20, "x1" to 30, "y1" to 40),
            { HPRTPrinterHelper.Bar("10", "20", "30", "40") },
            1
        ),
    )

    describe("generic method list") {
        testList.forEach { entry ->
            it("method success ${entry.methodName}") {
                every { PrinterHelper.IsOpened() }.returns(true)
                every { HPRTPrinterHelper.IsOpened() }.returns(true)
                every { entry.sdkCall() }.returns(entry.sdkCallReturn)

                val log = mockk<Log>()
                every { log.w(any()) } just Runs
                every {
                    context.getSharedPreferences(
                        "hk.gogovan.label_printer.flutter_label_printer",
                        Context.MODE_PRIVATE
                    ).edit().putInt(any(), any()).apply()
                } just Runs

                mockkStatic(TextUtils::class)
                every { TextUtils.isEmpty(any()) }.answers { call -> (call.invocation.args.first() as String).isNotEmpty() }

                val methodHandler = FlutterLabelPrinterMethodHandler(context, bluetoothSearcher)
                methodHandler.log = log

                val result = mockk<MethodChannel.Result>(relaxed = true)

                methodHandler.onMethodCall(
                    MethodCall(
                        entry.methodName, entry.arguments
                    ), result
                )
                verify { result.success(true) }
                verify { entry.sdkCall() }
            }
        }

        testList.forEach { entry ->
            it("method fail because Is not Opened ${entry.methodName}") {
                val methodHandler = FlutterLabelPrinterMethodHandler(context, bluetoothSearcher)

                val result = mockk<MethodChannel.Result>(relaxed = true)

                methodHandler.onMethodCall(
                    MethodCall(entry.methodName, null), result
                )
                verify { result.error("1005", "Printer not connected.", any()) }
            }
        }
    }


    describe("getStatusHMA300L") {
        it("success") {
            every { PrinterHelper.IsOpened() }.returns(true)
            every { PrinterHelper.getstatus() }.returns(6)

            val methodHandler = FlutterLabelPrinterMethodHandler(context, bluetoothSearcher)

            val result = mockk<MethodChannel.Result>(relaxed = true)
            methodHandler.onMethodCall(
                MethodCall(
                    "hk.gogovan.label_printer.hanin.cpcl.getStatus", null,
                ), result
            )
            verify { result.success(6) }
        }
    }

    describe("setAlignHMA300L") {
        beforeEach {
            every { PrinterHelper.IsOpened() }.returns(true)
            every { PrinterHelper.Align(any()) }.returns(1)
        }

        it("wrong param failure") {
            val methodHandler = FlutterLabelPrinterMethodHandler(context, bluetoothSearcher)

            val result = mockk<MethodChannel.Result>(relaxed = true)
            methodHandler.onMethodCall(
                MethodCall(
                    "hk.gogovan.label_printer.hanin.cpcl.setAlign",
                    mapOf("align" to 4),
                ), result
            )
            verify { result.error("1009", any(), any()) }
        }
    }

    describe("addBarcode") {
        val methodHandler = FlutterLabelPrinterMethodHandler(context, bluetoothSearcher)

        beforeEach {
            every { PrinterHelper.IsOpened() }.returns(true)
            every {
                PrinterHelper.Barcode(
                    any(),
                    any(),
                    any(),
                    any(),
                    any(),
                    any(),
                    any(),
                    any(),
                    any(),
                    any(),
                    any(),
                    any()
                )
            }.returns(1)
        }

        it("wrong barcode type") {
            val result = mockk<MethodChannel.Result>(relaxed = true)
            methodHandler.onMethodCall(
                MethodCall(
                    "hk.gogovan.label_printer.hanin.cpcl.addBarcode",
                    mapOf(
                        "orientation" to 2,
                    ),
                ), result
            )
            verify { result.error("1009", any(), any()) }
        }

        it("wrong type") {
            val result = mockk<MethodChannel.Result>(relaxed = true)
            methodHandler.onMethodCall(
                MethodCall(
                    "hk.gogovan.label_printer.hanin.cpcl.addBarcode",
                    mapOf(
                        "type" to 10,
                    ),
                ), result
            )
            verify { result.error("1009", any(), any()) }
        }

        it("missing showData info") {
            val result = mockk<MethodChannel.Result>(relaxed = true)
            methodHandler.onMethodCall(
                MethodCall(
                    "hk.gogovan.label_printer.hanin.cpcl.addBarcode",
                    mapOf(
                        "showData" to true,
                    ),
                ), result
            )
            verify { result.error("1009", any(), any()) }
        }

        it("wrong ratio") {
            val result = mockk<MethodChannel.Result>(relaxed = true)
            methodHandler.onMethodCall(
                MethodCall(
                    "hk.gogovan.label_printer.hanin.cpcl.addBarcode",
                    mapOf(
                        "ratio" to 11,
                    ),
                ), result
            )
            verify { result.error("1009", any(), any()) }
        }
    }

    describe("addQRCode") {
        val methodHandler = FlutterLabelPrinterMethodHandler(context, bluetoothSearcher)

        beforeEach {
            every { PrinterHelper.IsOpened() }.returns(true)
            every {
                PrinterHelper.PrintQR(any(), any(), any(), any(), any(), any())
            }.returns(1)
        }

        it("wrong barcode type") {
            val result = mockk<MethodChannel.Result>(relaxed = true)
            methodHandler.onMethodCall(
                MethodCall(
                    "hk.gogovan.label_printer.hanin.cpcl.addQRCode",
                    mapOf(
                        "orientation" to 2,
                    ),
                ), result
            )
            verify { result.error("1009", any(), any()) }
        }

        it("error unit size value") {
            val result = mockk<MethodChannel.Result>(relaxed = true)
            methodHandler.onMethodCall(
                MethodCall(
                    "hk.gogovan.label_printer.hanin.cpcl.addQRCode",
                    mapOf(
                        "unitSize" to 45,
                    ),
                ), result
            )
            verify { result.error("1009", any(), any()) }
        }
    }

    describe("addImage") {
        beforeEach {
            every { PrinterHelper.IsOpened() }.returns(true)
            every {
                PrinterHelper.printBitmapCPCL(any(), any(), any(), any(), any(), any())
            }.returns(1)

            mockkStatic(BitmapFactory::class)
        }

        afterEach {
            unmockkStatic(BitmapFactory::class)
        }

        it("success") {
            val image = mockk<Bitmap>()
            every { BitmapFactory.decodeFile("/sdcard/DCIM/1") }.returns(image)

            val methodHandler = FlutterLabelPrinterMethodHandler(context, bluetoothSearcher)

            val result = mockk<MethodChannel.Result>(relaxed = true)
            methodHandler.onMethodCall(
                MethodCall(
                    "hk.gogovan.label_printer.hanin.cpcl.addImage",
                    mapOf(
                        "imagePath" to "/sdcard/DCIM/1",
                        "x" to 100,
                        "y" to 200
                    ),
                ), result
            )
            verify { result.success(true) }
            verify { PrinterHelper.printBitmapCPCL(image, 100, 200, 0, 0, 0) }
        }

        it("failure no image") {
            every { BitmapFactory.decodeFile("/sdcard/DCIM/1") }.returns(null)

            val methodHandler = FlutterLabelPrinterMethodHandler(context, bluetoothSearcher)

            val result = mockk<MethodChannel.Result>(relaxed = true)
            methodHandler.onMethodCall(
                MethodCall(
                    "hk.gogovan.label_printer.hanin.cpcl.addImage",
                    mapOf(
                        "imagePath" to "/sdcard/DCIM/1",
                        "x" to 100,
                        "y" to 200
                    ),
                ), result
            )
        }
    }
})