package hk.gogovan.flutter_label_printer

import android.os.Handler
import android.os.Looper
import hk.gogovan.flutter_label_printer.searcher.BluetoothSearcher
import hk.gogovan.flutter_label_printer.util.ResultOr
import io.flutter.plugin.common.EventChannel
import io.kotest.core.spec.style.DescribeSpec
import io.kotest.core.test.TestScope
import io.mockk.coEvery
import io.mockk.every
import io.mockk.impl.annotations.MockK
import io.mockk.junit4.MockKRule
import io.mockk.mockk
import io.mockk.mockkConstructor
import io.mockk.mockkStatic
import io.mockk.slot
import io.mockk.verify
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.coroutineScope
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.test.StandardTestDispatcher
import kotlinx.coroutines.test.TestCoroutineScheduler
import kotlinx.coroutines.test.TestDispatcher
import org.junit.Rule
import org.junit.Test
import java.io.IOException

class BluetoothScanStreamHandlerTest: DescribeSpec({
    val bluetoothSearcher = mockk<BluetoothSearcher>()

    val eventSink = mockk<EventChannel.EventSink>(relaxed = true)
    val streamHandler = BluetoothScanStreamHandler(bluetoothSearcher)

    val testScheduler = TestCoroutineScheduler()
    streamHandler.coroutineScope = CoroutineScope(StandardTestDispatcher(testScheduler))

    beforeEach {
        mockkStatic(Looper::class)
        every { Looper.getMainLooper() } returns mockk()

        mockkConstructor(Handler::class)
        val runnable = slot<Runnable>()
        every { anyConstructed<Handler>().post(capture(runnable)) } answers {
            runnable.captured.run()
            true
        }
    }

    describe("handle received values") {
        it("success") {
            coEvery { bluetoothSearcher.scan(any()) } returns flow {
                emit(ResultOr(listOf("123A")))
            }

            streamHandler.onListen(null, eventSink)
            testScheduler.runCurrent()

            verify {
                eventSink.success(listOf("123A"))
            }
        }
    }

    describe("handle plugin errors") {
        it("errors") {
            coEvery { bluetoothSearcher.scan(any()) } returns flow {
                emit(ResultOr(PluginException(1010, "Cannot load image")));
            }

            streamHandler.onListen(null, eventSink)
            testScheduler.runCurrent()

            verify {
                eventSink.error("1010", "Cannot load image", any())
            }
        }
    }

    describe("handle other errors") {
        it("errors") {
            coEvery { bluetoothSearcher.scan(any()) } returns flow {
                emit(ResultOr(IOException("Cannot read image")));
            }

            streamHandler.onListen(null, eventSink)
            testScheduler.runCurrent()

            verify {
                eventSink.error("1004", any(), any())
            }
        }
    }
})