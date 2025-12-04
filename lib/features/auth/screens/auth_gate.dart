import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../providers/auth_provider.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (!auth.hasCheckedAuth) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator()
                .animate(onPlay: (controller) => controller.repeat())
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.2, 1.2),
                  duration: 1000.ms,
                  curve: Curves.easeInOut,
                )
                .then()
                .scale(
                  begin: const Offset(1.2, 1.2),
                  end: const Offset(0.8, 0.8),
                  duration: 1000.ms,
                  curve: Curves.easeInOut,
                ),
            ),
          );
        }

        if (auth.isAuthenticated) {
          return const DashboardScreen()
            .animate()
            .fadeIn(duration: 300.ms);
        }

        return const LoginScreen()
          .animate()
          .fadeIn(duration: 300.ms);
      },
    );
  }
}


