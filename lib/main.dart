import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'firebase_options.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/clinic/providers/selected_clinic_provider.dart';
import 'features/form_builder/providers/form_builder_workspace_provider.dart';
import 'features/form_builder/providers/form_builder_provider.dart';
import 'features/auth/screens/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with error handling
  // If Firebase is not configured, the app will still run
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization error: $e');
    print(
      'Please update firebase_options.dart with your Firebase configuration.',
    );
    print(
      'App will continue without Firebase. Please configure Firebase for full functionality.',
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FormBuilderProvider()),
        ChangeNotifierProvider(create: (_) => FormBuilderWorkspaceProvider()),
        ChangeNotifierProvider(create: (_) => SelectedClinicProvider()),
      ],
      child: ShadApp(
        title: 'Embryo One',
        debugShowCheckedModeBanner: false,
        home: const AuthGate(),
      ),
    );
  }
}
