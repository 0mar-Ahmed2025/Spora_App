// ignore_for_file: strict_top_level_inference

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageManager extends StatefulWidget {
  const ImageManager({
    super.key,
    required this.unselectedImageBuilder,
    required this.selectedImageBuilder,
    this.networkImageBuilder,
    required this.onImageSelected,
  });

  final Widget unselectedImageBuilder;
  final Widget Function(XFile imagePath) selectedImageBuilder;
  final Widget? networkImageBuilder;
  final Function(XFile pickedImage) onImageSelected;

  @override
  State<ImageManager> createState() => _ImageManagerState();
}

class _ImageManagerState extends State<ImageManager> {
  final ImagePicker picker = ImagePicker();
  XFile? image;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: pickImage,
      borderRadius: BorderRadius.circular(12),
      child: Builder(
        builder: (context) {
          if (image != null) {
            return widget.selectedImageBuilder(image!);
          } else if (widget.networkImageBuilder != null) {
            return widget.networkImageBuilder!;
          }
          return widget.unselectedImageBuilder;
        },
      ),
    );
  }

  pickImage() async {
    image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      widget.onImageSelected(image!);
    }

    setState(() {});
  }
}
