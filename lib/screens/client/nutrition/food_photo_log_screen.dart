import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/app_card.dart';
import '../../../widgets/common/primary_button.dart';
import '../../../providers/user_provider.dart';
import '../../../services/storage_service.dart';
import '../../../services/diet_service.dart';
import '../../../models/food_log_model.dart';

class FoodPhotoLogScreen extends StatefulWidget {
  const FoodPhotoLogScreen({super.key});

  @override
  State<FoodPhotoLogScreen> createState() => _FoodPhotoLogScreenState();
}

class _FoodPhotoLogScreenState extends State<FoodPhotoLogScreen> {
  final ImagePicker _picker = ImagePicker();
  final StorageService _storageService = StorageService();
  final DietService _dietService = DietService();
  
  XFile? _pickedImage;
  String _selectedMeal = 'Breakfast';
  bool _isUploading = false;

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

  Future<void> _handleUpload() async {
    if (_pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please take or select a photo first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final userProvider = context.read<UserProvider>();
    final clientId = userProvider.currentClient?.id ?? userProvider.currentUser?.id;
    
    if (clientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Client ID not found'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final imageFile = File(_pickedImage!.path);
      final now = DateTime.now();

      // Upload image to Firebase Storage
      final uploadResult = await _storageService.uploadFoodPhoto(
        imageFile: imageFile,
        clientId: clientId,
        date: now,
      );

      if (uploadResult.isFailure) {
        throw Exception(uploadResult.errorMessage ?? 'Upload failed');
      }

      final photoUrl = uploadResult.dataOrNull!;

      // Create a meal entry with the photo
      // Note: For photo logs, we'll use estimated macros (0) since we don't have nutrition analysis
      // In a real app, you might integrate with a nutrition API to analyze the photo
      final meal = MealModel(
        name: _selectedMeal,
        calories: 0.0, // Would be calculated from photo analysis in production
        protein: 0.0,
        carbs: 0.0,
        fat: 0.0,
        photoUrl: photoUrl,
      );

      // Add meal to today's food log
      final addMealResult = await _dietService.addMealToLog(
        clientId,
        now,
        meal,
      );

      if (addMealResult.isFailure) {
        throw Exception(addMealResult.errorMessage ?? 'Failed to add meal');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo uploaded successfully!'),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
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
                      text: _isUploading ? 'Uploading...' : 'Upload Photo',
                      onPressed: _isUploading ? null : _handleUpload,
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

