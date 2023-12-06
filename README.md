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
- A special "printer" that print to an image instead of a hardware printer. Useful for:
    - Send the image to printer instead of using printer commands for consistency and working around
      missing printer features.
    - Print to an image for preliminary testing and verification during development.

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
   If your app also requires Location permissions, remove `maxSdkVersion` attribute for those
   permissions.

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
_searcher.search
().listen
(
(event) {
// event contains a list of `PrinterSearchResult`s
});
```

2. Pass one of the returned `PrinterSearchResult` and use it to connect to a printer through an
   instance of a class implementing `PrinterInterface`. Each instance of `PrinterInterface`
   represent a single printer. If you wish to connect multiple printers, use multiple instances
   of `PrinterInterface`.

```dart
HaninTSPLPrinter? _printer;
_printer =

HaninTSPLPrinter(result);

await _printer
?.

connect();
```

3. Use the instance of `PrinterInterface` that has connected to a printer to send printing commands.
   `printTestPage` may be used to print a testing page.

```dart
await _printer
?.

printTestPage();
```

4. When you are done, call `disconnect` to disconnect the device from your app.

```dart
await _printer
?.

disconnect();
```

## Using print templates

1. Connect your printer (See above steps 1 - 2).
    - The retrieved `PrinterInterface` must also implement `TemplatablePrinterInterface`. If
      your `PrinterInterface`
      does not additionally implement `TemplatablePrinterInterface`, templates are not supported on
      that printer.
2. Create a `Template` by either of the following methods:
    1. Create a `List<Command>` and add the `Command`s manually. Then create `Template`
       with `final template = Template(commands)`. See the `Template` class doc for supported
       commands.
    2. Import a `YAML` file and instantiate a `Template`
       with `final template = Template.fromYaml(yamlString)`. See below for YAML format.
3. Create a `TemplatePrinter` and use it to print the template.

```dart

