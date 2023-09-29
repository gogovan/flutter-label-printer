package hk.gogovan.flutter_label_printer.searcher

import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import io.mockk.every
import io.mockk.junit4.MockKRule
import io.mockk.mockk
import kotlinx.coroutines.runBlocking
import org.junit.Rule
import org.junit.Test

class BluetoothSearcherTest {
    @get:Rule
    val mockkRule = MockKRule(this)

    @Test
    fun `test scan, no bluetooth available`() {
        val context = mockk<Context> {
            every { packageManager.hasSystemFeature(PackageManager.FEATURE_BLUETOOTH) } returns false
        }
        val activity = mockk<Activity>()

        val searcher = BluetoothSearcher(context)
        runBlocking {
            searcher.scan(activity)
        }
    }
}