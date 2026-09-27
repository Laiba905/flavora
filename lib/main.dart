import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';

import 'models/recipe_model.dart';
import 'models/ingredient_model.dart';
import 'services/hive_service.dart';
import 'viewmodels/recipe_viewmodel.dart';
import 'viewmodels/auth_viewmodel.dart';

import 'views/home/home_view.dart';
import 'views/auth/login_view.dart';

void main() async{

  // 1. flutter engine bindings initialization
  WidgetsFlutterBinding.ensureInitialized();

  // 2. supabase initialization
  await Supabase.initialize(
   url: 'https://eufagyilyrzwewusryij.supabase.co',
    anonKey: 'sb_publishable_0phpS6wVpj8tJHD8qPzTEg_hsKxTwtO',
  );

  // 3. hive local storage initialization
  await Hive.initFlutter();

  // hive adapter registration
  Hive.registerAdapter(RecipeModelAdapter());

  // opening hive box for favorites
  await Hive.openBox<RecipeModel>(HiveService.favoritesBoxName);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        // registering RecipeViewModel to app wide tree
        ChangeNotifierProvider(
          create: (_) => RecipeViewModel(),
        ),
      ],
      child: MaterialApp(
        title: 'Flavora',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

    // Checking if user is authenticated OR continuing as guest
    if (authViewModel.isAuthenticated || authViewModel.isGuestMode) {
      return const HomeView();
    }

    return const LoginView();
  }
}

