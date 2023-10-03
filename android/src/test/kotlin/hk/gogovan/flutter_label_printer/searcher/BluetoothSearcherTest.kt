package hk.gogovan.flutter_label_printer.searcher

import android.Manifest
import android.app.Activity
import android.bluetooth.BluetoothManager
import android.content.Context
import android.content.pm.PackageManager
import android.os.Handler
import hk.gogovan.flutter_label_printer.PluginException
import hk.gogovan.flutter_label_printer.util.ResultOr
import hk.gogovan.flutter_label_printer.util.checkSelfPermissions
import io.kotest.assertions.asClue
import io.kotest.assertions.nondeterministic.eventually
import io.kotest.core.spec.style.DescribeSpec
import io.kotest.core.spec.style.describeSpec
import io.kotest.matchers.should
import io.kotest.matchers.shouldBe
import io.kotest.matchers.types.beOfType
import io.kotest.matchers.types.shouldBeTypeOf
import io.mockk.coVerify
import io.mockk.every
import io.mockk.junit4.MockKRule
import io.mockk.mockk
import io.mockk.mockkConstructor
import io.mockk.slot
import io.mockk.unmockkConstructor
import io.mockk.verify
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

class BluetoothSearcherTest : DescribeSpec({
    val testScheduler = TestCoroutineScheduler()
    coroutineTestScope = true

    val coroutineScope = CoroutineScope(StandardTestDispatcher(testScheduler))

    suspend fun verifyPluginException(
        context: Context,
        btManager: BluetoothManager,
        activity: Activity?,
        code: Int
    ) {
        val searcher = BluetoothSearcher(context, btManager, coroutineScope)

        val resultFlow = searcher.scan(activity)

        var result: ResultOr<List<String>>? = null
        CoroutineScope(Dispatchers.Unconfined).launch {
            result = resultFlow.first()
        }

        testScheduler.runCurrent()

        eventually(5.seconds) {
            result!!.error should beOfType<PluginException>()
            (result!!.error as PluginException).code shouldBe code
        }
    }

    describe("scan") {
        describe("has no bluetooth feature") {
            val context = mockk<Context> {
                every { packageManager.hasSystemFeature(PackageManager.FEATURE_BLUETOOTH) } returns false
                every { getSystemService("bluetooth") } returns mockk<BluetoothManager>()
            }
            val btManager = mockk<BluetoothManager>()
            val activity = mockk<Activity>()

            it("return plugin exception") {
                verifyPluginException(context, btManager, activity, 1001)
            }
        }

        describe("has no bluetooth adapter") {
            val context = mockk<Context> {
                every { packageManager.hasSystemFeature(PackageManager.FEATURE_BLUETOOTH) } returns true
                every { getSystemService("bluetooth") } returns mockk<BluetoothManager>()
            }
            val activity = mockk<Activity>()
            val btManager = mockk<BluetoothManager> {
                every { adapter } returns null
            }

            it("returns plugin exception") {
                verifyPluginException(context, btManager, activity, 1001)
            }
        }

        describe("null activity") {
            val context = mockk<Context> {
                every { packageManager.hasSystemFeature(PackageManager.FEATURE_BLUETOOTH) } returns true
                every { getSystemService("bluetooth") } returns mockk<BluetoothManager>()
            }
            val activity = null
            val btManager = mockk<BluetoothManager> {
                every { adapter } returns mockk()
            }

            it("returns plugin exception") {
                verifyPluginException(context, btManager, activity, 1003)
            }
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