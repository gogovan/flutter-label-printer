# flutter-label-printer

Integrate printers with Flutter apps.

# Supported Printers

- Hanyin (HPRT) HM-A300L

# Setup

## Bluetooth

If your device requires Bluetooth connection, add Bluetooth permissions/notices as required by the
OS.

### Android

1. Add the following to your main `AndroidManifest.xml`.

```xml

<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.flutter_label_printer_example">

    <uses-feature android:name="android.hardware.bluetooth_le" android:required="true" />

    <uses-permission android:name="android.permission.BLUETOOTH" android:maxSdkVersion="30" />
    <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" android:maxSdkVersion="30" />
    <uses-permission android:name="android.permission.BLUETOOTH_SCAN"
        android:usesPermissionFlags="neverForLocation" />
    <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
    <!-- ... -->
</manifest>
```

### iOS

1. Include usage description keys for Bluetooth into `info.plist`.
   ![iOS XCode Bluetooth permission instruction](README_img/ios-bluetooth-perm.png)

# Usage

1. Use an instance of a class implementing `PrinterSearcherInterface` to search for compatible
   printers. It will return a list of `PrinterSearchResult`s.
2. Pass one of the returned `PrinterSearchResult` and use it to connect to a printer through an
   instance of a class implementing `PrinterInterface`. Each instance of `PrinterInterface`
   represent a single printer. If you wish to connect multiple printers, use multiple instances
   of `PrinterInterface`.
3. Use the instance of `PrinterInterface` that has connected to a printer to send printing commands.
4. When you are done, call `disconnect` to disconnect the device from your app.

# Issues

# Contributing
