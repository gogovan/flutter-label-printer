# flutter-label-printer

Integrate printers with Flutter apps.

# Supported Platforms

- Android: Android 7.0+
- iOS:

# Supported Printers

- Hanyin (HPRT) HM-A300L
    - HM-A400 and HM-A300S shares the same native SDK and hence should work in theory, but they are untested.

# Setup

## General

1. Set `minSdkVersion` in your Android app `build.gradle` to at least `24`.

```groovy
android {
    // ...
    defaultConfig {
        applicationId "com.example.flutter_label_printer_example"
        minSdkVersion 24
        // ...
    }
    // ...
}
```

2. Depending on the connection technology your printer device requires, do the following steps:

## Bluetooth

If your device requires Bluetooth connection, add Bluetooth permissions/notices as required by the
OS.

### Android

1. Add the following to your main `AndroidManifest.xml`.
   See [Android Developers](https://developer.android.com/guide/topics/connectivity/bluetooth/permissions))
   and [this StackOverflow answer](https://stackoverflow.com/a/70793272)
   for more information about permission settings.

```xml

<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.flutter_label_printer_example">

    <uses-feature android:name="android.hardware.bluetooth" android:required="true" />

    <uses-permission android:name="android.permission.BLUETOOTH" android:maxSdkVersion="30" />
    <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" android:maxSdkVersion="30" />
    <uses-permission android:name="android.permission.BLUETOOTH_SCAN"
        android:usesPermissionFlags="neverForLocation" tools:targetApi="s" />
    <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"
        android:maxSdkVersion="30" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"
        android:maxSdkVersion="30" />
    <!-- ... -->
</manifest>
```

### iOS

1. Include usage description keys for Bluetooth into `info.plist`.
   ![iOS XCode Bluetooth permission instruction](README_img/ios-bluetooth-perm.png)

# Usage

1. Use an instance of a class implementing `PrinterSearcherInterface` to search for compatible
   printers.
    1. All classes implementing `PrinterSearcherInterface` provides a `search` method returning
       a `Stream<List<PrinterSearchResult>>`. `listen` to the stream to list all the available
       devices.

```dart

HMA300LSearcher _searcher = HMA300LSearcher();
_searcher.search().listen((event) {
// event contains a list of `PrinterSearchResult`s
});
```

2. Pass one of the returned `PrinterSearchResult` and use it to connect to a printer through an
   instance of a class implementing `PrinterInterface`. Each instance of `PrinterInterface`
   represent a single printer. If you wish to connect multiple printers, use multiple instances
   of `PrinterInterface`.

```dart
HMA300L? _printer;
_printer = HMA300L(result);
await _printer?.connect();
```

3. Use the instance of `PrinterInterface` that has connected to a printer to send printing commands. 
   `printTestPage` may be used to print a testing page.

```dart
await _printer?.printTestPage();
```

4. When you are done, call `disconnect` to disconnect the device from your app.

```dart
await _printer?.disconnect();
```

# Issues

## HM-A300L
- Currently in iOS it can only print very small images, otherwise the printer will be stuck and unable to do anything, and can only be fixed by restarting the printer.

# Contributing
