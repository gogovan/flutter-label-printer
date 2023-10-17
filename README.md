# flutter-label-printer

Integrate printers with Flutter apps.

# Supported Platforms

- Android: Android 7.0+
- iOS:

# Supported Printers

- Hanin (HPRT) HM-A300L
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
   If your app also requires Location permissions, remove `maxSdkVersion` attribute for those permissions.

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

## Connect your printer and basic printing

1. Use an instance of a class implementing `PrinterSearcherInterface` to search for compatible
   printers.
    - All classes implementing `PrinterSearcherInterface` provides a `search` method returning
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

## Using print templates

1. Connect your printer (See above steps 1 - 2).
    - The retrieved `PrinterInterface` must also implement `TemplatablePrinterInterface`. If your `PrinterInterface`
      does not additionally implement `TemplatablePrinterInterface`, templates are not supported on that printer.
2. Create a `Template` by either of the following methods:
    1. Create a `List<Command>` and add the `Command`s manually. Then create `Template` with `final template = Template(commands)`. See the `Template` class doc for supported commands.
    2. Import a `YAML` file and instantiate a `Template` with `final template = Template.fromYaml(yamlString)`. See below for YAML format.
3. Create a `TemplatePrinter` and use it to print the template.
```dart
final printer = TemplatePrinter(printer, template);
await printer.printTemplate();
```

### Template YAML

`example/assets/template_schema.json` is a JSON Schema for YAML format supported by `Template` constructor. [Refer to JSON Schema webpage](https://json-schema-everywhere.github.io/yaml) for details. Start your YAML with
```yaml
# yaml-language-server: $schema=template_schema.json
```
and edit your YAML with [VSCode](https://code.visualstudio.com/) that has [YAML plugin](https://marketplace.visualstudio.com/items?itemName=redhat.vscode-yaml) installed.

### Supported commands

#### Size
Command `size` set the printing area. _Note that this command is required, otherwise unexpected behavior may occur._ Support following parameters:
- `paperType`: Either `continuous` or `label`
- `originX` and `originY`: Where the printing area starts
- `width` and `height`: Width and height of the printing area.
- `horizontalResolution` and `verticalResolution`: Set resolutions in dpi. 
    - HM-A300L ignore this parameter and always use 200dpi.

#### Text
Command `text` adds text with styling. Support following parameters:
- `text`: The text to print.
- `xPosition` and `yPosition`: The position of the text.
- `rotation`: Rotation of the text, if the printer support it. 
    - HM-A300L only support rotation in 90 degrees (i.e. 0, 90, 180 and 270 degrees) and other values will be rounded to nearest 90 degrees value.
- `style`: The style of the text, accepts an object:
    - `bold`: Bold and its degree.
    - `width` and `height`: The width and height of each character in the text.
    - `align`: Alignment of the text
        - HM-A300L supports `left`, `center` and `right`.

#### Barcode
Command `barcode` prints a barcode. Support following parameters:
- `type`: The barcode symbology of the barcode.
    - One of the following values: `code11, code39, code93, code128, codabar, ean2, ean5, ean8, ean13, interleaved2of5, msi, patchCode, pharmacode, plessey, telepen, upca, upce`
    - Note that not every printer support every barcode symbology. Refer to manufacturer manual for details.
- `xPosition` and `yPosition`: The position of the barcode.
- `data`: The data encoded in the barcode.
- `height:` The height of the barcode.

#### QR Code
Command `qrcode` prints a QR Code. Support following parameters:
- `xPosition` and `yPosition`: The position of the QR Code.
- `data`: The data encoded in the QR Code.
- `unitSize`: The size of each unit (square) of the QR Code.

#### Line
Command `line` draws a line. Support following parameters:
- `left`, `top`, `right`, `bottom`: The start and end points of the line.
- `strokeWidth`: Stroke width of the line.

#### Rectangle
Command `rectangle` draws a rectangle. Support following parameters:
- `left`, `top`, `right`, `bottom`: The points of the rectangle.
- `strokeWidth`: Stroke width of the rectangle.

#### Image
Command `image` prints an image. Support following parameters:
- `path`: The file path to the image. Due to different paths in different OSes, **avoid hardcoding a path**. Use String Replacement (see below) instead.
- `xPosition` and `yPosition`: The position of the image.

### Template String Replacement

Some strings in the template can be replaced with values retrieved at runtime. Pass the map of values to the `replaceStrings` parameter when constructing `TemplatePrinter` to enable:
```dart
final map = <String, String>{'name': 'John Doe', 'age': '23'};
final printer = TemplatePrinter(printer, template, replaceStrings: map);
```
To indicate replaceable strings in the template, wrap the key with double curly braces. e.g. The `{{name}}` in any strings in the template will be replaced by the value mapped to the key `name` in `replaceStrings`, i.e. `John Doe` in the above case. Keys are case-sensitive.

String replacement is supported on all fields that takes a String:
- Text string
- Barcode data
- QR Code data
- Image file path

# Known Issues

## HM-A300L
- Currently in iOS it can only print very small images, otherwise the printer will be stuck and unable to do anything, and can only be fixed by restarting the printer.

# Contributing

## Adding a new printer

1. Implement `PrinterSearcherInterface` for searching your printer.
2. Implement `PrinterSearchResult` as the result object returned by your `PrinterSearcherInterface`.
3. If your printer is intended to be used with the Templating system, implement `PrinterTemplateInterface` to support templating.
    1. Otherwise, Implement `PrinterInterface` for basic connectivity of your printer. 
4. When implementing the Templating system, avoid adding any printer-specific features into parameter classes. Convert parameter classes to a format for your printer in your printer instead.