package hk.gogovan.flutter_label_printer.searcher

import android.Manifest
import android.app.Activity
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.text.TextUtils
import hk.gogovan.flutter_label_printer.PluginException
import hk.gogovan.flutter_label_printer.util.ResultOr
import io.kotest.assertions.nondeterministic.eventually
import io.kotest.core.spec.style.DescribeSpec
import io.kotest.matchers.should
import io.kotest.matchers.shouldBe
import io.kotest.matchers.types.beOfType
import io.mockk.Runs
import io.mockk.every
import io.mockk.just
import io.mockk.mockk
import io.mockk.mockkStatic
import io.mockk.slot
import io.mockk.unmockkStatic
import io.mockk.verify
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch
import kotlinx.coroutines.test.StandardTestDispatcher
import kotlinx.coroutines.test.TestCoroutineScheduler
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
        val searcher = BluetoothSearcher(context, btManager, coroutineScope, coroutineScope)

        val resultFlow = searcher.scan(activity)
        var result: ResultOr<List<String>>? = null
        CoroutineScope(Dispatchers.Unconfined).launch {
            result = resultFlow.first()
        }

        testScheduler.runCurrent()

        eventually(1.seconds) {
            result!!.error should beOfType<PluginException>()
            (result!!.error as PluginException).code shouldBe code
        }
    }

    beforeEach {
        mockkStatic(TextUtils::class)

        val s = slot<CharSequence>()
        every { TextUtils.isEmpty(capture(s)) } answers { s.captured.isEmpty() }
    }

    afterEach {
        unmockkStatic(TextUtils::class)
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

        describe("bluetooth ready, no permission") {
            val context = mockk<Context> {
                every { packageManager.hasSystemFeature(PackageManager.FEATURE_BLUETOOTH) } returns true
                every { getSystemService("bluetooth") } returns mockk<BluetoothManager>()

                every { checkSelfPermission(any()) } returns PackageManager.PERMISSION_DENIED
            }

            val activity = mockk<Activity> {
                every { startActivityForResult(
                    any(),
                    BluetoothSearcher.REQUEST_ENABLE_CODE
                )} just Runs
            }
            val btManager = mockk<BluetoothManager> {
                every { adapter } returns mockk {
                    every { state } returns BluetoothAdapter.STATE_OFF
                }
            }

            it("requests permissions denied and returns plugin exception") {
                val searcher = BluetoothSearcher(context, btManager, coroutineScope, coroutineScope)

                searcher.scan(activity)
                // manually invoke permission result
                searcher.handlePermissionResult(
                    BluetoothSearcher.REQUEST_PERMISSION_CODE,
                    arrayOf(
                        Manifest.permission.BLUETOOTH_SCAN,
                        Manifest.permission.BLUETOOTH_CONNECT
                    ),
                    intArrayOf(PackageManager.PERMISSION_DENIED, PackageManager.PERMISSION_DENIED)
                )

                val resultFlow = searcher.scan(activity)
                var result: ResultOr<List<String>>? = null
                CoroutineScope(Dispatchers.Unconfined).launch {
                    result = resultFlow.first()
                }

                testScheduler.runCurrent()

                eventually(1.seconds) {
                    result!!.error should beOfType<PluginException>()
                    (result!!.error as PluginException).code shouldBe 1002
                }
            }

            it("requests permissions granted and requests for enable bluetooth fail") {
                val searcher = BluetoothSearcher(context, btManager, coroutineScope, coroutineScope)

                searcher.scan(activity)
                testScheduler.runCurrent()

                // manually invoke permission result
                searcher.handlePermissionResult(
                    BluetoothSearcher.REQUEST_PERMISSION_CODE,
                    arrayOf(
                        Manifest.permission.BLUETOOTH_SCAN,
                        Manifest.permission.BLUETOOTH_CONNECT
                    ),
                    intArrayOf(PackageManager.PERMISSION_GRANTED, PackageManager.PERMISSION_GRANTED)
                )
                testScheduler.runCurrent()

                // manually invoke activity result
                searcher.handleActivityResult(
                    BluetoothSearcher.REQUEST_ENABLE_CODE,
                    Activity.RESULT_CANCELED
                )

                val resultFlow = searcher.scan(activity)
                var result: ResultOr<List<String>>? = null
                CoroutineScope(Dispatchers.Unconfined).launch {
                    result = resultFlow.first()
                }
                testScheduler.runCurrent()

                eventually(1.seconds) {
                    verify { activity.startActivityForResult(
                        any(),
                        BluetoothSearcher.REQUEST_ENABLE_CODE
                    )}

                    result!!.error should beOfType<PluginException>()
                    (result!!.error as PluginException).code shouldBe 1004
                }
            }
        }
    }
})