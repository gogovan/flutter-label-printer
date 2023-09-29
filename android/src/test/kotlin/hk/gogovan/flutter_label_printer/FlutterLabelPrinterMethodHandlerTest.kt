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
    }

    afterEach {
        unmockkStatic(PrinterHelper::class)
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

    describe("stopSearchHMA300L") {
        it("success") {
            every { bluetoothSearcher.stopScan() }.returns(true)
            val methodHandler = FlutterLabelPrinterMethodHandler(context, bluetoothSearcher)

            val result = mockk<MethodChannel.Result>(relaxed = true)

            methodHandler.onMethodCall(
                MethodCall(
                    "hk.gogovan.label_printer.stopSearchHMA300L", null
                ), result
            )
            verify { bluetoothSearcher.stopScan() }
            verify { result.success(true) }
        }
    }

    describe("connectHMA300L") {
        it("success") {
            every { PrinterHelper.portOpenBT(context, "abcd1234") }.returns(0)
            val methodHandler = FlutterLabelPrinterMethodHandler(context, bluetoothSearcher)

            val result = mockk<MethodChannel.Result>(relaxed = true)

            methodHandler.onMethodCall(
                MethodCall(
                    "hk.gogovan.label_printer.connectHMA300L",
                    mapOf("address" to "abcd1234"),
                ), result
            )
            verify { PrinterHelper.portOpenBT(context, "abcd1234") }
            verify { result.success(true) }
        }

        it("failure") {
            every { PrinterHelper.portOpenBT(context, "abcd1234") }.returns(-1)
            val methodHandler = FlutterLabelPrinterMethodHandler(context, bluetoothSearcher)

            val result = mockk<MethodChannel.Result>(relaxed = true)

            methodHandler.onMethodCall(
                MethodCall(
                    "hk.gogovan.label_printer.connectHMA300L",
                    mapOf("address" to "abcd1234"),
                ), result
            )
            verify { PrinterHelper.portOpenBT(context, "abcd1234") }
            verify { result.error("1008", "Connection timed out.", any()) }
        }

        it("fail because IsOpened") {
            every { PrinterHelper.IsOpened() }.returns(true)
            val methodHandler = FlutterLabelPrinterMethodHandler(context, bluetoothSearcher)

            val result = mockk<MethodChannel.Result>(relaxed = true)

            methodHandler.onMethodCall(
                MethodCall(
                    "hk.gogovan.label_printer.connectHMA300L",
                    mapOf("address" to "abcd1234"),
                ), result
            )
            verify { result.error("1005", "Printer already connected.", any()) }
        }

        it("fail because address null") {
            val methodHandler = FlutterLabelPrinterMethodHandler(context, bluetoothSearcher)

            val result = mockk<MethodChannel.Result>(relaxed = true)

            methodHandler.onMethodCall(
                MethodCall(
                    "hk.gogovan.label_printer.connectHMA300L", null
                ), result
            )
            verify { result.error("1000", "Unable to extract arguments.", any()) }
        }
    }

    describe("PrinterHelper Not opened errors") {
        listOf(
            "hk.gogovan.label_printer.disconnectHMA300L",
            "hk.gogovan.label_printer.setPrintAreaSizeHMA300L",
            "hk.gogovan.label_printer.addTextHMA300L",
            "hk.gogovan.label_printer.printHMA300L",
            "hk.gogovan.label_printer.setPaperTypeHMA300L",
            "hk.gogovan.label_printer.setBoldHMA300L",
            "hk.gogovan.label_printer.setTextSizeHMA300L",
            "hk.gogovan.label_printer.getStatusHMA300L",
            "hk.gogovan.label_printer.prefeedHMA300L",
            "hk.gogovan.label_printer.setPageWidthHMA300L",
            "hk.gogovan.label_printer.setAlignHMA300L",
            "hk.gogovan.label_printer.addBarcode",
            "hk.gogovan.label_printer.addQRCode",
            "hk.gogovan.label_printer.addRectangle",
            "hk.gogovan.label_printer.addLine",
            "hk.gogovan.label_printer.addImage",
        ).forEach { method ->
            it("method fail because Is not Opened") {
                val methodHandler = FlutterLabelPrinterMethodHandler(context, bluetoothSearcher)

                val result = mockk<MethodChannel.Result>(relaxed = true)

                methodHandler.onMethodCall(
                    MethodCall(method, null), result
                )
                verify { result.error("1005", "Printer not connected.", any()) }
            }
        }
    }

    describe("disconnectHMA300L") {
        it("success") {
            every { PrinterHelper.IsOpened() }.returns(true)
            val methodHandler = FlutterLabelPrinterMethodHandler(context, bluetoothSearcher)

            val result = mockk<MethodChannel.Result>(relaxed = true)

            methodHandler.onMethodCall(
                MethodCall(
                    "hk.gogovan.label_printer.disconnectHMA300L", null
                ), result
            )
            verify { result.success(true) }
            verify { PrinterHelper.portClose() }
        }
    }

    describe("setPrintAreaSizeHMA300L") {
        it("success") {
            every { PrinterHelper.IsOpened() }.returns(true)
            every { PrinterHelper.printAreaSize(any(), any(), any(), any(), any()) }.returns(1)
            val methodHandler = FlutterLabelPrinterMethodHandler(context, bluetoothSearcher)

            val result = mockk<MethodChannel.Result>(relaxed = true)

            methodHandler.onMethodCall(
                MethodCall(
                    "hk.gogovan.label_printer.setPrintAreaSizeHMA300L",
                    mapOf(
                        "offset" to 5,
                        "height" to 480,
                    ),
                ), result
            )
            verify { result.success(true) }
            verify { PrinterHelper.printAreaSize("5", "200", "200", "480", "1") }
        }
    }

    describe("addTextHMA300L") {
        it("success") {
            every { PrinterHelper.IsOpened() }.returns(true)
            every { PrinterHelper.Text(any(), any(), any(), any(), any(), any()) }.returns(1)
            val methodHandler = FlutterLabelPrinterMethodHandler(context, bluetoothSearcher)

            mockkStatic(TextUtils::class)
            every { TextUtils.isEmpty(any()) }.returns(false)

            val result = mockk<MethodChannel.Result>(relaxed = true)

            methodHandler.onMethodCall(
                MethodCall(
                    "hk.gogovan.label_printer.addTextHMA300L",
                    mapOf(
                        "rotate" to 0,
                        "font" to 1,
                        "x" to 240,
                        "y" to 160,
                        "text" to "Hello World!",
                    ),
                ), result
            )
            verify { result.success(true) }
            verify {
                PrinterHelper.Text(
                    PrinterHelper.TEXT,
                    "1",
                    "0",
                    "240",
                    "160",
                    "Hello World!"
                )
            }
        }
    }

    describe("printHMA300L") {
        it("success") {
            every { PrinterHelper.IsOpened() }.returns(true)
            every { PrinterHelper.Print() }.returns(1)

            val log = mockk<Log>()
            every { log.w(any()) } just Runs

            val methodHandler = FlutterLabelPrinterMethodHandler(context, bluetoothSearcher)
            methodHandler.log = log

            val result = mockk<MethodChannel.Result>(relaxed = true)

            methodHandler.onMethodCall(
                MethodCall(
                    "hk.gogovan.label_printer.printHMA300L", null
                ), result
            )
            verify { result.success(true) }
            verify { PrinterHelper.Print() }
        }
    }

    describe("setPaperTypeHMA300L") {
        it("success") {
            every { PrinterHelper.IsOpened() }.returns(true)
            every { PrinterHelper.setPaperFourInch(any()) }.returns(1)

            every {
                context.getSharedPreferences(
                    "hk.gogovan.label_printer.flutter_label_printer",
                    Context.MODE_PRIVATE
                ).edit().putInt(any(), any()).apply()
            } just Runs

            val methodHandler = FlutterLabelPrinterMethodHandler(context, bluetoothSearcher)

            val result = mockk<MethodChannel.Result>(relaxed = true)
            methodHandler.onMethodCall(
                MethodCall(
                    "hk.gogovan.label_printer.setPaperTypeHMA300L",
                    mapOf("paperType" to 1),
                ), result
            )
            verify { result.success(true) }
            verify { PrinterHelper.setPaperFourInch(1) }
        }
    }

    describe("setBoldHMA300L") {
        val methodHandler = FlutterLabelPrinterMethodHandler(context, bluetoothSearcher)
        beforeEach {
            every { PrinterHelper.IsOpened() }.returns(true)
            every { PrinterHelper.SetBold(any()) }.returns(1)
        }

        it("success") {
            val result = mockk<MethodChannel.Result>(relaxed = true)
            methodHandler.onMethodCall(
                MethodCall(
                    "hk.gogovan.label_printer.setBoldHMA300L",
                    mapOf("size" to 2),
                ), result
            )
            verify { result.success(true) }
            verify { PrinterHelper.SetBold("2") }
        }

        it("exceed range success") {
            val result = mockk<MethodChannel.Result>(relaxed = true)
            methodHandler.onMethodCall(
                MethodCall(
                    "hk.gogovan.label_printer.setBoldHMA300L",
                    mapOf("size" to 6),
                ), result
            )
            verify { result.success(true) }
            verify { PrinterHelper.SetBold("5") }
        }
    }

    describe("setTextSizeHMA300L") {
        val methodHandler = FlutterLabelPrinterMethodHandler(context, bluetoothSearcher)

        beforeEach {
            every { PrinterHelper.IsOpened() }.returns(true)
            every { PrinterHelper.SetMag(any(), any()) }.returns(1)
        }

        it("success") {
            val result = mockk<MethodChannel.Result>(relaxed = true)
            methodHandler.onMethodCall(
                MethodCall(
                    "hk.gogovan.label_printer.setTextSizeHMA300L",
                    mapOf("width" to 2, "height" to 3),
                ), result
            )
            verify { result.success(true) }
            verify { PrinterHelper.SetMag("2", "3") }
        }

        it("exceed range success") {
            val result = mockk<MethodChannel.Result>(relaxed = true)
            methodHandler.onMethodCall(
                MethodCall(
                    "hk.gogovan.label_printer.setTextSizeHMA300L",
                    mapOf("width" to 0, "height" to 24),
                ), result
            )
            verify { result.success(true) }
            verify { PrinterHelper.SetMag("1", "16") }
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
                    "hk.gogovan.label_printer.getStatusHMA300L", null,
                ), result
            )
            verify { result.success(6) }
        }
    }

    describe("prefeedHMA300L") {
        it("success") {
            every { PrinterHelper.IsOpened() }.returns(true)
            every { PrinterHelper.Prefeed(any()) }.returns(1)

            val methodHandler = FlutterLabelPrinterMethodHandler(context, bluetoothSearcher)

            val result = mockk<MethodChannel.Result>(relaxed = true)
            methodHandler.onMethodCall(
                MethodCall(
                    "hk.gogovan.label_printer.prefeedHMA300L",
                    mapOf("dot" to 80),
                ), result
            )
            verify { result.success(true) }
            verify { PrinterHelper.Prefeed("80") }
        }
    }

    describe("setPageWidthHMA300L") {
        it("success") {
            every { PrinterHelper.IsOpened() }.returns(true)
            every { PrinterHelper.PageWidth(any()) }.returns(1)

            val methodHandler = FlutterLabelPrinterMethodHandler(context, bluetoothSearcher)

            val result = mockk<MethodChannel.Result>(relaxed = true)
            methodHandler.onMethodCall(
                MethodCall(
                    "hk.gogovan.label_printer.setPageWidthHMA300L",
                    mapOf("width" to 80),
                ), result
            )
            verify { result.success(true) }
            verify { PrinterHelper.PageWidth("80") }
        }
    }

    describe("setAlignHMA300L") {
        beforeEach {
            every { PrinterHelper.IsOpened() }.returns(true)
            every { PrinterHelper.Align(any()) }.returns(1)
        }

        it("success") {
            val methodHandler = FlutterLabelPrinterMethodHandler(context, bluetoothSearcher)

            val result = mockk<MethodChannel.Result>(relaxed = true)
            methodHandler.onMethodCall(
                MethodCall(
                    "hk.gogovan.label_printer.setAlignHMA300L",
                    mapOf("align" to 1),
                ), result
            )
            verify { result.success(true) }
            verify { PrinterHelper.Align(PrinterHelper.CENTER) }
        }

        it("wrong param failure") {
            val methodHandler = FlutterLabelPrinterMethodHandler(context, bluetoothSearcher)

            val result = mockk<MethodChannel.Result>(relaxed = true)
            methodHandler.onMethodCall(
                MethodCall(
                    "hk.gogovan.label_printer.setAlignHMA300L",
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

        it("success") {
            val result = mockk<MethodChannel.Result>(relaxed = true)
            methodHandler.onMethodCall(
                MethodCall(
                    "hk.gogovan.label_printer.addBarcode",
                    mapOf(
                        "type" to 4,
                        "data" to "https://example.com",
                        "width" to 3,
                        "height" to 2,
                        "x" to 100,
                        "y" to 120,
                    ),
                ), result
            )
            verify { result.success(true) }
            verify {
                PrinterHelper.Barcode(
                    PrinterHelper.BARCODE,
                    PrinterHelper.code39,
                    "3",
                    "0",
                    "2",
                    "100",
                    "120",
                    false,
                    any(),
                    any(),
                    any(),
                    "https://example.com"
                )
            }
        }

        it("success with showData") {
            val result = mockk<MethodChannel.Result>(relaxed = true)
            methodHandler.onMethodCall(
                MethodCall(
                    "hk.gogovan.label_printer.addBarcode",
                    mapOf(
                        "type" to 4,
                        "data" to "https://example.com",
                        "width" to 3,
                        "height" to 2,
                        "x" to 100,
                        "y" to 120,
                        "showData" to true,
                        "dataFont" to 6,
                        "dataTextSize" to 2,
                        "dataTextOffset" to 0,
                    ),
                ), result
            )
            verify { result.success(true) }
            verify {
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
            }
        }

        it("wrong barcode type") {
            val result = mockk<MethodChannel.Result>(relaxed = true)
            methodHandler.onMethodCall(
                MethodCall(
                    "hk.gogovan.label_printer.addBarcode",
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
                    "hk.gogovan.label_printer.addBarcode",
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
                    "hk.gogovan.label_printer.addBarcode",
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
                    "hk.gogovan.label_printer.addBarcode",
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

        it("success") {
            val result = mockk<MethodChannel.Result>(relaxed = true)
            methodHandler.onMethodCall(
                MethodCall(
                    "hk.gogovan.label_printer.addQRCode",
                    mapOf(
                        "data" to "https://example.com",
                        "x" to 100,
                        "y" to 120,
                        "unitSize" to 5,
                    ),
                ), result
            )
            verify { result.success(true) }
            verify {
                PrinterHelper.PrintQR(
                    PrinterHelper.BARCODE, "100", "120", "0", "5", "https://example.com"
                )
            }
        }

        it("wrong barcode type") {
            val result = mockk<MethodChannel.Result>(relaxed = true)
            methodHandler.onMethodCall(
                MethodCall(
                    "hk.gogovan.label_printer.addQRCode",
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
                    "hk.gogovan.label_printer.addQRCode",
                    mapOf(
                        "unitSize" to 45,
                    ),
                ), result
            )
            verify { result.error("1009", any(), any()) }
        }
    }

    describe("addRectangle") {
        it("success") {
            every { PrinterHelper.IsOpened() }.returns(true)
            every {
                PrinterHelper.Box(any(), any(), any(), any(), any())
            }.returns(1)

            val methodHandler = FlutterLabelPrinterMethodHandler(context, bluetoothSearcher)

            val result = mockk<MethodChannel.Result>(relaxed = true)
            methodHandler.onMethodCall(
                MethodCall(
                    "hk.gogovan.label_printer.addRectangle",
                    mapOf(
                        "x0" to 10,
                        "y0" to 20,
                        "x1" to 30,
                        "y1" to 40,
                        "width" to 3,
                    ),
                ), result
            )
            verify { result.success(true) }
            verify { PrinterHelper.Box("10", "20", "30", "40", "3") }
        }
    }

    describe("addLine") {
        it("success") {
            every { PrinterHelper.IsOpened() }.returns(true)
            every {
                PrinterHelper.Line(any(), any(), any(), any(), any())
            }.returns(1)

            val methodHandler = FlutterLabelPrinterMethodHandler(context, bluetoothSearcher)

            val result = mockk<MethodChannel.Result>(relaxed = true)
            methodHandler.onMethodCall(
                MethodCall(
                    "hk.gogovan.label_printer.addLine",
                    mapOf(
                        "x0" to 10,
                        "y0" to 20,
                        "x1" to 30,
                        "y1" to 40,
                        "width" to 3,
                    ),
                ), result
            )
            verify { result.success(true) }
            verify { PrinterHelper.Line("10", "20", "30", "40", "3") }
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
                    "hk.gogovan.label_printer.addImage",
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
                    "hk.gogovan.label_printer.addImage",
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