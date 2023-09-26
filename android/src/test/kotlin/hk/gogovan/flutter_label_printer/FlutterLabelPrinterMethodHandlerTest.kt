package hk.gogovan.flutter_label_printer

import android.content.Context
import cpcl.PrinterHelper
import hk.gogovan.flutter_label_printer.searcher.BluetoothSearcher
import hk.gogovan.flutter_label_printer.util.Log
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
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
            "hk.gogovan.label_printer.setPrintAreaSizeHMA300L"
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

}