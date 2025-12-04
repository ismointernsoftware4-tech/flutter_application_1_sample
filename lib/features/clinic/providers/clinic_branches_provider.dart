import 'package:flutter/material.dart';

import '../models/clinic_models.dart';

class ClinicBranchesProvider extends ChangeNotifier {
  List<ClinicBranch> _branches = [];
  String? _clinicId;

  List<ClinicBranch> get branches => List.unmodifiable(_branches);

  void setBranches(String clinicId, List<ClinicBranch> branches) {
    if (_clinicId == clinicId && _branches.length == branches.length) {
      return;
    }
    _clinicId = clinicId;
    _branches = branches.map((b) => b).toList();
    notifyListeners();
  }

  void addBranch(ClinicBranch branch) {
    _branches = [..._branches, branch];
    notifyListeners();
  }

  void updateBranch(String branchId, ClinicBranch updated) {
    _branches = _branches.map((branch) {
      if (branch.branchId == branchId) {
        return updated;
      }
      return branch;
    }).toList();
    notifyListeners();
  }
}

