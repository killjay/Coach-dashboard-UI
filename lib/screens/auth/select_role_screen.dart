import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/primary_button.dart';
import '../client/onboarding/demographics_screen.dart';
import '../coach/client_management/client_list_view_screen.dart';
import 'sign_up_login_screen.dart';

class SelectRoleScreen extends StatefulWidget {
  const SelectRoleScreen({super.key});

  @override
  State<SelectRoleScreen> createState() => _SelectRoleScreenState();
}

class _SelectRoleScreenState extends State<SelectRoleScreen> {
  String? _selectedRole; // 'client' or 'coach'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              Text(
                'Select Your Role',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: AppColors.textZinc900,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Choose how you want to use the app',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textZinc500,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              // Client Card
              _buildRoleCard(
                context,
                title: "I'm a Client",
                description: 'Track workouts, log nutrition, and follow your coach\'s plans',
                icon: Icons.person,
                isSelected: _selectedRole == 'client',
                onTap: () {
                  setState(() {
                    _selectedRole = 'client';
                  });
                },
              ),
              const SizedBox(height: 16),
              // Coach Card
              _buildRoleCard(
                context,
                title: "I'm a Coach",
                description: 'Manage clients, create plans, and track progress',
                icon: Icons.fitness_center,
                isSelected: _selectedRole == 'coach',
                onTap: () {
                  setState(() {
                    _selectedRole = 'coach';
                  });
                },
              ),
              const Spacer(),
              // Continue Button
              PrimaryButton(
                text: 'Continue',
                onPressed: _selectedRole == null
                    ? null
                    : () {
                        if (_selectedRole == 'client') {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const DemographicsScreen(),
                            ),
                          );
                        } else if (_selectedRole == 'coach') {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => const ClientListViewScreen(),
                            ),
                          );
                        }
                      },
              ),
              const SizedBox(height: 16),
              // Sign in Link
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const SignUpLoginScreen(),
                    ),
                  );
                },
                child: Text(
                  'Sign in',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.primary.withOpacity(0.2),
            width: isSelected ? 3 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.2)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary20,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.textZinc900,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textZinc500,
                        ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }
}
