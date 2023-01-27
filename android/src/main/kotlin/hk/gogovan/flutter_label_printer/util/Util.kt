package hk.gogovan.flutter_label_printer.util

import android.content.Context
import android.content.pm.PackageManager

/**
 * Same as checkSelfPermission but with multiple permissions.
 */
fun Context.checkSelfPermissions(permissions: Array<String>): Int {
    for (perm in permissions) {
        val status = checkSelfPermission(perm)
        if (status == PackageManager.PERMISSION_DENIED) {
            return PackageManager.PERMISSION_DENIED
        }
    }
    return PackageManager.PERMISSION_GRANTED
}