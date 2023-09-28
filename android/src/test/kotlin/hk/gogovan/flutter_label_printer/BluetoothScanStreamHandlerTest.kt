package hk.gogovan.flutter_label_printer

import android.os.Handler
import android.os.Looper
import hk.gogovan.flutter_label_printer.searcher.BluetoothSearcher
import hk.gogovan.flutter_label_printer.util.ResultOr
import io.flutter.plugin.common.EventChannel
import io.mockk.coEvery
import io.mockk.every
import io.mockk.impl.annotations.MockK
import io.mockk.junit4.MockKRule
import io.mockk.mockk
import io.mockk.mockkConstructor
import io.mockk.mockkStatic
import io.mockk.slot
import io.mockk.verify
import kotlinx.coroutines.flow.flow
import org.junit.Rule
import org.junit.Test

class BluetoothScanStreamHandlerTest {
    @get:Rule
    val mockkRule = MockKRule(this)

    @MockK
    lateinit var bluetoothSearcher: BluetoothSearcher

    data class HandlerResult(val eventSink: EventChannel.EventSink, val streamHandler: BluetoothScanStreamHandler)
    private fun setupHandler(): HandlerResult {
        val eventSink = mockk<EventChannel.EventSink>(relaxed = true)
        val streamHandler = BluetoothScanStreamHandler(bluetoothSearcher)

        mockkStatic(Looper::class)
        every { Looper.getMainLooper() } returns mockk()

        mockkConstructor(Handler::class)
        val runnable = slot<Runnable>()
        every { anyConstructed<Handler>().post(capture(runnable)) } answers {
            runnable.captured.run();
            true
        }

        return HandlerResult(eventSink, streamHandler)
    }

    @Test
    fun `handle received values`() {
        val (eventSink, streamHandler) = setupHandler()

        coEvery { bluetoothSearcher.scan(any()) } returns flow {
            emit(ResultOr(listOf("123A")))
        }

        streamHandler.onListen(null, eventSink)

        verify {
            eventSink.success(listOf("123A"))
        }
    }

    @Test
    fun `handle plugin errors`() {
        val (eventSink, streamHandler) = setupHandler()

        coEvery { bluetoothSearcher.scan(any()) } returns flow {
            emit(ResultOr(PluginException(1010, "Cannot load image")));
        }

        streamHandler.onListen(null, eventSink)

        verify {
            eventSink.error("1010", "Cannot load image", any())
        }
    }
}