final printer = TemplatePrinter(printer, template);
await
printer.printTemplate
();
```

### Template YAML

`example/assets/template_schema.json` is a JSON Schema for YAML format supported by `Template`
constructor. [Refer to JSON Schema webpage](https://json-schema-everywhere.github.io/yaml) for
details.

#### VSCode Integration

Start your YAML with

```yaml
# yaml-language-server: $schema=template_schema.json
```

and edit your YAML with [VSCode](https://code.visualstudio.com/) that
has [YAML plugin](https://marketplace.visualstudio.com/items?itemName=redhat.vscode-yaml) installed.

### Template YAML root

There are two properties at root, `size` and `commands`, taking an object and an array of object
respectively. Both are required.

For each command, a table is provided listing support for each printing SDK. Legends is as follows:
:x: Not supported. These parameters will be ignored if sent to unsupported printers.
:o: Supported.
:star: Required.

### Size command

The `size` object set the printing area.
This command create a canvas for drawing items to be printed. Call `print` to perform the actual
printing.

| Parameter   | Description                                        | Possible Values                                            | Hanin CPCL | Hanin TSPL | Image  |
|-------------|----------------------------------------------------|------------------------------------------------------------|------------|------------|--------|
| `paperType` | Type of paper.                                     | `continuous` for receipt papers. `label` for label papers. | :star:     | :x:        | :x:    |
| `originX`   | Starting horizontal position of the printing area. | Number                                                     | :o:        | :x:        | :x:    |
| `originY`   | Starting vertical position of the printing area.   | Number                                                     | :o:        | :x:        | :x:    |
| `width`     | Width of the printing area.                        | Number                                                     | :star:     | :star:     | :star: |
| `height`    | Height of the printing area.                       | Number                                                     | :star:     | :star:     | :star: |

### Printing commands

Put all printing commands in the `commands` object. They will be sent to the printer in order.

#### Text

Command `text` adds text with styling.

| Parameter       | Description                                                                         | Possible Values              | Hanin CPCL                   | Hanin TSPL                   | Image  |
|-----------------|-------------------------------------------------------------------------------------|------------------------------|------------------------------|------------------------------|--------|
| `text`          | The text to print.                                                                  | Text                         | :star:                       | :star:                       | :star: |
| `xPosition`     | The x position of the text in the canvas.                                           | Number                       | :star:                       | :star:                       | :star: |
| `yPosition`     | The y position of the text in the canvas.                                           | Number                       | :star:                       | :star:                       | :star: |
| `rotation`      | Rotation of the text.                                                               | Number                       | :o: in 90 degrees increments | :o: in 90 degrees increments | :x:    |
| `width`         | Width of the text area.                                                             | Number                       | :x:                          | :o:                          | :o:    |
| `height`        | Height of the text area.                                                            | Number                       | :x:                          | :o:                          | :o:    |
| `useImage`      | Whether to use image to represent this text. [1]                                    | Boolean                      | :o:                          | :o:                          | :x:    |
| `style`         | The style of the text. Accept an object.                                            |                              | :o:                          | :o:                          | :o:    |
| `style.bold`    | Bold text and degree of boldness.                                                   | Number                       | :o:                          | :o:                          | :o:    |
| `style.width`   | Width of each character in text, as a multiplier. For image printer, the font size. | Number                       | :o:                          | :o:                          | :o:    |
| `style.height`  | Height of each character in text, as a multiplier.                                  | Number                       | :o:                          | :o:                          | :x:    |
| `style.align`   | Alignment of text.                                                                  | `left`, `center` or `right`. | :o:                          | :o:                          | :o:    |
| `style.font`    | Font of text.                                                                       | [2]                          | :o:                          | :o:                          | :o:    |
| `style.reverse` | Reverse the color of the text.                                                      | Boolean                      | :x:                          | :x:                          | :o:    |
| `style.padding` | Padding for the text. Particularly useful with style.reverse = true                 | Number                       | :x:                          | :x:                          | :o:    |

1: If the text command provided by the printer is insufficient, set `useImage` to true and
flutter_label_printer will generate an image in the OS representing this text and send the image to
the printer instead. While this is more flexible and can workaround missing features of the printer,
it is also slower and may not be supported by printers that cannot print images.
If this is used, attributes supported by the `image` printer, instead of your actual printer, is
used.
2: Either one
of `small, medium, large, vlarge, vvlarge, chinese, chineseLarge, ocrSmall, ocrLarge, square, triumvirate`
for Hanin TSPL and CPCL. For image printer, any font supported by the OS is supported.

#### Barcode

Command `barcode` prints a barcode.

| Parameter      | Description                                  | Possible Values                 | Hanin CPCL | Hanin TSPL | Image  |
|----------------|----------------------------------------------|---------------------------------|------------|------------|--------|
| `type`         | The barcode symbology of the barcode.        | Different for each printer. [1] | :star:     | :star:     | :star: |
| `xPosition`    | The x position of the barcode in the canvas. | Number                          | :star:     | :star:     | :star: |
| `yPosition`    | The y position of the barcode in the canvas. | Number                          | :star:     | :star:     | :star: |
| `data`         | Data encoded in the barcode.                 | Text                            | :star:     | :star:     | :star: |
| `height`       | The height of the barcode.                   | Number                          | :star:     | :star:     | :star: |
| `barLineWidth` | The width of each narrow bar of the barcode. | Number                          | :o:        | :o:        | :o:    |

[1] Supported barcodes:

| Symbology  | Hanin CPCL | Hanin TSPL | Image |
|------------|------------|------------|-------|
| `code39`   | :o:        | :o:        | :o:   |
| `code93`   | :o:        | :o:        | :o:   |
| `code128`  | :o:        | :o:        | :o:   |
| `code128m` | :x:        | :o:        | :x:   |
| `codabar`  | :o:        | :x:        | :o:   |
| `ean2`     | :x:        | :x:        | :o:   |
| `ean5`     | :x:        | :x:        | :o:   |
| `ean8`     | :o:        | :x:        | :o:   |
| `ean13`    | :o:        | :o:        | :o:   |
| `ean128`   | :x:        | :o:        | :x:   |
| `msi`      | :x:        | :o:        | :x:   |
| `itf14`    | :x:        | :o:        | :x:   |
| `telepen`  | :x:        | :x:        | :o:   |
| `upca`     | :o:        | :o:        | :o:   |
| `upce`     | :o:        | :x:        | :o:   |

#### QR Code

Command `qrcode` prints a QR Code.

| Parameter   | Description                                    | Possible Values | Hanin CPCL | Hanin TSPL | Image |
|-------------|------------------------------------------------|-----------------|------------|------------|-------|
| `xPosition` | The x position of the barcode in the canvas.   | Number          | :star:     | :star:     | :o:   |
| `yPosition` | The y position of the barcode in the canvas.   | Number          | :star:     | :star:     | :o:   |
| `data`      | Data encoded in the barcode.                   | Text            | :star:     | :star:     | :o:   |
| `unitSize`  | The size of each unit (square) of the QR Code. | Number          | :star:     | :star:     | :o:   |

#### Line

Command `line` draws a line.

| Parameter     | Description               | Possible Values | Hanin CPCL | Hanin TSPL | Image  |
|---------------|---------------------------|-----------------|------------|------------|--------|
| `left`        | x0                        | Number          | :star:     | :star:     | :star: |
| `top`         | y0                        | Number          | :star:     | :star:     | :star: |
| `right`       | x1                        | Number          | :star:     | :star:     | :star: |
| `bottom`      | y1                        | Number          | :star:     | :star:     | :star: |
| `strokeWidth` | Stroke width of the line. | Number          | :o:        | :x:        | :o:    |

#### Rectangle

Command `rectangle` draws a rectangle.

| Parameter     | Description               | Possible Values | Hanin CPCL | Hanin TSPL | Image  |
|---------------|---------------------------|-----------------|------------|------------|--------|
| `left`        | x0                        | Number          | :star:     | :star:     | :star: |
| `top`         | y0                        | Number          | :star:     | :star:     | :star: |
| `right`       | x1                        | Number          | :star:     | :star:     | :star: |
| `bottom`      | y1                        | Number          | :star:     | :star:     | :star: |
| `strokeWidth` | Stroke width of the line. | Number          | :o:        | :o:        | :o:    |

#### Image

Command `image` prints an image.

| Parameter   | Description                                                                                                                                    | Possible Values | Hanin CPCL | Hanin TSPL | Image |
|-------------|------------------------------------------------------------------------------------------------------------------------------------------------|-----------------|------------|------------|-------|
| `path`      | The file path to the image. Due to different paths in different OSes, **avoid hardcoding a path**. Use String Replacement (see below) instead. | Text            | :star:     | :star:     | :o:   |
| `xPosition` | The x position of the image in the canvas.                                                                                                     | Number          | :star:     | :star:     | :o:   |
| `yPosition` | The y position of the image in the canvas.                                                                                                     | Number          | :star:     | :star:     | :o:   |

### Template String Replacement

Some strings in the template can be replaced with values retrieved at runtime. Pass the map of
values to the `replaceStrings` parameter when constructing `TemplatePrinter` to enable:

```dart

