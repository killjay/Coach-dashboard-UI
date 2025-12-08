import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/app_icon_button.dart';
import '../../../widgets/common/app_card.dart';
import '../../../widgets/common/primary_button.dart';

class AssignPlansScreen extends StatefulWidget {
  final String? preSelectedClientId;

  const AssignPlansScreen({
    super.key,
    this.preSelectedClientId,
  });

  @override
  State<AssignPlansScreen> createState() => _AssignPlansScreenState();
}

class _AssignPlansScreenState extends State<AssignPlansScreen> {
  final TextEditingController _searchController = TextEditingController();
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedWorkoutTemplate;
  String? _selectedDietPlan;

  late List<ClientData> _allClients;

  @override
  void initState() {
    super.initState();
    _allClients = [
      ClientData(name: 'Alex Morgan', isSelected: false),
      ClientData(name: 'James Anderson', isSelected: false),
      ClientData(name: 'Serena Williams', isSelected: false),
      ClientData(name: 'Michael Chen', isSelected: false),
      ClientData(name: 'Emma Thompson', isSelected: false),
    ];
    
    // Pre-select client if provided
    if (widget.preSelectedClientId != null) {
      for (var client in _allClients) {
        if (client.name == widget.preSelectedClientId) {
          client.isSelected = true;
          break;
        }
      }
    }
  }

  List<ClientData> get _filteredClients {
    if (_searchController.text.isEmpty) {
      return _allClients;
    }
    return _allClients
        .where((client) => client.name.toLowerCase().contains(_searchController.text.toLowerCase()))
        .toList();
  }

  bool get _isAllSelected {
    final filtered = _filteredClients;
    return filtered.isNotEmpty && filtered.every((client) => client.isSelected);
  }

  void _toggleSelectAll() {
    final allSelected = _isAllSelected;
    setState(() {
      for (var client in _filteredClients) {
        client.isSelected = !allSelected;
      }
    });
  }

  int get _selectedCount => _allClients.where((c) => c.isSelected).length;

  void _assignPlans() {
    if (_selectedCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one client'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedWorkoutTemplate == null && _selectedDietPlan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one plan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Plans assigned to $_selectedCount client(s)!'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  void dispose() {
    _searchController.dispose();
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
                      'Assign Plan',
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
                    // Search Bar
                    TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                          ),
                      decoration: InputDecoration(
                        hintText: 'Search by client name...',
                        hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: const Color(0xFF8E8E93),
                            ),
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF8E8E93)),
                        filled: true,
                        fillColor: AppColors.cardDark,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(16.0),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // SELECT CLIENTS Section
                    Text(
                      'SELECT CLIENTS',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    // Select All
                    AppCard(
                      backgroundColor: AppColors.cardDark,
                      padding: const EdgeInsets.all(16.0),
                      onTap: _toggleSelectAll,
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primary20,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.people,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Select All',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          Checkbox(
                            value: _isAllSelected,
                            onChanged: (_) => _toggleSelectAll(),
                            activeColor: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Individual Clients
                    ..._filteredClients.map((client) => Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: AppCard(
                            backgroundColor: AppColors.cardDark,
                            padding: const EdgeInsets.all(16.0),
                            onTap: () {
                              setState(() {
                                client.isSelected = !client.isSelected;
                              });
                            },
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: AppColors.primary20,
                                  child: Text(
                                    client.name[0],
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    client.name,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                                Checkbox(
                                  value: client.isSelected,
                                  onChanged: (value) {
                                    setState(() {
                                      client.isSelected = value ?? false;
                                    });
                                  },
                                  activeColor: AppColors.primary,
                                ),
                              ],
                            ),
                          ),
                        )),
                    const SizedBox(height: 32),
                    // SELECT PLAN & DATE Section
                    Text(
                      'SELECT PLAN & DATE',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    // Workout Template
                    AppCard(
                      backgroundColor: AppColors.cardDark,
                      padding: const EdgeInsets.all(16.0),
                      onTap: () {
                        // Navigate to workout template selection
                        setState(() {
                          _selectedWorkoutTemplate = 'Full Body Strength';
                        });
                      },
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primary20,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.fitness_center,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Workout Template',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: const Color(0xFF8E8E93),
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _selectedWorkoutTemplate ?? 'Choose a workout template',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: _selectedWorkoutTemplate != null
                                            ? Colors.white
                                            : const Color(0xFF8E8E93),
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Color(0xFF8E8E93)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Diet Plan
                    AppCard(
                      backgroundColor: AppColors.cardDark,
                      padding: const EdgeInsets.all(16.0),
                      onTap: () {
                        // Navigate to diet plan selection
                        setState(() {
                          _selectedDietPlan = 'High Protein - 2200 kcal';
                        });
                      },
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primary20,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.restaurant,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Diet Plan',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: const Color(0xFF8E8E93),
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _selectedDietPlan ?? 'Choose a diet plan',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: _selectedDietPlan != null
                                            ? Colors.white
                                            : const Color(0xFF8E8E93),
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Color(0xFF8E8E93)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Start Date
                    AppCard(
                      backgroundColor: AppColors.cardDark,
                      padding: const EdgeInsets.all(16.0),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _startDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.dark(
                                  primary: AppColors.primary,
                                  onPrimary: AppColors.backgroundDark,
                                  surface: AppColors.cardDark,
                                  onSurface: Colors.white,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (date != null) {
                          setState(() {
                            _startDate = date;
                          });
                        }
                      },
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primary20,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.calendar_today,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Start Date',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: const Color(0xFF8E8E93),
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatDate(_startDate),
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Color(0xFF8E8E93)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            // Assign Button
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AppColors.backgroundDark,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  text: _selectedCount > 0
                      ? 'Assign to $_selectedCount Client${_selectedCount > 1 ? 's' : ''}'
                      : 'Assign Plan',
                  onPressed: _assignPlans,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ClientData {
  String name;
  bool isSelected;

  ClientData({
    required this.name,
    required this.isSelected,
  });
}
