import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../providers/auth_provider.dart';
import '../../../shared/utils/responsive_helper.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenPadding = ResponsiveHelper.getScreenPadding(context);
    final isMobile = ResponsiveHelper.isMobile(context);
    
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: screenPadding,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isMobile ? double.infinity : 420,
            ),
            child: ShadCard(
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 24 : 32),
                child: Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome Back',
                              style: TextStyle(
                                    fontSize: ResponsiveHelper.getTitleFontSize(context),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey[900],
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Sign in to continue to Embryo One',
                              style: TextStyle(color: Colors.blueGrey[500]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        ShadInput(
                          placeholder: const Text('Email'),
                          keyboardType: TextInputType.emailAddress,
                          onChanged: auth.updateLoginEmail,
                        ),
                        const SizedBox(height: 16),
                        ShadInput(
                          placeholder: const Text('Password'),
                          obscureText: true,
                          onChanged: auth.updateLoginPassword,
                        ),
                        const SizedBox(height: 12),
                        if (auth.errorMessage != null)
                          Text(
                            auth.errorMessage!,
                            style: const TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        const SizedBox(height: 24),
                        ShadButton(
                          onPressed: auth.isLoading
                              ? null
                              : () async {
                                  await auth.login();
                                },
                          child: auth.isLoading
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Login',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

