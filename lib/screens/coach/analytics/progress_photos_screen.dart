import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/app_icon_button.dart';
import '../../../widgets/common/app_card.dart';

class ProgressPhotosScreen extends StatefulWidget {
  final String clientName;

  const ProgressPhotosScreen({
    super.key,
    this.clientName = 'Jessica Smith',
  });

  @override
  State<ProgressPhotosScreen> createState() => _ProgressPhotosScreenState();
}

class _ProgressPhotosScreenState extends State<ProgressPhotosScreen> {
  PhotoData? _beforePhoto;
  PhotoData? _afterPhoto;
  String? _activeSlot; // 'before' or 'after'
  final TextEditingController _notesController = TextEditingController();

  final List<PhotoData> _photoTimeline = [
    PhotoData(date: DateTime(2024, 1, 5), week: 'Week 1'),
    PhotoData(date: DateTime(2024, 1, 12), week: 'Week 2'),
    PhotoData(date: DateTime(2024, 1, 19), week: 'Week 3'),
    PhotoData(date: DateTime(2024, 1, 26), week: 'Week 4'),
    PhotoData(date: DateTime(2024, 2, 2), week: 'Week 5'),
    PhotoData(date: DateTime(2024, 2, 9), week: 'Week 6'),
  ];

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _selectPhoto(PhotoData photo) {
    if (_activeSlot == 'before') {
      setState(() {
        _beforePhoto = photo;
        _activeSlot = null;
      });
    } else if (_activeSlot == 'after') {
      setState(() {
        _afterPhoto = photo;
        _activeSlot = null;
      });
    } else {
      // If no slot is active, set as before
      setState(() {
        _beforePhoto = photo;
      });
    }
  }

  void _showPhotoOptions(PhotoData photo) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility, color: Colors.white),
              title: const Text('View Full Size', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // Show full size photo
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.white),
              title: const Text('Add Notes to Photo', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // Show notes dialog
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Photo', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                // Delete photo
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  AppIconButton(
                    icon: Icons.arrow_back_ios_new,
                    onPressed: () => Navigator.of(context).pop(),
                    iconColor: Colors.white,
                  ),
                  Expanded(
                    child: Text(
                      widget.clientName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  AppIconButton(
                    icon: Icons.upload,
                    onPressed: () {
                      // Show upload/share menu
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: AppColors.cardDark,
                        builder: (context) => Container(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.camera_alt, color: Colors.white),
                                title: const Text('Upload New Photo', style: TextStyle(color: Colors.white)),
                                onTap: () {
                                  Navigator.pop(context);
                                  // Open camera/gallery
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.share, color: Colors.white),
                                title: const Text('Share Comparison', style: TextStyle(color: Colors.white)),
                                onTap: () {
                                  Navigator.pop(context);
                                  // Share comparison
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    iconColor: Colors.white,
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Comparison Section
                    Text(
                      'Compare Progress',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select two photos from the timeline below to compare.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF8E8E93),
                          ),
                    ),
                    const SizedBox(height: 24),
                    // Before/After Photos
                    Row(
                      children: [
                        Expanded(
                          child: _buildPhotoSlot(
                            photo: _beforePhoto,
                            label: 'Before',
                            onTap: () {
                              setState(() => _activeSlot = 'before');
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildPhotoSlot(
                            photo: _afterPhoto,
                            label: 'After',
                            onTap: () {
                              setState(() => _activeSlot = 'after');
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Photo Timeline
                    Text(
                      'Photo Timeline',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _photoTimeline.length,
                        itemBuilder: (context, index) {
                          final photo = _photoTimeline[index];
                          final isSelected = _beforePhoto == photo || _afterPhoto == photo;
                          return GestureDetector(
                            onTap: () => _selectPhoto(photo),
                            onLongPress: () => _showPhotoOptions(photo),
                            child: Container(
                              width: 100,
                              margin: EdgeInsets.only(right: index < _photoTimeline.length - 1 ? 12 : 0),
                              decoration: BoxDecoration(
                                color: AppColors.cardDark,
                                borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
                                border: isSelected
                                    ? Border.all(color: AppColors.primary, width: 2)
                                    : null,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: AppColors.backgroundDark,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.photo,
                                      color: Color(0xFF8E8E93),
                                      size: 32,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    photo.week,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  Text(
                                    _formatDate(photo.date),
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: const Color(0xFF8E8E93),
                                          fontSize: 10,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Coach's Notes
                    Text(
                      'Coach\'s Notes',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    AppCard(
                      backgroundColor: AppColors.cardDark,
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.note, color: AppColors.primary, size: 20),
                              const SizedBox(width: 12),
                              Text(
                                'Notes for Week 1',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Great starting point. Notice posture in the side profile...',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: const Color(0xFF8E8E93),
                                ),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () {
                              // Show edit notes dialog
                            },
                            child: Text(
                              'Edit Notes',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Open camera/gallery
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.camera_alt, color: AppColors.backgroundDark),
      ),
    );
  }

  Widget _buildPhotoSlot({
    required PhotoData? photo,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
          border: Border.all(
            color: _activeSlot == label.toLowerCase() ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: photo == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.add_photo_alternate,
                    color: Color(0xFF8E8E93),
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to Select',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF8E8E93),
                        ),
                  ),
                ],
              )
            : Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.backgroundDark,
                      borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.photo,
                        color: Color(0xFF8E8E93),
                        size: 64,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(AppTheme.radiusDefault),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            '${photo.week} ${_formatDate(photo.date)}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class PhotoData {
  final DateTime date;
  final String week;

  PhotoData({
    required this.date,
    required this.week,
  });
}
