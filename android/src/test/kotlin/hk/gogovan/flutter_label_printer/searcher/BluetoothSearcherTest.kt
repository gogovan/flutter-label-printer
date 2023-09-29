package hk.gogovan.flutter_label_printer.searcher

import android.app.Activity
import android.bluetooth.BluetoothManager
import android.content.Context
import android.content.pm.PackageManager
import hk.gogovan.flutter_label_printer.PluginException
import hk.gogovan.flutter_label_printer.util.ResultOr
import io.kotest.assertions.asClue
import io.kotest.assertions.nondeterministic.eventually
import io.kotest.core.spec.style.DescribeSpec
import io.kotest.matchers.should
import io.kotest.matchers.shouldBe
import io.kotest.matchers.types.beOfType
import io.kotest.matchers.types.shouldBeTypeOf
import io.mockk.coVerify
import io.mockk.every
import io.mockk.junit4.MockKRule
import io.mockk.mockk
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.take
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.test.StandardTestDispatcher
import kotlinx.coroutines.test.TestCoroutineScheduler
import org.junit.Rule
import org.junit.Test
import kotlin.time.Duration.Companion.seconds

class BluetoothSearcherTest: DescribeSpec({
    var context = mockk<Context>(relaxed = true)
    val activity = mockk<Activity>()

    val testScheduler = TestCoroutineScheduler()

    coroutineTestScope = true

    describe("scan") {
        describe("has no bluetooth feature") {
            beforeEach {
                context = mockk {
                    every { packageManager.hasSystemFeature(PackageManager.FEATURE_BLUETOOTH) } returns false
                    every { getSystemService("bluetooth") } returns mockk<BluetoothManager>()
                }
            }

            it("return fail") {
                val searcher = BluetoothSearcher(context)
                searcher.coroutineScope = CoroutineScope(StandardTestDispatcher(testScheduler))

                val resultFlow = searcher.scan(activity)

                var result: ResultOr<List<String>>? = null
                CoroutineScope(Dispatchers.Unconfined).launch {
                    result = resultFlow.first()
                }

                testScheduler.runCurrent()

                eventually(5.seconds) {
                    result!!.error should beOfType<PluginException>()
                    (result!!.error as PluginException).code shouldBe 1001
                }
            }
        }
    }
})