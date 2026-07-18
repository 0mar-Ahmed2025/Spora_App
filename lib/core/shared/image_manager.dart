// ignore_for_file: strict_top_level_inference

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageManager extends StatelessWidget {
  const ImageManager({
    super.key,
    this.localImage,
    required this.unselectedImageBuilder,
    required this.selectedImageBuilder,
    this.networkImageBuilder,
    required this.onImageSelected,
  });

  final XFile? localImage;
  final Widget unselectedImageBuilder;
  final Widget Function(XFile imagePath) selectedImageBuilder;
  final Widget? networkImageBuilder;
  final Function(XFile pickedImage) onImageSelected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _pickImage(context),
      borderRadius: BorderRadius.circular(12),
      child: Builder(
        builder: (context) {
          if (localImage != null) {
            return selectedImageBuilder(localImage!);
          } else if (networkImageBuilder != null) {
            return networkImageBuilder!;
          }
          return unselectedImageBuilder;
        },
      ),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedImage != null) {
      onImageSelected(pickedImage);
    }
  }
}
