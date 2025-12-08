import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/app_icon_button.dart';
import '../../widgets/common/app_card.dart';
import '../coach/community/leaderboard_settings_screen.dart';

class GeneralSettingsScreen extends StatefulWidget {
  const GeneralSettingsScreen({super.key});

  @override
  State<GeneralSettingsScreen> createState() => _GeneralSettingsScreenState();
}

class _GeneralSettingsScreenState extends State<GeneralSettingsScreen> {
  bool _pushNotificationsEnabled = true;

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
                      'General Settings',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 40), // Spacer for centering
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
                    // Account Section
                    _buildSectionHeader('Account'),
                    const SizedBox(height: 8),
                    _buildAccountSection(),
                    const SizedBox(height: 24),
                    // Notifications Section
                    _buildSectionHeader('Notifications'),
                    const SizedBox(height: 8),
                    _buildNotificationsSection(),
                    const SizedBox(height: 24),
                    // Privacy Section
                    _buildSectionHeader('Privacy'),
                    const SizedBox(height: 8),
                    _buildPrivacySection(),
                    const SizedBox(height: 24),
                    // Support & About Section
                    _buildSectionHeader('Support & About'),
                    const SizedBox(height: 8),
                    _buildSupportSection(),
                    const SizedBox(height: 24),
                    // Log Out Button
                    _buildLogOutButton(),
                    const SizedBox(height: 24),
                    SizedBox(height: MediaQuery.of(context).padding.bottom),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondaryDark,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
      ),
    );
  }

  Widget _buildAccountSection() {
    return AppCard(
      backgroundColor: AppColors.cardDark,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _buildSettingsRow(
            icon: Icons.person,
            title: 'Profile',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Edit Coach Profile screen coming soon'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            showDivider: true,
          ),
          _buildSettingsRow(
            icon: Icons.lock,
            title: 'Password & Security',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Password & Security screen coming soon'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            showDivider: true,
          ),
          _buildSettingsRow(
            icon: Icons.star,
            title: 'Subscription',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Coach Subscription Management screen coming soon'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            showDivider: true,
          ),
          _buildSettingsRow(
            icon: Icons.credit_card,
            title: 'Payment Methods',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Payment Methods Management screen coming soon'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            showDivider: true,
          ),
          _buildSettingsRow(
            icon: Icons.link,
            title: 'Linked Accounts',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Linked Accounts Management screen coming soon'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return AppCard(
      backgroundColor: AppColors.cardDark,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _buildToggleRow(
            icon: Icons.notifications,
            title: 'Push Notifications',
            value: _pushNotificationsEnabled,
            onChanged: (value) {
              setState(() {
                _pushNotificationsEnabled = value;
              });
            },
            showDivider: true,
          ),
          _buildEmailNotificationsRow(),
        ],
      ),
    );
  }

  Widget _buildPrivacySection() {
    return AppCard(
      backgroundColor: AppColors.cardDark,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _buildSettingsRow(
            icon: Icons.share,
            title: 'Data Sharing',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Coach Data Sharing Preferences screen coming soon'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            showDivider: true,
          ),
          _buildSettingsRow(
            icon: Icons.shield,
            title: 'Leaderboard Settings',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const LeaderboardSettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection() {
    return AppCard(
      backgroundColor: AppColors.cardDark,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _buildSettingsRow(
            icon: Icons.help_center,
            title: 'Help & Support',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Help Center screen coming soon'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            showDivider: true,
          ),
          _buildSettingsRow(
            icon: Icons.support_agent,
            title: 'Contact Support',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Contact Support screen coming soon'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            showDivider: true,
          ),
          _buildSettingsRow(
            icon: Icons.description,
            title: 'Terms & Conditions',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Terms & Conditions coming soon'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            showDivider: true,
          ),
          _buildSettingsRow(
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Privacy Policy coming soon'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            showDivider: true,
          ),
          _buildSettingsRow(
            icon: Icons.info,
            title: 'App Version',
            onTap: null,
            trailing: Text(
              '1.0.0',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsRow({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    bool showDivider = false,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: showDivider
            ? BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              )
            : null,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.transparent,
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.normal,
                    ),
              ),
            ),
            if (trailing != null)
              trailing
            else if (onTap != null)
              Icon(
                Icons.chevron_right,
                color: AppColors.textSecondaryDark,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleRow({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool showDivider = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: showDivider
          ? BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
            )
          : null,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.transparent,
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.normal,
                  ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildEmailNotificationsRow() {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Coach Email Preferences screen coming soon'),
            duration: Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.transparent,
              ),
              child: Icon(
                Icons.mail,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Email Notifications',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.normal,
                    ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.textSecondaryDark,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogOutButton() {
    return AppCard(
      backgroundColor: AppColors.cardDark,
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: () {
          _showLogOutConfirmation(context);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: Text(
              'Log Out',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ),
      ),
    );
  }

  void _showLogOutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: const Text(
          'Log Out',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to log out?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement actual logout logic
              // Navigate to Sign Up or Log In screen
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/sign-in',
                (route) => false,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logged out successfully'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            child: const Text(
              'Log Out',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

