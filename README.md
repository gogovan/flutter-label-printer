# flutter-label-printer

Integrate printers with Flutter apps.

# Supported Platforms

- Android: Android 7.0+
- iOS:

# Supported Printers

- Hanin (HPRT) CPCL Printers
  - HM-A300L is tested
- Hanin (HPRT) TSPL Printers
  - N41BT is tested

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

2. Depending on your printer, you may need to include SDKs for the printer in order for your project to build. Refer to manufacturer manual for installation details.
   1. In particular for iOS, you may need to include the SDK Framework in your project and set the Target to the `flutter_label_printer` pod.  

3. Depending on the connection technology your printer device requires, do the following steps:

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
BluetoothPrinterSearcher _searcher = BluetoothPrinterSearcher();
_searcher.search().listen((event) {
  // event contains a list of `PrinterSearchResult`s
});
```

2. Pass one of the returned `PrinterSearchResult` and use it to connect to a printer through an
   instance of a class implementing `PrinterInterface`. Each instance of `PrinterInterface`
   represent a single printer. If you wish to connect multiple printers, use multiple instances
   of `PrinterInterface`.

```dart
HaninTSPLPrinter? _printer;
_printer = HaninTSPLPrinter(result);
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

`example/assets/template_schema.json` is a JSON Schema for YAML format supported by `Template` constructor. [Refer to JSON Schema webpage](https://json-schema-everywhere.github.io/yaml) for details.

#### VSCode Integration

Start your YAML with
```yaml
# yaml-language-server: $schema=template_schema.json
```
and edit your YAML with [VSCode](https://code.visualstudio.com/) that has [YAML plugin](https://marketplace.visualstudio.com/items?itemName=redhat.vscode-yaml) installed.

### Template YAML root
There are two properties at root, `size` and `commands`, taking an object and an array of object respectively. Both are required. 

For each command, a table is provided listing support for each printing SDK. Legends is as follows:
:x: Not supported. These parameters will be ignored if sent to unsupported printers.
:o: Supported.
:star: Required.

### Size command
The `size` object set the printing area.
This command create a canvas for drawing items to be printed. Call `print` to perform the actual printing.

| Parameter   | Description                                        | Possible Values                                            | Hanin CPCL | Hanin TSPL |
|-------------|----------------------------------------------------|------------------------------------------------------------|------------|------------|
| `paperType` | Type of paper.                                     | `continuous` for receipt papers. `label` for label papers. | :star:     | :x:        |
| `originX`   | Starting horizontal position of the printing area. | Number                                                     | :o:        | :x:        |
| `originY`   | Starting vertical position of the printing area.   | Number                                                     | :o:        | :x:        |
| `width`     | Width of the printing area.                        | Number                                                     | :star:     | :star:     |
| `height`    | Height of the printing area.                       | Number                                                     | :star:     | :star:     |

### Printing commands

Put all printing commands in the `commands` object. They will be sent to the printer in order.

#### Text
Command `text` adds text with styling.

| Parameter      | Description                                        | Possible Values              | Hanin CPCL                   | Hanin TSPL                   |
|----------------|----------------------------------------------------|------------------------------|------------------------------|------------------------------|
| `text`         | The text to print                                  | Text                         | :star:                       | :star:                       |
| `xPosition`    | The x position of the text in the canvas.          | Number                       | :star:                       | :star:                       |
| `yPosition`    | The y position of the text in the canvas.          | Number                       | :star:                       | :star:                       |
| `rotation`     | Rotation of the text.                              | Number                       | :o: in 90 degrees increments | :o: in 90 degrees increments |
| `style`        | The style of the text. Accept an object.           |                              | :o:                          | :o:                          |
| `style.bold`   | Bold text and degree of boldness.                  | Number                       | :o:                          | :x:                          |
| `style.width`  | Width of each character in text, as a multiplier.  | Number                       | :o:                          | :o:                          |
| `style.height` | Height of each character in text, as a multiplier. | Number                       | :o:                          | :o:                          |
| `style.align`  | Alignment of text.                                 | `left`, `center` or `right`. | :o:                          | :o:                          |

#### Barcode
Command `barcode` prints a barcode.

| Parameter   | Description                                  | Possible Values             | Hanin CPCL                                                                       | Hanin TSPL                                                                                  |
|-------------|----------------------------------------------|-----------------------------|----------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------|
| `type`      | The barcode symbology of the barcode.        | Different for each printer. | :star: `upca`, `upce`, `ean13`, `ean8`, `code39`, `code93`, `code128`, `codabar` | :star: `code128`, `code128m`, `ean128`, `code39`, `code93`, `upca`, `msi`, `itf14`, `ean13` |
| `xPosition` | The x position of the barcode in the canvas. | Number                      | :star:                                                                           | :star:                                                                                      |
| `yPosition` | The y position of the barcode in the canvas. | Number                      | :star:                                                                           | :star:                                                                                      |
| `data`      | Data encoded in the barcode.                 | Text                        | :star:                                                                           | :star:                                                                                      |
| `height`    | The height of the barcode.                   | Number                      | :star:                                                                           | :star:                                                                                      |

#### QR Code
Command `qrcode` prints a QR Code. 

| Parameter   | Description                                    | Possible Values | Hanin CPCL | Hanin TSPL |
|-------------|------------------------------------------------|-----------------|------------|------------|
| `xPosition` | The x position of the barcode in the canvas.   | Number          | :star:     | :star:     |
| `yPosition` | The y position of the barcode in the canvas.   | Number          | :star:     | :star:     |
| `data`      | Data encoded in the barcode.                   | Text            | :star:     | :star:     |
| `unitSize`  | The size of each unit (square) of the QR Code. | Number          | :star:     | :star:     |

#### Line
Command `line` draws a line.

| Parameter     | Description               | Possible Values | Hanin CPCL | Hanin TSPL |
|---------------|---------------------------|-----------------|------------|------------|
| `left`        | x0                        | Number          | :star:     | :star:     |
| `top`         | y0                        | Number          | :star:     | :star:     |
| `right`       | x1                        | Number          | :star:     | :star:     |
| `bottom`      | y1                        | Number          | :star:     | :star:     |
| `strokeWidth` | Stroke width of the line. | Number          | :o:        | :x:        |

#### Rectangle
Command `rectangle` draws a rectangle. 

| Parameter     | Description               | Possible Values | Hanin CPCL | Hanin TSPL |
|---------------|---------------------------|-----------------|------------|------------|
| `left`        | x0                        | Number          | :star:     | :star:     |
| `top`         | y0                        | Number          | :star:     | :star:     |
| `right`       | x1                        | Number          | :star:     | :star:     |
| `bottom`      | y1                        | Number          | :star:     | :star:     |
| `strokeWidth` | Stroke width of the line. | Number          | :o:        | :o:        |

#### Image
Command `image` prints an image.

| Parameter   | Description                                                                                                                                    | Possible Values | Hanin CPCL | Hanin TSPL |
|-------------|------------------------------------------------------------------------------------------------------------------------------------------------|-----------------|------------|------------|
| `path`      | The file path to the image. Due to different paths in different OSes, **avoid hardcoding a path**. Use String Replacement (see below) instead. | Text            | :star:     | :star:     |
| `xPosition` | The x position of the image in the canvas.                                                                                                     | Number          | :star:     | :star:     |
| `yPosition` | The y position of the image in the canvas.                                                                                                     | Number          | :star:     | :star:     |

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

## Hanin CPCL
- Currently in iOS it can only print very small images, otherwise the printer will be stuck and unable to do anything, and can only be fixed by restarting the printer.

# Contributing

## Adding a new printer

1. Implement `PrinterSearcherInterface` for searching your printer.
2. Implement `PrinterSearchResult` as the result object returned by your `PrinterSearcherInterface`.
3. If your printer is intended to be used with the Templating system, implement `PrinterTemplateInterface` to support templating.
    1. Otherwise, Implement `PrinterInterface` for basic connectivity of your printer. 
4. When implementing the Templating system, avoid adding any printer-specific features into parameter classes. Convert parameter classes to a format for your printer in your printer instead.