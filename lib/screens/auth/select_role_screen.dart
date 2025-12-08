import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/primary_button.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/invitation_service.dart';
import '../../services/user_service.dart';
import '../../utils/deep_link_handler.dart';
import '../../models/user_model.dart';
import '../../models/client_model.dart';
import '../../models/coach_model.dart';
import '../client/onboarding/demographics_screen.dart';
import '../client/dashboard/today_view_screen.dart';
import '../coach/client_management/client_list_view_screen.dart';
import 'sign_up_login_screen.dart';

class SelectRoleScreen extends StatefulWidget {
  final String? invitationCode;
  
  const SelectRoleScreen({
    super.key,
    this.invitationCode,
  });

  @override
  State<SelectRoleScreen> createState() => _SelectRoleScreenState();
}

class _SelectRoleScreenState extends State<SelectRoleScreen> {
  String? _selectedRole; // 'client' or 'coach'
  bool _isProcessing = false;
  final InvitationService _invitationService = InvitationService();
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    // Auto-select client role if invitation code exists
    if (widget.invitationCode != null) {
      _selectedRole = 'client';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
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
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Choose how you want to use the app',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondaryDark,
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
              // Invitation message
              if (widget.invitationCode != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.mail_outline,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'You\'ve been invited by a coach',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              // Continue Button
              PrimaryButton(
                text: _isProcessing ? 'Processing...' : 'Continue',
                onPressed: _selectedRole == null || _isProcessing
                    ? null
                    : _handleContinue,
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
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.borderWhite10,
            width: isSelected ? 3 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.3)
                  : Colors.black.withOpacity(0.3),
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
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondaryDark,
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

  Future<void> _handleContinue() async {
    if (_selectedRole == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final userProvider = context.read<UserProvider>();
      final userId = authProvider.user?.uid;

      if (userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User not authenticated. Please sign in again.'),
            ),
          );
        }
        return;
      }

      // Get user email and name from auth
      final email = authProvider.user?.email ?? '';
      final name = authProvider.user?.displayName ?? email.split('@')[0];

      if (_selectedRole == 'client') {
        // Check if client document already exists
        final existingClient = await _userService.getClient(userId);
        
        if (existingClient.isSuccess && existingClient.dataOrNull != null) {
          // Client already exists, check onboarding status
          final client = existingClient.dataOrNull!;
          
          // Accept invitation if code exists and client not linked
          if (widget.invitationCode != null && client.coachId == null) {
            await _acceptInvitation(widget.invitationCode!, userId);
          }
          
          // Load client data
          await userProvider.loadClient(userId);
          
          if (mounted) {
            if (client.onboardingCompleted) {
              // Navigate to dashboard
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => const TodayViewScreen(),
                ),
              );
            } else {
              // Navigate to onboarding
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => const DemographicsScreen(),
                ),
              );
            }
          }
        } else {
          // Create user and client documents
          final userModel = UserModel(
            id: userId,
            email: email,
            name: name,
            role: UserRole.client,
            createdAt: DateTime.now(),
          );

          final clientModel = ClientModel(
            id: userId,
            email: email,
            name: name,
            createdAt: DateTime.now(),
            onboardingCompleted: false,
          );

          // Create user document
          await _userService.createUser(userModel);
          
          // Create client document
          await _userService.setDocument('clients/$userId', clientModel.toJson());

          // Accept invitation if code exists
          if (widget.invitationCode != null) {
            await _acceptInvitation(widget.invitationCode!, userId);
          }

          // Clear invitation code
          await DeepLinkHandler.clearInvitationCode();

          // Load client data
          await userProvider.loadClient(userId);

          if (mounted) {
            // Navigate to onboarding
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => const DemographicsScreen(),
              ),
            );
          }
        }
      } else if (_selectedRole == 'coach') {
        // Check if coach document already exists
        final existingCoach = await _userService.getCoach(userId);
        
        if (existingCoach.isSuccess && existingCoach.dataOrNull != null) {
          // Coach already exists, navigate to dashboard
          await userProvider.loadCoach(userId);
          
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => const ClientListViewScreen(),
              ),
            );
          }
        } else {
          // Create user and coach documents
          final userModel = UserModel(
            id: userId,
            email: email,
            name: name,
            role: UserRole.coach,
            createdAt: DateTime.now(),
          );

          final coachModel = CoachModel(
            id: userId,
            email: email,
            name: name,
            createdAt: DateTime.now(),
            clientIds: [],
          );

          // Create user document
          await _userService.createUser(userModel);
          
          // Create coach document
          await _userService.setDocument('coaches/$userId', coachModel.toJson());

          // Verify coach document was created (retry up to 3 times)
          bool coachExists = false;
          for (int i = 0; i < 3; i++) {
            final coachResult = await _userService.getCoach(userId);
            if (coachResult.isSuccess && coachResult.dataOrNull != null) {
              coachExists = true;
              break;
            }
            await Future.delayed(const Duration(milliseconds: 300));
          }

          if (!coachExists) {
            throw Exception('Failed to create coach document');
          }

          // Load coach data
          await userProvider.loadCoach(userId);

          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => const ClientListViewScreen(),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _acceptInvitation(String code, String clientId) async {
    try {
      final result = await _invitationService.acceptInvitation(code, clientId);
      if (result.isFailure && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage ?? 'Failed to accept invitation'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      // Error already handled in service
    }
  }
}
