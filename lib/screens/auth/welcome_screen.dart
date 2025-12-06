import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/primary_button.dart';
import 'sign_up_login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuDuQncb-f3FUy0PLAGggqIQeetPhaKoEE1dTYmjCPycj1QezGXykKLXp8qfXU0cIDTu6LP5lqFHDaIj5hXuilTbkG8ayEmqcjefr7W9nMrbQA8CG1brsIeylbDBhK3nSiLfpMzcL3AVGHMJQOy-dJgWGVm_8qXaRubmOPZPHn852q65V2LmbH6K_Mbly_nF7UG5RDxSMf7Y4IGWbkVRnsjwVTFDtRhqR3Kkh0DPnXVltoey_9W-tGdq9tkyIjG40LWRKn66UePLi9M',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.backgroundDark.withOpacity(0.3),
                AppColors.backgroundDark.withOpacity(0.8),
                AppColors.backgroundDark,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  // Welcome Message
                  Text(
                    'Welcome to Your Fitness Journey',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 36,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Transform your body, track your progress, and achieve your goals with your personal coach.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  // Get Started Button
                  PrimaryButton(
                    text: 'Get Started',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SignUpLoginScreen(),
                        ),
                      );
                    },
                    height: 56,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
