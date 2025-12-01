import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../clinic/models/clinic_models.dart';
import '../../role/models/role_model.dart';
import '../../clinic/providers/clinic_branches_provider.dart';
import '../../clinic/providers/clinic_workspace_provider.dart';
import '../../clinic/providers/selected_clinic_provider.dart';
import '../../role/services/role_service.dart';
import '../widgets/clinic_sidebar.dart';
import '../../form_builder/screens/form_entry_screen.dart';
import '../../form_builder/screens/form_builder_workspace_screen.dart';
import '../../branch/screens/branch_management_screen.dart';
import '../../user/screens/user_management_screen.dart';
import '../../role/screens/create_role_screen.dart';

class ClinicWorkspaceScreen extends StatefulWidget {
  const ClinicWorkspaceScreen({
    super.key,
    required this.clinicId,
    required this.clinicName,
  });

  final String clinicId;
  final String clinicName;

  @override
  State<ClinicWorkspaceScreen> createState() => _ClinicWorkspaceScreenState();
}

class _ClinicWorkspaceScreenState extends State<ClinicWorkspaceScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? _lastSyncedClinicId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<SelectedClinicProvider>();
      final clinic = provider.clinic;
      // Always ensure the clinicId matches the widget's clinicId
      // This is critical - widget.clinicId comes from Firestore selection
      if (clinic == null || clinic.clinicId != widget.clinicId) {
        // Load from Firestore
        provider.loadClinicFromFirestore(widget.clinicId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<
      SelectedClinicProvider,
      ClinicWorkspaceProvider,
      ClinicBranchesProvider
    >(
      builder:
          (
            context,
            clinicProvider,
            workspaceProvider,
            branchesProvider,
            child,
          ) {
            final clinic = clinicProvider.clinic;
            final section = workspaceProvider.selectedSection;
            final isMobile = MediaQuery.of(context).size.width < 900;

            if (clinic != null && _lastSyncedClinicId != clinic.clinicId) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                branchesProvider.setBranches(clinic.clinicId, clinic.branches);
              });
              _lastSyncedClinicId = clinic.clinicId;
            }

            if (clinic == null) {
              return Scaffold(
                key: _scaffoldKey,
                appBar: AppBar(
                  title: Text(widget.clinicName),
                  leading: isMobile
                      ? IconButton(
                          icon: const Icon(Icons.menu),
                          onPressed: () =>
                              _scaffoldKey.currentState?.openDrawer(),
                        )
                      : null,
                ),
                drawer: isMobile ? const ClinicSidebar(isDrawer: true) : null,
                body: const Center(child: CircularProgressIndicator()),
              );
            }

            return Scaffold(
              key: _scaffoldKey,
              appBar: AppBar(
                title: Text(clinic.clinicName),
                leading: isMobile
                    ? IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () =>
                            _scaffoldKey.currentState?.openDrawer(),
                      )
                    : null,
              ),
              drawer: isMobile ? const ClinicSidebar(isDrawer: true) : null,
              body: Row(
                children: [
                  if (!isMobile) const ClinicSidebar(),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _WorkspaceHeader(
                          clinicName: clinic.clinicName,
                          shortName: clinic.shortName,
                          selectedSection: section,
                        ),
                        Expanded(child: _buildSection(section, clinic)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
    );
  }

  Widget _buildSection(String section, ClinicData clinic) {
    switch (section) {
      case 'Clinic Details':
        return _ClinicDetailsTab(clinic: clinic);
      case 'Clinic Branches':
        return BranchManagementScreen(clinicId: clinic.clinicId);
      case 'Clinic Users':
        return const UserManagementScreen();
      case 'Clinic Roles':
        return _ClinicRolesTab(clinic: clinic);
      case 'Clinic Settings':
        return _ClinicSettingsTab(clinic: clinic);
      case 'Clinic Form Builder':
        return FormBuilderWorkspaceScreen(
          initialFormId: 'form_add_item',
          clinicId: clinic.clinicId,
        );
      default:
        if (section.startsWith('Clinic Form:')) {
          final formTitle = section.substring('Clinic Form:'.length);
          return FormEntryScreen(
            formTitle: formTitle,
            clinicId: clinic.clinicId,
            clinicName: clinic.clinicName,
          );
        }
        return _ClinicDashboardTab(clinic: clinic);
    }
  }
}

class _WorkspaceHeader extends StatelessWidget {
  const _WorkspaceHeader({
    required this.clinicName,
    required this.shortName,
    required this.selectedSection,
  });

  final String clinicName;
  final String shortName;
  final String selectedSection;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            selectedSection,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            '$clinicName • $shortName',
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _ClinicDashboardTab extends StatelessWidget {
  const _ClinicDashboardTab({required this.clinic});

  final ClinicData clinic;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _heroSection(context),
          const SizedBox(height: 24),
          _statsGrid(),
          const SizedBox(height: 24),
          _modulesSection(),
          const SizedBox(height: 24),
          _quickLinks(),
        ],
      ),
    );
  }

  Widget _heroSection(BuildContext context) {
    const Color primaryDark = Color(0xFF312E81);
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEEF2FF), Color(0xFFE0E7FF), Color(0xFFDBEAFE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 18),
            blurRadius: 35,
            spreadRadius: -10,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 6),
            blurRadius: 15,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: primaryDark.withOpacity(0.15)),
                    ),
                    child: Text(
                      clinic.shortName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: primaryDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    clinic.clinicName,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.black.withOpacity(0.08),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              clinic.status.toLowerCase() == 'active'
                                  ? Icons.check_circle
                                  : Icons.pause_circle,
                              color: clinic.status.toLowerCase() == 'active'
                                  ? Colors.green[600]
                                  : Colors.orange[600],
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              clinic.status,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                        '${clinic.summary.totalBranches} Active Branches',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _HeroButton(
                  color: const Color(0xFF4338CA),
                  icon: Icons.edit_outlined,
                  label: 'Edit details',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Edit details coming soon')),
                    );
                  },
                ),
                _HeroButton(
                  color: const Color(0xFF2563EB),
                  icon: Icons.account_tree_outlined,
                  label: 'Add branch',
                  outlined: true,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Add branch coming soon')),
                    );
                  },
                ),
                _HeroButton(
                  color: const Color(0xFF1D4ED8),
                  icon: Icons.person_add_alt_1,
                  label: 'Add user',
                  outlined: true,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Add user coming soon')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statsGrid() {
    final summary = clinic.summary;
    final stats = [
      _StatItem('Branches', summary.totalBranches, Icons.location_city),
      _StatItem('Users', summary.totalUsers, Icons.people),
      _StatItem('Vendors', summary.totalVendors, Icons.storefront),
      _StatItem('Items', summary.totalItems, Icons.inventory_2),
      _StatItem('Low Stock', summary.lowStockAlerts, Icons.warning_amber),
      _StatItem('Expiring Soon', summary.expiringSoon, Icons.timer),
      _StatItem('Pending PO', summary.pendingPO, Icons.assignment_outlined),
      _StatItem('Pending GRN', summary.pendingGRN, Icons.receipt_long),
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: stats
          .map(
            (item) => _StatCard(
              title: item.title,
              value: item.value,
              icon: item.icon,
            ),
          )
          .toList(),
    );
  }

  Widget _modulesSection() {
    final enabled = clinic.modules.enabledModules.toList();
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enabled Modules',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            if (enabled.isEmpty)
              const Text('No modules enabled.')
            else
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: enabled
                    .map(
                      (module) => Chip(
                        label: Text(module),
                        avatar: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 18,
                        ),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _quickLinks() {
    final summary = clinic.summary;
    final cards = [
      _QuickLinkCard(
        title: 'Branches',
        value: summary.totalBranches.toString(),
        description: 'Manage clinic branches',
        icon: Icons.account_tree_outlined,
      ),
      _QuickLinkCard(
        title: 'Users',
        value: summary.totalUsers.toString(),
        description: 'Clinic administrators',
        icon: Icons.people_alt_outlined,
      ),
      _QuickLinkCard(
        title: 'Vendors',
        value: summary.totalVendors.toString(),
        description: 'Linked vendors',
        icon: Icons.store_mall_directory_outlined,
      ),
      _QuickLinkCard(
        title: 'Inventory',
        value: summary.totalItems.toString(),
        description:
            'Low stock: ${summary.lowStockAlerts}, Expiring: ${summary.expiringSoon}',
        icon: Icons.inventory_2_outlined,
      ),
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: cards
          .map(
            (card) => SizedBox(
              width: 260,
              child: Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(card.icon, size: 30, color: Colors.blue[700]),
                      const SizedBox(height: 12),
                      Text(
                        card.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        card.value,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        card.description,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _ClinicDetailsTab extends StatelessWidget {
  const _ClinicDetailsTab({required this.clinic});

  final ClinicData clinic;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionCard(
            title: 'General Information',
            children: [
              _detailRow('Clinic Code', clinic.clinicCode),
              _detailRow('Legal Name', clinic.legalName),
              _detailRow('Description', clinic.description),
              _detailRow(
                'Working Hours',
                '${clinic.settings.workingHoursStart} - ${clinic.settings.workingHoursEnd}',
              ),
              _detailRow('Timezone', clinic.settings.timezone),
            ],
          ),
          const SizedBox(height: 16),
          _sectionCard(
            title: 'Contact & Address',
            children: [
              _detailRow('Phone', clinic.contact.phone),
              _detailRow('Email', clinic.contact.email),
              _detailRow('Website', clinic.contact.website),
              _detailRow(
                'Primary Contact',
                '${clinic.contact.primaryContactPerson} (${clinic.contact.primaryContactNumber})',
              ),
              _detailRow(
                'Address',
                '${clinic.address.addressLine1}, ${clinic.address.addressLine2}, ${clinic.address.city}, ${clinic.address.state} - ${clinic.address.pincode}, ${clinic.address.country}',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _sectionCard(
            title: 'Licenses & Documents',
            trailing: FilledButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Edit clinic details coming soon'),
                  ),
                );
              },
              child: const Text('Edit Clinic Details'),
            ),
            children: [
              _detailRow('GST Number', clinic.license.gstNumber),
              _detailRow('PAN Number', clinic.license.panNumber),
              _detailRow('Drug License No', clinic.license.drugLicenseNo),
              _detailRow('FSSAI Number', clinic.license.fssaiNumber),
              _detailRow('Registration Date', clinic.license.registrationDate),
              _detailRow('License Expiry', clinic.license.licenseExpiryDate),
              const SizedBox(height: 12),
              const Text(
                'Documents',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ...clinic.license.documents.map(
                (doc) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.picture_as_pdf_outlined),
                  title: Text(doc.name),
                  subtitle: Text(doc.url),
                  trailing: IconButton(
                    icon: const Icon(Icons.open_in_new),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Open ${doc.name} coming soon')),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    List<Widget>? children,
    Widget? trailing,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
            const SizedBox(height: 12),
            ...children ?? [],
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ClinicRolesTab extends StatelessWidget {
  _ClinicRolesTab({required this.clinic});

  final ClinicData clinic;
  final RoleService _roleService = RoleService();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Roles & Permissions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  debugPrint('Add Role button pressed in Clinic Roles tab');
                  debugPrint('Clinic ID: ${clinic.clinicId}');
                  
                  // Use Future.microtask to ensure navigation happens after current frame
                  Future.microtask(() {
                    if (!context.mounted) {
                      debugPrint('Context not mounted, cannot navigate');
                      return;
                    }
                    
                    try {
                      debugPrint('Navigating to CreateRoleScreen...');
                      Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            debugPrint('Building CreateRoleScreen widget...');
                            try {
                              return CreateRoleScreen(
                                clinicId: clinic.clinicId,
                              );
                            } catch (e) {
                              debugPrint('Error creating CreateRoleScreen: $e');
                              return Scaffold(
                                appBar: AppBar(title: const Text('Error')),
                                body: Center(
                                  child: Text('Error: $e'),
                                ),
                              );
                            }
                          },
                        ),
                      ).then((created) {
                        debugPrint('Returned from CreateRoleScreen: $created');
                        if (created == true && context.mounted) {
                          final messenger = ScaffoldMessenger.maybeOf(context);
                          messenger?.showSnackBar(
                            const SnackBar(
                              content: Text('Role created successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      }).catchError((error) {
                        debugPrint('Error in navigation: $error');
                        if (context.mounted) {
                          final messenger = ScaffoldMessenger.maybeOf(context);
                          messenger?.showSnackBar(
                            SnackBar(
                              content: Text('Error: $error'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      });
                    } catch (e, stackTrace) {
                      debugPrint('Exception in Add Role button: $e');
                      debugPrint('Stack trace: $stackTrace');
                      if (context.mounted) {
                        final messenger = ScaffoldMessenger.maybeOf(context);
                        messenger?.showSnackBar(
                          SnackBar(
                            content: Text('Error opening form: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Role'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<List<RoleModel>>(
              stream: _roleService.getRolesStream(clinic.clinicId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error loading roles: ${snapshot.error}'),
                      ],
                    ),
                  );
                }

                final roles = snapshot.data ?? [];

                if (roles.isEmpty) {
                  return const Center(
                    child: Text(
                      'No roles defined yet.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: roles.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final role = roles[index];
                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.blue[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.shield_outlined,
                                    color: Colors.blue[700],
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        role.roleName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      if (role.description.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          role.description,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: role.status == 'Active'
                                        ? Colors.green[100]
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    role.status,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: role.status == 'Active'
                                          ? Colors.green[800]
                                          : Colors.grey[700],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                PopupMenuButton(
                                  icon: const Icon(Icons.more_vert),
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      child: const Row(
                                        children: [
                                          Icon(Icons.edit, size: 18),
                                          SizedBox(width: 8),
                                          Text('Edit'),
                                        ],
                                      ),
                                      onTap: () {
                                        Future.delayed(
                                          const Duration(milliseconds: 100),
                                          () {
                                            ScaffoldMessenger.maybeOf(context)
                                                ?.showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Edit ${role.roleName} coming soon',
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                    PopupMenuItem(
                                      child: const Row(
                                        children: [
                                          Icon(Icons.delete, size: 18, color: Colors.red),
                                          SizedBox(width: 8),
                                          Text('Delete', style: TextStyle(color: Colors.red)),
                                        ],
                                      ),
                                      onTap: () {
                                        Future.delayed(
                                          const Duration(milliseconds: 100),
                                          () {
                                            _showDeleteDialog(context, role);
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                Chip(
                                  label: Text(
                                    '${role.permissions.length} permissions',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  visualDensity: VisualDensity.compact,
                                ),
                                Chip(
                                  label: Text(
                                    'Created: ${_formatDate(role.createdAt)}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, RoleModel role) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Role'),
        content: Text('Are you sure you want to delete "${role.roleName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                await _roleService.deleteRole(
                  clinicId: clinic.clinicId,
                  roleId: role.id,
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                    SnackBar(
                      content: Text('${role.roleName} deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                    SnackBar(
                      content: Text('Error deleting role: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _ClinicSettingsTab extends StatelessWidget {
  const _ClinicSettingsTab({required this.clinic});

  final ClinicData clinic;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _settingsCard(
            title: 'Operational Settings',
            children: [
              SwitchListTile(
                title: const Text('Allow Multi Branch'),
                value: clinic.settings.allowMultiBranch,
                onChanged: null,
                secondary: const Icon(Icons.account_tree),
              ),
              SwitchListTile(
                title: const Text('Enable Stock Tracking'),
                value: clinic.settings.enableStockTracking,
                onChanged: null,
                secondary: const Icon(Icons.inventory),
              ),
              SwitchListTile(
                title: const Text('Enable Batch Management'),
                value: clinic.settings.enableBatchManagement,
                onChanged: null,
                secondary: const Icon(Icons.qr_code),
              ),
              SwitchListTile(
                title: const Text('Enable Expiry Management'),
                value: clinic.settings.enableExpiryManagement,
                onChanged: null,
                secondary: const Icon(Icons.timer),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _settingsCard(
            title: 'Modules & Features',
            children: clinic.modules.modules.entries
                .map(
                  (entry) => SwitchListTile(
                    title: Text(entry.key),
                    value: entry.value,
                    onChanged: null,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          _settingsCard(
            title: 'Billing Prefixes',
            children: [
              _billingRow('Billing Prefix', clinic.billing.billingPrefix),
              _billingRow('PO Prefix', clinic.billing.poPrefix),
              _billingRow('GRN Prefix', clinic.billing.grnPrefix),
              _billingRow('Invoice Prefix', clinic.billing.invoicePrefix),
              _billingRow(
                'Financial Year',
                '${clinic.billing.financialYearStart} - ${clinic.billing.financialYearEnd}',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Save settings coming soon')),
                );
              },
              icon: const Icon(Icons.save),
              label: const Text('Save Settings'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _billingRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _StatItem {
  final String title;
  final int value;
  final IconData icon;

  const _StatItem(this.title, this.value, this.icon);
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final int value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Colors.blue[700]),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value.toString(),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickLinkCard {
  final String title;
  final String value;
  final String description;
  final IconData icon;

  const _QuickLinkCard({
    required this.title,
    required this.value,
    required this.description,
    required this.icon,
  });
}


class _HeroButton extends StatelessWidget {
  const _HeroButton({
    required this.color,
    required this.icon,
    required this.label,
    this.outlined = false,
    required this.onPressed,
  });

  final Color color;
  final IconData icon;
  final String label;
  final bool outlined;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [Icon(icon, size: 18), const SizedBox(width: 8), Text(label)],
    );

    if (outlined) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withOpacity(0.4)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: child,
      );
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 6,
        shadowColor: color.withOpacity(0.3),
      ),
      child: child,
    );
  }
}

