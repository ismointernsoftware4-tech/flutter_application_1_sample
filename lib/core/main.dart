import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'firebase_options.dart';
import '../features/auth/providers/auth_provider.dart';
import '../shared/providers/dashboard_provider.dart';
import '../features/item_master/providers/item_master_provider.dart';
import '../features/item_master/providers/item_column_visibility_provider.dart';
import '../shared/providers/form_builder_provider.dart';
import '../features/dashboard/screens/dashboard_screen.dart';

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
    print('Please update firebase_options.dart with your Firebase configuration.');
    print('App will continue without Firebase. Please configure Firebase for full functionality.');
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
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => ItemMasterProvider()),
        ChangeNotifierProvider(create: (_) => ItemColumnVisibilityProvider()),
        ChangeNotifierProvider(create: (_) => FormBuilderProvider()),
      ],
      child: ShadTheme(
        data: ShadThemeData(brightness: Brightness.light),
        child: MaterialApp(
          title: 'Embryo One',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
              },
            ),
          ),
          home: const DashboardScreen(),
        ),
      ),
    );
  }
}
