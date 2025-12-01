import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../models/branch_model.dart';
import '../services/branch_service.dart';
import '../providers/branch_form_provider.dart';
import '../controllers/branch_form_controller.dart';
import 'add_branch_screen.dart';

class BranchManagementScreen extends StatefulWidget {
  const BranchManagementScreen({super.key, required this.clinicId});

  final String clinicId;

  @override
  State<BranchManagementScreen> createState() => _BranchManagementScreenState();
}

class _BranchManagementScreenState extends State<BranchManagementScreen> {
  final BranchService _branchService = BranchService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Branch Management',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => _showAddBranchDialog(context),
                  icon: const Icon(Icons.add_business_outlined),
                  label: const Text('Add Branch'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: StreamBuilder<List<BranchModel>>(
                stream: _branchService.getAllBranches(widget.clinicId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading branches',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              '${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Clinic ID: ${widget.clinicId}',
                            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    );
                  }

                  final branches = snapshot.data ?? [];
                  
                  debugPrint('BranchManagementScreen: Displaying ${branches.length} branches for clinic ${widget.clinicId}');

                  if (branches.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.business_outlined, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          const Text(
                            'No branches found',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add your first branch to get started',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Clinic ID: ${widget.clinicId}',
                            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: branches.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final branch = branches[index];
                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey[200]!),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: branch.status == 'Active'
                                  ? Colors.green[50]
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.business,
                              color: branch.status == 'Active'
                                  ? Colors.green[700]
                                  : Colors.grey[600],
                            ),
                          ),
                          title: Text(
                            branch.branchName.isNotEmpty 
                                ? branch.branchName 
                                : branch.branchCode.isNotEmpty 
                                    ? branch.branchCode 
                                    : 'Branch ${branch.branchId}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              if (branch.branchCode.isNotEmpty || branch.branchType.isNotEmpty)
                                Text(
                                  [
                                    if (branch.branchCode.isNotEmpty) branch.branchCode,
                                    if (branch.branchType.isNotEmpty) branch.branchType,
                                  ].join(' • '),
                                ),
                              if (branch.city.isNotEmpty || branch.state.isNotEmpty)
                                Text('${branch.city}${branch.city.isNotEmpty && branch.state.isNotEmpty ? ', ' : ''}${branch.state}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Chip(
                                label: Text(
                                  branch.status,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                backgroundColor: branch.status == 'Active'
                                    ? Colors.green[50]
                                    : Colors.grey[200],
                                labelStyle: TextStyle(
                                  color: branch.status == 'Active'
                                      ? Colors.green[700]
                                      : Colors.grey[700],
                                ),
                              ),
                              const SizedBox(width: 8),
                              PopupMenuButton(
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, size: 18),
                                        SizedBox(width: 8),
                                        Text('Edit'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, size: 18, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Delete', style: TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                  ),
                                ],
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _showEditBranchDialog(context, branch);
                                  } else if (value == 'delete') {
                                    _deleteBranch(context, branch);
                                  }
                                },
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
      ),
    );
  }

  void _showAddBranchDialog(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => BranchFormProvider(clinicId: widget.clinicId),
            ),
            ChangeNotifierProvider(
              create: (_) => BranchFormController(clinicId: widget.clinicId),
            ),
          ],
          child: AddBranchScreen(clinicId: widget.clinicId),
        ),
      ),
    );
    
    if (result != null && context.mounted) {
      // Branch was created successfully, the stream will automatically update
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Branch added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showEditBranchDialog(BuildContext context, BranchModel branch) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit branch functionality coming soon')),
    );
  }

  Future<void> _deleteBranch(BuildContext context, BranchModel branch) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Branch'),
        content: Text('Are you sure you want to delete ${branch.branchName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await _branchService.deleteBranch(widget.clinicId, branch.branchId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Branch deleted successfully')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }
}

