import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerWidget extends StatelessWidget {
  final Function(File) onImageSelected;
  final String? currentImageUrl;

  const ImagePickerWidget({
    super.key,
    required this.onImageSelected,
    this.currentImageUrl,
  });

  Future<void> _pickImage(BuildContext context) async {
    try {
      final imagePicker = ImagePicker();
      final pickedFile =
          await imagePicker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        onImageSelected(File(pickedFile.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pickImage(context),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          image: currentImageUrl != null
              ? DecorationImage(
                  image: NetworkImage(currentImageUrl!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: currentImageUrl == null
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate_outlined, size: 48),
                    SizedBox(height: 8),
                    Text('Add Event Flyer'),
                  ],
                ),
              )
            : null,
      ),
    );
  }
}
