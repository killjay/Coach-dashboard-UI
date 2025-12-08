import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/app_card.dart';
import '../../../widgets/common/primary_button.dart';

class FoodPhotoLogScreen extends StatefulWidget {
  const FoodPhotoLogScreen({super.key});

  @override
  State<FoodPhotoLogScreen> createState() => _FoodPhotoLogScreenState();
}

class _FoodPhotoLogScreenState extends State<FoodPhotoLogScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;
  String _selectedMeal = 'Breakfast';

  final List<String> _meals = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _pickedImage = image;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleUpload() {
    if (_pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please take or select a photo first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // TODO: Upload image to Firebase Storage and save food log
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Photo uploaded successfully!'),
        backgroundColor: AppColors.primary,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Food Photo Log',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: Colors.white,
              ),
        ),
      ),
      body: Column(
        children: [
          // Meal Selection Tabs
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _meals.length,
              itemBuilder: (context, index) {
                final meal = _meals[index];
                final isSelected = _selectedMeal == meal;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedMeal = meal;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.black20,
                        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.borderWhite10,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          meal,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: isSelected
                                    ? AppColors.backgroundDark
                                    : Colors.white,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Photo Capture Area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: AppCard(
                      backgroundColor: AppColors.cardDark,
                      padding: EdgeInsets.zero,
                      child: _pickedImage != null
                          ? Stack(
                              children: [
                                Image.file(
                                  File(_pickedImage!.path),
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  top: 16,
                                  right: 16,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _pickedImage = null;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            )
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate,
                                    size: 64,
                                    color: AppColors.textSecondaryDark,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Tap to take a photo',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          color: AppColors.textSecondaryDark,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Action Buttons
                  Row(
                    children: [
                      // Gallery Button
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pickImage(ImageSource.gallery),
                          icon: const Icon(Icons.photo_library, color: Colors.white),
                          label: Text(
                            'Gallery',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Colors.white,
                                ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.borderWhite10),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Camera Button
                      Expanded(
                        flex: 2,
                        child: PrimaryButton(
                          text: 'Take Photo',
                          icon: Icons.camera_alt,
                          onPressed: () => _pickImage(ImageSource.camera),
                          height: 56,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Upload Button (only shown when image is selected)
                  if (_pickedImage != null)
                    PrimaryButton(
                      text: 'Upload Photo',
                      onPressed: _handleUpload,
                      height: 56,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

