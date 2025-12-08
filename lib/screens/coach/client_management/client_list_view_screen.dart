import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/app_icon_button.dart';
import '../../../widgets/common/app_card.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/user_service.dart';
import '../../../models/client_model.dart';
import 'client_profile_view_screen.dart';
import 'invite_clients_screen.dart';
import '../analytics/compliance_dashboard_screen.dart';
import '../community/community_highlights_screen.dart';
import '../community/leaderboard_settings_screen.dart';
import '../plan_creation/assign_plans_screen.dart';
import '../plans/plans_overview_screen.dart';
import '../../shared/general_settings_screen.dart';

class ClientListViewScreen extends StatefulWidget {
  const ClientListViewScreen({super.key});

  @override
  State<ClientListViewScreen> createState() => _ClientListViewScreenState();
}

class _ClientListViewScreenState extends State<ClientListViewScreen> {
  final TextEditingController _searchController = TextEditingController();
  final UserService _userService = UserService();
  String _selectedSort = 'Name (A-Z)';
  String? _selectedFilter;
  String _searchQuery = '';
  List<ClientModel> _clients = [];
  bool _isLoading = true;

  final List<String> _sortOptions = [
    'Name (A-Z)',
    'Name (Z-A)',
    'Last Login (Newest)',
    'Last Login (Oldest)',
    'Compliance (High to Low)',
    'Compliance (Low to High)',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
    _subscribeToClients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _subscribeToClients() {
    final authProvider = context.read<AuthProvider>();
    final coachId = authProvider.user?.uid;

    if (coachId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Subscribe to real-time client list
    _userService.streamClientList(coachId).listen((clients) {
      if (mounted) {
        setState(() {
          _clients = clients;
          _isLoading = false;
        });
      }
    }, onError: (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading clients: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  List<ClientModel> get _filteredClients {
    var clients = _clients;
    
    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      clients = clients
          .where((c) => c.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    
    // Sort clients
    switch (_selectedSort) {
      case 'Name (A-Z)':
        clients.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'Name (Z-A)':
        clients.sort((a, b) => b.name.compareTo(a.name));
        break;
      case 'Compliance (High to Low)':
        // Note: Compliance calculation would need to be added
        break;
      case 'Compliance (Low to High)':
        // Note: Compliance calculation would need to be added
        break;
    }
    
    return clients;
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
                  Expanded(
                    child: Text(
                      'Clients',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  AppIconButton(
                    icon: Icons.add,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const InviteClientsScreen(),
                        ),
                      );
                    },
                    iconColor: Colors.white,
                  ),
                ],
              ),
            ),
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search clients...',
                  hintStyle: TextStyle(color: AppColors.white40),
                  prefixIcon: const Icon(Icons.search, color: AppColors.textSecondaryDark),
                  filled: true,
                  fillColor: AppColors.black20,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
                    borderSide: BorderSide(color: AppColors.borderWhite10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
                    borderSide: BorderSide(color: AppColors.borderWhite10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 12),
            // Sort/Filter Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _showSortOptions(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.cardDark,
                          borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Sort by: $_selectedSort',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                  ),
                            ),
                            const Icon(
                              Icons.expand_more,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedFilter = _selectedFilter == 'Last Login' ? null : 'Last Login';
                      });
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: _selectedFilter == 'Last Login'
                          ? AppColors.primary20
                          : AppColors.cardDark,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
                      ),
                    ),
                    child: Text(
                      'Last Login',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedFilter = _selectedFilter == 'Last Workout' ? null : 'Last Workout';
                      });
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: _selectedFilter == 'Last Workout'
                          ? AppColors.primary20
                          : AppColors.cardDark,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
                      ),
                    ),
                    child: Text(
                      'Last Workout',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Client List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : _filteredClients.isEmpty
                      ? Center(
                          child: Text(
                            'No clients found',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: AppColors.textSecondaryDark,
                                ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: _filteredClients.length,
                          itemBuilder: (context, index) {
                            final client = _filteredClients[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: _buildClientCard(client),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(context),
    );
  }

  Widget _buildClientCard(ClientModel client) {
    final isOnboarding = !client.onboardingCompleted;
    
    return AppCard(
      backgroundColor: AppColors.cardDark,
      padding: const EdgeInsets.all(16.0),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ClientProfileViewScreen(clientId: client.id),
          ),
        );
      },
      child: Row(
        children: [
          // Profile Picture
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary20,
            ),
            child: client.profileImageUrl != null
                ? ClipOval(
                    child: Image.network(
                      client.profileImageUrl!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Center(
                    child: Text(
                      client.name.isNotEmpty ? client.name[0].toUpperCase() : '?',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
          ),
          const SizedBox(width: 16),
          // Client Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        client.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    // Status Indicator
                    if (isOnboarding)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Onboarding',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.orange,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      )
                    else
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isOnboarding
                      ? 'In Onboarding'
                      : 'Active Client',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryDark,
                      ),
                ),
              ],
            ),
          ),
          // Chevron
          const Icon(
            Icons.chevron_right,
            color: AppColors.textSecondaryDark,
            size: 24,
          ),
        ],
      ),
    );
  }

  void _showSortOptions(BuildContext context) {
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
            Text(
              'Sort by',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ..._sortOptions.map((option) {
              final isSelected = _selectedSort == option;
              return ListTile(
                title: Text(
                  option,
                  style: TextStyle(
                    color: isSelected ? AppColors.primary : Colors.white,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  setState(() {
                    _selectedSort = option;
                  });
                  Navigator.pop(context);
                },
              );
            }),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundDark.withOpacity(0.95),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, Icons.people, 'Clients', isActive: true, onTap: () {
                // Refresh the Client List View (already on this screen)
              }),
              _buildNavItem(context, Icons.event_note, 'Plans', onTap: () {
                // Navigate to Plans Overview
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PlansOverviewScreen(),
                  ),
                );
              }),
              _buildNavItem(context, Icons.analytics, 'Analytics', onTap: () {
                // Navigate to Compliance Dashboard
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ComplianceDashboardScreen(),
                  ),
                );
              }),
              _buildNavItem(context, Icons.people_outline, 'Community', onTap: () {
                // Navigate to Community Highlights
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const CommunityHighlightsScreen(),
                  ),
                );
              }),
              _buildNavItem(context, Icons.settings, 'Settings', onTap: () {
                // Navigate to General Settings
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const GeneralSettingsScreen(),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label, {
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isActive
                ? AppColors.primary
                : Colors.grey[500],
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isActive
                      ? AppColors.primary
                      : Colors.grey[500],
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
          ),
        ],
      ),
    );
  }
}
