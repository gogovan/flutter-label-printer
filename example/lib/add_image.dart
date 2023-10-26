import 'package:flutter/material.dart';
import 'package:flutter_label_printer/printer/common_classes.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_image.dart';
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
  var mode = MonochromizationAlgorithm.dithering;

  Future<void> _onPressed(context) async {
    final navigator = Navigator.of(context);
    try {
      MyApp.printer?.addImage(
        PrintImage(
            path: imagePath!,
            xPosition: double.parse(xController.text),
            yPosition: double.parse(yController.text),
            monochromizationAlgorithm: mode),
      );

      navigator.pop();
    } catch (ex, st) {
      print('Exception: $ex\n$st');
    }
  }

  Future<void> _onPickImage() async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(
          source: ImageSource.gallery, requestFullMetadata: false);

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
              DropdownButton<MonochromizationAlgorithm>(
                items: const [
                  DropdownMenuItem(
                      value: MonochromizationAlgorithm.binary,
                      child: Text('Binary')),
                  DropdownMenuItem(
                      value: MonochromizationAlgorithm.cluster,
                      child: Text('Cluster')),
                  DropdownMenuItem(
                      value: MonochromizationAlgorithm.dithering,
                      child: Text('Dithering')),
                ],
                onChanged: (item) {
                  mode = item!;
                  setState(() {});
                },
                value: mode,
              ),
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
