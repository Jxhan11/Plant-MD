import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:fc_native_image_resize/fc_native_image_resize.dart';
import 'package:flutter/material.dart';
import 'package:kissansphere/main.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'package:image/image.dart' as img;
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'dart:developer' as logger;
import 'dart:developer' as logger;

var diseases = ['Healthy', 'Cercospora', 'Alternatica', 'Bacterial Blight'];
String? element; // var element = diseases[_random.nextInt(diseases.length)];
// final ImagePicker _picker = ImagePicker();
final ImagePickerAndroid _picker = ImagePickerAndroid();

File? selectedImage;

// Future<img.Image?> loadImage(String path) async {
//   try {
//     final bytes = await File(path).readAsBytes();
//     return await img.decodeImage(bytes);
//   } catch (error) {
//     print("Error loading image: $error");
//     return null;
//   }
// }

Future<void> pickImage() async {
  try {
    final pickedFile = await _picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      selectedImage = File(pickedFile.path);
    }
  } catch (error) {
    print("Error picking image: $error");
  }
}

Future<img.Image?> loadImage(String path) async {
  try {
    final bytes = await File(path).readAsBytes();
    return img.decodeImage(bytes);
  } catch (error) {
    print("Error loading image: $error");
    return null;
  }
}

img.Image resizeImage(img.Image image, int width, int height) {
  return img.copyResize(image, height: height, width: width);
}


dynamic normalizePixels(List<int> imageData) {
  final List<double> normalizedData = [];
  for (int value in imageData) {
    final normalizedValue =
        (value / 255.0); // Normalize and convert to uint8 range
    normalizedData.add(normalizedValue);
  }
  return normalizedData;
}

List<double> normalizeImage(List list) {
  debugPrint('List size ${list.length}');
  List<double> newList = [];
  for (int i = 0; i < list.length; i++) {
    newList.add(list[i] / 255);
  }
  return newList;
}

List<int> imageDataToList(img.Image image) {
  final width = image.width;
  final height = image.height;
  final pixels = image.getBytes();

  final List<int> imageDataList = [];
  for (var i = 0; i < width * height * 3; i++) {
    imageDataList.add(pixels[i]);
  }
  return imageDataList;
}


Future<List<dynamic>?> _runFile(String path) async {
  try {
    final image = await loadImage(path);
    if (image == null) return null;
    var res = image.getBytes().toList();
    // logger.log(res.toString());
    var resized_image = img.copyResize(image, height: 512, width: 512);
    debugPrint('og image bytes after resize \n $resized_image');
    var normalizedImage = normalizeImage(resized_image.getBytes().toList());
    debugPrint(
        'resized image bytes after normalize \n ${normalizedImage.length}');
// tfl.Tensor dataTensor = tfl.Tensor(type: DataType.FLOAT32, value: data);
    var final_inp = normalizedImage.reshape([1, 512, 512, 3]);
    debugPrint('final inpute: $final_inp');
    // String res = await tfl
    // var res = reshapeImageForTfLite(normalizedData, 512, 512);
    final interpreter =
        await tfl.Interpreter.fromAsset('assets/models/modelc2f.tflite');

    var input = final_inp;
    // [[[21],[12],[212]]]
    var output = List.filled(1 * 4, 0).reshape([1, 4]);
    debugPrint('This is output: $output');
    interpreter.run(input, output);
    debugPrint('This is output: $output');

    return output;
  } catch (e) {
    debugPrint('Error $e');
  }
  return null;
}

class HomescreenPage extends StatefulWidget {
  const HomescreenPage({super.key});

  @override
  State<HomescreenPage> createState() => _HomescreenPageState();
}

class _HomescreenPageState extends State<HomescreenPage> {
  bool analysisStarted = false;
  bool? analysisCompleted;
  // File? selectedImage;

