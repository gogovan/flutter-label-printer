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
import io.mockk.Runs
import io.mockk.every
import io.mockk.impl.annotations.MockK
import io.mockk.junit4.MockKRule
import io.mockk.just
import io.mockk.mockk
import io.mockk.mockkStatic
import io.mockk.runs
import io.mockk.verify
import junit.framework.Assert.assertEquals
import org.junit.Before
import org.junit.Rule
import org.junit.Test

class FlutterLabelPrinterMethodHandlerTest {
    @get:Rule
    val mockkRule = MockKRule(this)

    @MockK
    lateinit var context: Context

    @MockK
    lateinit var bluetoothSearcher: BluetoothSearcher

    @Before
    fun setup() {
        every {
            context.getSharedPreferences("hk.gogovan.label_printer.flutter_label_printer", 0)
                .getInt("paper_type", 0)
        }.returns(0)
    }

    @Test
    fun `test setLogLevel`() {
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

    @Test
    fun `test stopSearchHMA300L`() {
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

    @Test
    fun `test connectHMA300L success`() {
        mockkStatic(PrinterHelper::class)
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

    @Test
    fun `test connectHMA300L failure`() {
        mockkStatic(PrinterHelper::class)
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

    @Test
    fun `test connectHMA300L fail because IsOpened`() {
        mockkStatic(PrinterHelper::class)
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

    @Test
    fun `test connectHMA300L fail because address null`() {
        val methodHandler = FlutterLabelPrinterMethodHandler(context, bluetoothSearcher)

        val result = mockk<MethodChannel.Result>(relaxed = true)

        methodHandler.onMethodCall(
            MethodCall(
                "hk.gogovan.label_printer.connectHMA300L", null
            ), result
        )
        verify { result.error("1000", "Unable to extract arguments.", any()) }
    }

    @Test
    fun `test various method fail because Is not Opened`() {
        mockkStatic(PrinterHelper::class)
        val methodHandler = FlutterLabelPrinterMethodHandler(context, bluetoothSearcher)

        val result = mockk<MethodChannel.Result>(relaxed = true)

        val methodNames = listOf(
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

            )
        for (method in methodNames) {
            methodHandler.onMethodCall(
                MethodCall(method, null), result
            )
            verify { result.error("1005", "Printer not connected.", any()) }
        }
    }

    @Test
    fun `test disconnectHMA300L success`() {
        mockkStatic(PrinterHelper::class)
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

    @Test
    fun `test setPrintAreaSizeHMA300L success`() {
        mockkStatic(PrinterHelper::class)
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

    @Test
    fun `test addTextHMA300L success`() {
        mockkStatic(PrinterHelper::class)
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
        verify { PrinterHelper.Text(PrinterHelper.TEXT, "1", "0", "240", "160", "Hello World!") }
    }

    @Test
    fun `test printHMA300L success`() {
        mockkStatic(PrinterHelper::class)
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

    @Test
    fun `test setPaperTypeHMA300L success`() {
        mockkStatic(PrinterHelper::class)
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

    @Test
    fun `test setBoldHMA300L success`() {
        mockkStatic(PrinterHelper::class)
        every { PrinterHelper.IsOpened() }.returns(true)
        every { PrinterHelper.SetBold(any()) }.returns(1)

        val methodHandler = FlutterLabelPrinterMethodHandler(context, bluetoothSearcher)

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

    @Test
    fun `test setTextSizeHMA300L success`() {
        mockkStatic(PrinterHelper::class)
        every { PrinterHelper.IsOpened() }.returns(true)
        every { PrinterHelper.SetMag(any(), any()) }.returns(1)

        val methodHandler = FlutterLabelPrinterMethodHandler(context, bluetoothSearcher)

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

    @Test
    fun `test getStatusHMA300L success`() {
        mockkStatic(PrinterHelper::class)
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

    @Test
    fun `test prefeedHMA300L success`() {
        mockkStatic(PrinterHelper::class)
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

    @Test
    fun `test setPageWidthHMA300L success`() {
        mockkStatic(PrinterHelper::class)
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

    @Test
    fun `test setAlignHMA300L success`() {
        mockkStatic(PrinterHelper::class)
        every { PrinterHelper.IsOpened() }.returns(true)
        every { PrinterHelper.Align(any()) }.returns(1)

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

    @Test
    fun `test addBarcode success`() {
        mockkStatic(PrinterHelper::class)
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

        val methodHandler = FlutterLabelPrinterMethodHandler(context, bluetoothSearcher)

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

    @Test
    fun `test addQRCode success`() {
        mockkStatic(PrinterHelper::class)
        every { PrinterHelper.IsOpened() }.returns(true)
        every {
            PrinterHelper.PrintQR(any(), any(), any(), any(), any(), any())
        }.returns(1)

        val methodHandler = FlutterLabelPrinterMethodHandler(context, bluetoothSearcher)

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

    @Test
    fun `test addRectangle success`() {
        mockkStatic(PrinterHelper::class)
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

    @Test
    fun `test testLine success`() {
        mockkStatic(PrinterHelper::class)
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

    @Test
    fun `test addImage success`() {
        mockkStatic(PrinterHelper::class)
        every { PrinterHelper.IsOpened() }.returns(true)
        every {
            PrinterHelper.printBitmapCPCL(any(), any(), any(), any(), any(), any())
        }.returns(1)

        mockkStatic(BitmapFactory::class)
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
}