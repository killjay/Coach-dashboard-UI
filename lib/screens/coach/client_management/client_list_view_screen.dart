import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/app_icon_button.dart';
import '../../../widgets/common/app_card.dart';
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
  String _selectedSort = 'Name (A-Z)';
  String? _selectedFilter;
  String _searchQuery = '';

  final List<String> _sortOptions = [
    'Name (A-Z)',
    'Name (Z-A)',
    'Last Login (Newest)',
    'Last Login (Oldest)',
    'Compliance (High to Low)',
    'Compliance (Low to High)',
  ];

  // Mock data
  final List<ClientData> _allClients = [
    ClientData(
      name: 'Eleanor Pena',
      lastLogin: '2 hours ago',
      lastWorkout: 'Yesterday',
      compliance: 92,
      status: ClientStatus.active,
      profilePicture: null,
    ),
    ClientData(
      name: 'Alex Morgan',
      lastLogin: '1 day ago',
      lastWorkout: '2 days ago',
      compliance: 85,
      status: ClientStatus.active,
      profilePicture: null,
    ),
    ClientData(
      name: 'Sarah Williams',
      lastLogin: '3 days ago',
      lastWorkout: '3 days ago',
      compliance: 78,
      status: ClientStatus.active,
      profilePicture: null,
    ),
    ClientData(
      name: 'Mike Chen',
      lastLogin: '5 days ago',
      lastWorkout: '1 week ago',
      compliance: 65,
      status: ClientStatus.atRisk,
      profilePicture: null,
    ),
  ];

  List<ClientData> get _filteredClients {
    var clients = _allClients;
    
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
      case 'Last Login (Newest)':
        // In production, this would sort by actual date
        break;
      case 'Last Login (Oldest)':
        // In production, this would sort by actual date
        break;
      case 'Compliance (High to Low)':
        clients.sort((a, b) => b.compliance.compareTo(a.compliance));
        break;
      case 'Compliance (Low to High)':
        clients.sort((a, b) => a.compliance.compareTo(b.compliance));
        break;
    }
    
    return clients;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredClients = _filteredClients;

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
              child: filteredClients.isEmpty
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
                      itemCount: filteredClients.length,
                      itemBuilder: (context, index) {
                        final client = filteredClients[index];
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

  Widget _buildClientCard(ClientData client) {
    return AppCard(
      backgroundColor: AppColors.cardDark,
                          padding: const EdgeInsets.all(16.0),
                          onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ClientProfileViewScreen(clientId: client.name),
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
            child: client.profilePicture != null
                ? ClipOval(
                    child: Image.network(
                      client.profilePicture!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Center(
                                child: Text(
                      client.name[0],
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
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: client.status == ClientStatus.active
                            ? AppColors.primary
                            : Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                                    Text(
                  'Last workout: ${client.lastWorkout}',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryDark,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
          // Compliance Metric & Chevron
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                    '${client.compliance}%',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  Text(
                                    'Compliance',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondaryDark,
                          fontSize: 10,
                                        ),
                                  ),
                                ],
                              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: AppColors.textSecondaryDark,
                size: 24,
              ),
            ],
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

enum ClientStatus {
  active,
  atRisk,
  inactive,
}

class ClientData {
  final String name;
  final String lastLogin;
  final String lastWorkout;
  final int compliance;
  final ClientStatus status;
  final String? profilePicture;

  ClientData({
    required this.name,
    required this.lastLogin,
    required this.lastWorkout,
    required this.compliance,
    required this.status,
    this.profilePicture,
  });
}