final map = <String, String>{'name': 'John Doe', 'age': '23'};
final printer = TemplatePrinter(printer, template, replaceStrings: map);
```

To indicate replaceable strings in the template, wrap the key with double curly braces. e.g.
The `{{name}}` in any strings in the template will be replaced by the value mapped to the key `name`
in `replaceStrings`, i.e. `John Doe` in the above case. Keys are case-sensitive.

String replacement is supported on all fields that takes a String:

- Text string
- Barcode data
- QR Code data
- Image file path

### Printer Hints

Some printers does not support all features available in the commands. flutter_label_printer
provides a workaround method to support these features.

#### text_align

`text_align` allows text to be aligned according to the `style.align` parameter of the `text`
command, even if the printer does not support it.
Only Hanin TSPL is supported. Only support a single-line text with a monospaced font.

```yaml
printer_hints:
  text_align:
    enabled: true # Set to true to enable this feature
    charWidth: 8 # The base character width of the font used, before any scaling introduced by `style.width` in the text command. This is used to calculate the width of the text.
```

# Known Issues

## Hanin CPCL

- Currently in iOS it can only print very small images, otherwise the printer will be stuck and
  unable to do anything, and can only be fixed by restarting the printer.

# Contributing

## Adding a new printer

1. Implement `PrinterSearcherInterface` for searching your printer.
2. Implement `PrinterSearchResult` as the result object returned by your `PrinterSearcherInterface`.
3. If your printer is intended to be used with the Templating system,
   implement `PrinterTemplateInterface` to support templating.
    1. Otherwise, Implement `PrinterInterface` for basic connectivity of your printer.
4. When implementing the Templating system, avoid adding any printer-specific features into
   parameter classes. Convert parameter classes to a format for your printer in your printer
   instead.