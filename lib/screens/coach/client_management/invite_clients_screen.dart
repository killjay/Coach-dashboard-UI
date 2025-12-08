import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/app_icon_button.dart';
import '../../../widgets/common/primary_button.dart';
import '../../../widgets/common/app_card.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/invitation_service.dart';

class InviteClientsScreen extends StatefulWidget {
  const InviteClientsScreen({super.key});

  @override
  State<InviteClientsScreen> createState() => _InviteClientsScreenState();
}

class _InviteClientsScreenState extends State<InviteClientsScreen> {
  final TextEditingController _emailController = TextEditingController();
  final InvitationService _invitationService = InvitationService();
  String? _currentInviteLink;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _generateShareableLink();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _generateShareableLink() async {
    try {
      final authProvider = context.read<AuthProvider>();
      final coachId = authProvider.user?.uid;
      
      if (coachId == null) {
        return;
      }

      // Create a shareable invitation (no email)
      final result = await _invitationService.createInvitation(
        coachId: coachId,
      );

      if (result.isSuccess && result.dataOrNull != null) {
        final invitation = result.dataOrNull!;
        setState(() {
          _currentInviteLink = 'https://coachapp.com/invite/${invitation.code}';
        });
      }
    } catch (e) {
      // Handle error silently, will show error when user tries to use it
    }
  }

  Future<void> _sendInvite() async {
    final emails = _emailController.text.trim();
    if (emails.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter at least one email address'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate email format (basic validation)
    final emailList = emails.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    final invalidEmails = emailList.where((e) => !emailRegex.hasMatch(e)).toList();

    if (invalidEmails.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid email format: ${invalidEmails.join(", ")}'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final coachId = authProvider.user?.uid;

      if (coachId == null) {
        throw Exception('Coach not authenticated');
      }

      // Create invitation for each email
      int successCount = 0;
      int failCount = 0;

      for (final email in emailList) {
        final result = await _invitationService.createInvitation(
          coachId: coachId,
          email: email,
        );

        if (result.isSuccess) {
          successCount++;
        } else {
          failCount++;
        }
      }

      _emailController.clear();

      if (mounted) {
        if (failCount == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully sent ${successCount} invitation(s)!'),
              backgroundColor: AppColors.primary,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sent ${successCount} invitation(s), ${failCount} failed'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending invitations: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _copyLink() {
    if (_currentInviteLink == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Generating link...'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Clipboard.setData(ClipboardData(text: _currentInviteLink!));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Link copied!'),
        backgroundColor: AppColors.primary,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _shareLink() {
    // Open native share sheet
    // In a real app, you'd use a package like share_plus
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share feature - use share_plus package in production'),
        duration: Duration(seconds: 2),
      ),
    );
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
                      'Invite Clients',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 40),
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
                    // Invitation Header
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: AppColors.primary20,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person_add,
                              color: AppColors.primary,
                              size: 64,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Grow Your Client List',
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 32,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Send an invitation to get your new clients started.',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: const Color(0xFF8E8E93),
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
                    // Invite by Email Section
                    Text(
                      'Invite by Email',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Client email(s)',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF8E8E93),
                          ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      maxLines: 4,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                          ),
                      decoration: InputDecoration(
                        hintText: 'Enter client email(s), separated by commas',
                        hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withOpacity(0.4),
                            ),
                        filled: true,
                        fillColor: AppColors.cardDark,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(16.0),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: PrimaryButton(
                        text: _isLoading ? 'Sending...' : 'Send Invite',
                        onPressed: _isLoading ? null : _sendInvite,
                      ),
                    ),
                    const SizedBox(height: 48),
                    // Or Share a Link Section
                    Text(
                      'Or Share a Link',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Anyone with this link can join as your client.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF8E8E93),
                          ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: AppColors.cardDark,
                        borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _currentInviteLink ?? 'Generating link...',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: _currentInviteLink != null
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.5),
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: _copyLink,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary20,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.copy,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: PrimaryButton(
                        text: 'Share',
                        icon: Icons.share,
                        onPressed: _shareLink,
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
