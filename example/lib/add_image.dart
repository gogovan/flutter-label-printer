import 'package:flutter/material.dart';
import 'package:flutter_label_printer/printer/hm_a300l_classes.dart';
import 'package:flutter_label_printer_example/main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class AddImage extends StatefulWidget {
  const AddImage({Key? key}) : super(key: key);

  @override
  State<AddImage> createState() => _AddImageState();
}

class _AddImageState extends State<AddImage> {
  String? imagePath;
  final xController = TextEditingController();
  final yController = TextEditingController();
  var mode = HMA300LPrintImageMode.dithering;
  var compress = false;
  var package = false;

  Future<void> _onPressed(context) async {
    final navigator = Navigator.of(context);
    try {
      await MyApp.printer?.addImage(HMA300LPrintImageParams(
        imagePath: imagePath!,
        xPosition: int.parse(xController.text),
        yPosition: int.parse(yController.text),
        mode: mode,
        compress: compress,
        package: package,
      ));
      navigator.pop();
    } catch (ex, st) {
      print('Exception: $ex\n$st');
    }
  }

  Future<void> _onPickImage() async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(source: ImageSource.gallery, requestFullMetadata: false);

      if (file != null) {
        final image = await img.decodeImageFile(file.path);
        if (image != null) {
          final resized = img.copyResize(image, width: 50);
          final newDir = await getTemporaryDirectory();
          final newPath = "${newDir.absolute.path}/${file.name}.png";
          if (await img.encodePngFile(newPath, resized)) {
            setState(() {
              imagePath = newPath;
            });
          } else {
            setState(() {
              imagePath = null;
            });
          }
        }
      }
    } catch (ex, st) {
      print('Exception: $ex\n$st');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Set Print Area Size'),
        ),
        body: LayoutBuilder(builder:
            (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
              child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: viewportConstraints.maxHeight,
            ),
            child: Column(children: [
              ElevatedButton(
                onPressed: _onPickImage,
                child: const Text("Pick Image"),
              ),
              Text("Image path = $imagePath"),
              TextField(
                decoration: const InputDecoration(
                  hintText: 'x',
                ),
                keyboardType: TextInputType.number,
                controller: xController,
              ),
              TextField(
                decoration: const InputDecoration(
                  hintText: 'y',
                ),
                keyboardType: TextInputType.number,
                controller: yController,
              ),
              const Text('Mode'),
              DropdownButton<HMA300LPrintImageMode>(
                items: const [
                  DropdownMenuItem(
                      value: HMA300LPrintImageMode.binary, child: Text('Binary')),
                  DropdownMenuItem(
                      value: HMA300LPrintImageMode.cluster, child: Text('Cluster')),
                  DropdownMenuItem(
                      value: HMA300LPrintImageMode.dithering,
                      child: Text('Dithering')),
                ],
                onChanged: (item) {
                  mode = item!;
                  setState(() {});
                },
                value: mode,
              ),
              CheckboxListTile(
                  title: const Text("Compress"),
                  value: compress,
                  onChanged: (value) {
                    setState(() {
                      compress = value ?? false;
                    });
                  }),
              CheckboxListTile(
                  title: const Text("Package"),
                  value: package,
                  onChanged: (value) {
                    setState(() {
                      package = value ?? false;
                    });
                  }),
              ElevatedButton(
                  onPressed: () => _onPressed(context),
                  child: const Text("Add image")),
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Back"))
            ]),
          ));
        }));
  }
}