  @override
  Widget build(BuildContext context) {
    var deviceHeight = MediaQuery.of(context).size.height;
    var deviceWidth = MediaQuery.of(context).size.width - 60;

    return Scaffold(
      backgroundColor: ColorConstants.backgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'Kissan',
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: ColorConstants.primaryColor),
            ),
            Text(
              'Suraksha',
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: ColorConstants.primaryTextColor),
            ),
          ],
        ),
        foregroundColor: ColorConstants.primaryTextColor,
        backgroundColor: Color(0xff212521),
      ),
      body: Container(
        height: deviceHeight,
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.all(25),
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Detection',
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 30,
                          color: ColorConstants.primaryTextColor)),
                  Text('Model',
                      // textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.w100,
                          fontSize: 30,
                          fontStyle: FontStyle.italic,
                          color: ColorConstants.primaryTextColor)),
                  SizedBox(
                    height: 15,
                  ),
                  CustomDivider(),
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      BoxWithIcon(
                        text: 'Upload images',
                        icon: Icon(Icons.photo_size_select_actual_sharp),
                        height: 120,
                        width: deviceWidth * 0.33,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      BoxWithIcon(
                        text: 'Capture photo',
                        icon: Icon(Icons.camera_alt_rounded),
                        height: 120,
                        width: deviceWidth * 0.63,
                      )
                    ],
                  ),
                  SizedBox(
                    height: 45,
                  ),
                  Text('Analysis',
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 30,
                          color: ColorConstants.primaryTextColor)),
                  Text('Result',
                      // textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.w100,
                          fontSize: 30,
                          fontStyle: FontStyle.italic,
                          color: ColorConstants.primaryTextColor)),
                  SizedBox(
                    height: 15,
                  ),
                  CustomDivider(),
                  SizedBox(
                    height: 15,
                  ),
                  if (analysisStarted)
                    Center(
                      child: CircularProgressIndicator(
                        color: ColorConstants.primaryColor,
                      ),
                    ),
                  if (analysisCompleted != null && analysisCompleted!)
                    Column(
                      children: [
                        if (selectedImage != null)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: SizedBox(
                                height: 200,
                                width: 200,
                                child: Image.file(selectedImage!)),
                          ),
                        SizedBox(
                          height: 30,
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Disease Type -> ${element}',
                            style: TextStyle(
                                fontSize: 20,
                                color: ColorConstants.primaryTextColor),
                          ),
                        ),
                        SizedBox(
                          height: 50,
                        ),
                      ],
                    ),
                  SizedBox(
                    height: 100,
                  ),
                ],
              ),
            ),
            if (!analysisStarted)
              Positioned(
                  left: 0,
                  right: 0,
                  bottom: 50,
                  child: Container(
                    // color: Colors.amber,
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTap: () async {
                        setState(() {
                          analysisStarted = true;
                          analysisCompleted = false;
                        });
                        List<dynamic>? res =
                            await _runFile(selectedImage!.path);
                        // if (res) {
                        setState(() {
                          analysisStarted = false;
                          analysisCompleted = true;
                        });
                        double max = 0;
                        var index = 0;
                        for (int i = 0; i < diseases.length; i++) {
                          if (res?[0][i] > max) {
                            max = res?[0][i];
                            index = i;
                          }
                        }
                        setState(() {
                          element = diseases[index];
                        });
                        debugPrint('This is element $element');
                        // element =
                        // }
                      },
                      child: Container(
                        // width: 100,
                        // alignment: Alignment.center,
                        decoration: BoxDecoration(
                          // border: Border.all(),
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.white,
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Start',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                )),
                            Text(' Analysis',
                                style: TextStyle(
                                  fontWeight: FontWeight.w100,
                                  fontSize: 15,
                                ))
                          ],
                        ),
                      ),
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}

class BoxWithIcon extends StatefulWidget {
  const BoxWithIcon(
      {super.key,
      required this.icon,
      required this.text,
      this.height = 100,
      this.width = 100});
  final Icon icon;
  final String text;
  final double? height;
  final double? width;

  @override
  State<BoxWithIcon> createState() => _BoxWithIconState();
}

class _BoxWithIconState extends State<BoxWithIcon> {
  Future _pickImageFromGallery() async {
    try {
      final pickedFile = await _picker.getImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          selectedImage = File(pickedFile.path);
          debugPrint('path ${pickedFile.path}');
        });
        selectedImage = File(pickedFile.path);
      }
    } catch (error) {
      print("Error picking image: $error");
    }
    // try {
    //   final returnedImage =
    //       await ImagePicker().pickImage(source: ImageSource.gallery);
    //   setState(() {
    //     selectedImage = File(returnedImage!.path);
    //     debugPrint('path ${returnedImage.path}');
    //   });
    // } catch (e) {
    //   debugPrint('Error $e');
    // }
  }

  Future _pickImageFromCamera() async {
    try {
      final pickedFile = await _picker.getImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          selectedImage = File(pickedFile.path);
          debugPrint('path ${pickedFile.path}');
        });
        selectedImage = File(pickedFile.path);
      }
    } catch (error) {
      print("Error picking image: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.text.contains('image')) {
          _pickImageFromGallery();
        } else {
          _pickImageFromCamera();
        }
      },
      child: Container(
        // color: Colors.amber,
        height: widget.height! + 7,
        width: widget.width! + 7,
        child: Stack(
          children: [
            Positioned(
                bottom: 0,
                left: 0,
                child: Container(
                  height: widget.height!,
                  width: widget.width!,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: Color(0xff334434)),
                  child: SizedBox(),
                )),
            Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(10),
                  height: widget.height!,
                  width: widget.width!,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: ColorConstants.primaryColor),
                  child: Stack(
                    children: [
                      Positioned(
                          left: 0,
                          top: 0,
                          child: SizedBox(
                              width: widget.width! / 2,
                              child: Text(
                                widget.text.toUpperCase(),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xff0B220B),
                                    fontWeight: FontWeight.bold),
                              ))),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: widget.icon,
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class CustomDivider extends StatelessWidget {
  const CustomDivider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: Divider(
        thickness: 1,
        color: ColorConstants.primaryColor,
      ),
    );
  }
}
