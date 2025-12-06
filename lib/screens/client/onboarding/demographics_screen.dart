import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/primary_button.dart';
import '../../../widgets/common/app_icon_button.dart';
import 'health_screening_screen.dart';

class DemographicsScreen extends StatefulWidget {
  const DemographicsScreen({super.key});

  @override
  State<DemographicsScreen> createState() => _DemographicsScreenState();
}

class _DemographicsScreenState extends State<DemographicsScreen> {
  DateTime? _selectedDate;
  String? _selectedGender;
  double? _height; // in cm
  double? _weight; // in kg
  int _currentStep = 0; // 0: DOB, 1: Gender, 2: Height, 3: Weight

  final List<String> _genders = ['Male', 'Female', 'Other', 'Prefer not to say'];

  void _handleContinue() {
    if (_currentStep == 0 && _selectedDate != null) {
      setState(() => _currentStep = 1);
    } else if (_currentStep == 1 && _selectedGender != null) {
      setState(() => _currentStep = 2);
    } else if (_currentStep == 2 && _height != null) {
      setState(() => _currentStep = 3);
    } else if (_currentStep == 3 && _weight != null) {
      // All demographics collected, navigate to health screening
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const HealthScreeningScreen(),
        ),
      );
    }
  }

  bool get _canContinue {
    switch (_currentStep) {
      case 0:
        return _selectedDate != null;
      case 1:
        return _selectedGender != null;
      case 2:
        return _height != null;
      case 3:
        return _weight != null;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  AppIconButton(
                    icon: Icons.arrow_back_ios_new,
                    onPressed: () {
                      if (_currentStep > 0) {
                        setState(() => _currentStep--);
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    iconColor: Colors.white.withOpacity(0.9),
                  ),
                ],
              ),
            ),
            // Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: List.generate(4, (index) {
                  final isActive = index <= _currentStep;
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.primary
                            : Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: _buildStepContent(),
              ),
            ),
            // Continue Button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
              child: SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  text: 'Continue',
                  onPressed: _canContinue ? _handleContinue : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildDateOfBirthStep();
      case 1:
        return _buildGenderStep();
      case 2:
        return _buildHeightStep();
      case 3:
        return _buildWeightStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildDateOfBirthStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Let's start with your date of birth",
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.015,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'This helps us calculate metrics like your metabolic rate.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
        ),
        const SizedBox(height: 32),
        GestureDetector(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
              firstDate: DateTime(1950),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.dark(
                      primary: AppColors.primary,
                      onPrimary: AppColors.backgroundDark,
                      surface: AppColors.card,
                      onSurface: Colors.white,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (date != null) {
              setState(() => _selectedDate = date);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedDate == null
                      ? 'Select Date of Birth'
                      : '${_getMonthName(_selectedDate!.month)} ${_selectedDate!.day}, ${_selectedDate!.year}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: _selectedDate == null
                            ? Colors.white.withOpacity(0.4)
                            : Colors.white,
                      ),
                ),
                Icon(
                  Icons.calendar_today,
                  color: Colors.white.withOpacity(0.6),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What is your gender?',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.015,
              ),
        ),
        const SizedBox(height: 32),
        ..._genders.map((gender) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: GestureDetector(
                onTap: () => setState(() => _selectedGender = gender),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: _selectedGender == gender
                        ? AppColors.primary20
                        : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
                    border: Border.all(
                      color: _selectedGender == gender
                          ? AppColors.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          gender,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                              ),
                        ),
                      ),
                      if (_selectedGender == gender)
                        Icon(
                          Icons.check_circle,
                          color: AppColors.primary,
                        ),
                    ],
                  ),
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildHeightStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What is your height?',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.015,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter your height in centimeters',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
          ),
          child: TextField(
            keyboardType: TextInputType.number,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: Colors.white,
                ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: '170',
              hintStyle: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: Colors.white.withOpacity(0.4),
                  ),
              border: InputBorder.none,
              suffixText: 'cm',
              suffixStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
            ),
            onChanged: (value) {
              final height = double.tryParse(value);
              setState(() => _height = height);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWeightStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What is your current weight?',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.015,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter your weight in kilograms',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
          ),
          child: TextField(
            keyboardType: TextInputType.number,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: Colors.white,
                ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: '70',
              hintStyle: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: Colors.white.withOpacity(0.4),
                  ),
              border: InputBorder.none,
              suffixText: 'kg',
              suffixStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
            ),
            onChanged: (value) {
              final weight = double.tryParse(value);
              setState(() => _weight = weight);
            },
          ),
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }
}
