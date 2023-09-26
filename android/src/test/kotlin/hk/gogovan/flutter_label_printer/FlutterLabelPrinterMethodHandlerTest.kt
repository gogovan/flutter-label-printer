package hk.gogovan.flutter_label_printer

import android.content.Context
import hk.gogovan.flutter_label_printer.searcher.BluetoothSearcher
import hk.gogovan.flutter_label_printer.util.Log
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.mockk.every
import io.mockk.impl.annotations.MockK
import io.mockk.junit4.MockKRule
import io.mockk.just
import io.mockk.mockk
import io.mockk.runs
import io.mockk.verify
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
    fun setLogLevel() {
        val log = mockk<Log>()
        every { log.setLogLevel(any()) } just runs

        val methodHandler = FlutterLabelPrinterMethodHandler(context, bluetoothSearcher)
        methodHandler.log = log

        val result = mockk<MethodChannel.Result>()

        methodHandler.onMethodCall(
            MethodCall(
                "hk.gogovan.label_printer.setLogLevel",
                mapOf("level" to 1),
            ), result
        )
        verify { log.setLogLevel(1) }
    }
}