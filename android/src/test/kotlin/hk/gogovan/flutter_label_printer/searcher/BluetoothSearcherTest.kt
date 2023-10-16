package hk.gogovan.flutter_label_printer.searcher

import android.Manifest
import android.app.Activity
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothClass
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
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
import io.mockk.mockkConstructor
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
        searcher: BluetoothSearcher,
        activity: Activity?,
        code: Int
    ) {
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

        mockkConstructor(Intent::class)
        mockkConstructor(IntentFilter::class)
        every { anyConstructed<IntentFilter>().addAction(any()) } just Runs
    }

    afterEach {
        unmockkStatic(TextUtils::class)

        unmockkStatic(Intent::class)
        unmockkStatic(IntentFilter::class)
    }

    describe("scan") {
        describe("has no bluetooth feature") {
            val context = mockk<Context> {
                every { packageManager.hasSystemFeature(PackageManager.FEATURE_BLUETOOTH) } returns false
                every { getSystemService("bluetooth") } returns mockk<BluetoothManager>()
            }
            val btManager = mockk<BluetoothManager>()
            val activity = mockk<Activity>()

            val searcher = BluetoothSearcher(context, btManager, coroutineScope, coroutineScope)
            it("return plugin exception") {
                verifyPluginException(searcher, activity, 1001)
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

            val searcher = BluetoothSearcher(context, btManager, coroutineScope, coroutineScope)
            it("returns plugin exception") {
                verifyPluginException(searcher, activity, 1001)
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

            val searcher = BluetoothSearcher(context, btManager, coroutineScope, coroutineScope)
            it("returns plugin exception") {
                verifyPluginException(searcher, activity, 1003)
            }
        }

        describe("bluetooth ready, no permission") {
            val context = mockk<Context> {
                every { packageManager.hasSystemFeature(PackageManager.FEATURE_BLUETOOTH) } returns true
                every { getSystemService("bluetooth") } returns mockk<BluetoothManager>()

                every { checkSelfPermission(any()) } returns PackageManager.PERMISSION_DENIED
            }

            val activity = mockk<Activity> {
                every {
                    startActivityForResult(
                        any(),
                        BluetoothSearcher.REQUEST_ENABLE_CODE
                    )
                } just Runs
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

                verifyPluginException(searcher, activity, 1002)
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

                verifyPluginException(searcher, activity, 1004)
            }
        }

        describe("bluetooth ready, permission granted, cannot start discovery") {
            val context = mockk<Context> {
                every { packageManager.hasSystemFeature(PackageManager.FEATURE_BLUETOOTH) } returns true
                every { getSystemService("bluetooth") } returns mockk<BluetoothManager>()

                every { checkSelfPermission(any()) } returns PackageManager.PERMISSION_GRANTED
            }

            val activity = mockk<Activity> {
                every {
                    startActivityForResult(
                        any(),
                        BluetoothSearcher.REQUEST_ENABLE_CODE
                    )
                } just Runs

                every { registerReceiver(any(), any()) } returns mockk()
            }
            val btManager = mockk<BluetoothManager> {
                every { adapter } returns mockk {
                    every { state } returns BluetoothAdapter.STATE_ON
                    every { cancelDiscovery() } returns false
                    every { startDiscovery() } returns false
                }
            }

            it("gets exception") {
                val searcher = BluetoothSearcher(context, btManager, coroutineScope, coroutineScope)

                searcher.scan(activity)
                testScheduler.runCurrent()

                verifyPluginException(searcher, activity, 1004)
            }
        }

        describe("bluetooth ready, permission granted") {
            val context = mockk<Context> {
                every { packageManager.hasSystemFeature(PackageManager.FEATURE_BLUETOOTH) } returns true
                every { getSystemService("bluetooth") } returns mockk<BluetoothManager>()

                every { checkSelfPermission(any()) } returns PackageManager.PERMISSION_GRANTED
            }

            val activity = mockk<Activity> {
                every {
                    startActivityForResult(
                        any(),
                        BluetoothSearcher.REQUEST_ENABLE_CODE
                    )
                } just Runs

                every { registerReceiver(any(), any()) } returns mockk()
            }
            val btManager = mockk<BluetoothManager> {
                every { adapter } returns mockk {
                    every { state } returns BluetoothAdapter.STATE_ON
                    every { cancelDiscovery() } returns true
                    every { startDiscovery() } returns true
                }
            }
            val btDevice = mockk<BluetoothDevice> {
                every { bluetoothClass.majorDeviceClass } returns BluetoothClass.Device.Major.IMAGING
                every { address } returns "12:34:56:AB:CD:EF"
            }
            val receiveIntent = mockk<Intent> {
                every { getParcelableExtra<BluetoothDevice>(BluetoothDevice.EXTRA_DEVICE) } returns btDevice
            }

            it("starts scan") {
                val searcher = BluetoothSearcher(context, btManager, coroutineScope, coroutineScope)

                searcher.scan(activity)
                testScheduler.runCurrent()

                searcher.onBluetoothFound.onReceive(context, receiveIntent)

                val resultFlow = searcher.scan(activity)
                var result: ResultOr<List<String>>? = null
                CoroutineScope(Dispatchers.Unconfined).launch {
                    result = resultFlow.first()
                }

                testScheduler.runCurrent()

                eventually(1.seconds) {
                    result!!.value shouldBe listOf("12:34:56:AB:CD:EF")
                }
            }
        }
    }
})