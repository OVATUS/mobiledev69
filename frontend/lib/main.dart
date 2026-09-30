import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'repositories/auth_repository.dart';
import 'repositories/task_repository.dart';
import 'services/auth_service.dart';
import 'services/secure_storage_service.dart';
import 'services/task_api_service.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/task_viewmodel.dart';
import 'viewmodels/theme_viewmodel.dart';
import 'views/login_view.dart';
import 'views/task_list_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Dependency Injection Setup
    final storageService = SecureStorageService();
    final authService = AuthService(storageService);
    final taskApiService = TaskApiService(storageService);

    final authRepo = AuthRepository(authService);
    final taskRepo = TaskRepository(taskApiService);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel(authRepo)),
        ChangeNotifierProvider(create: (_) => TaskViewModel(taskRepo)),
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
      ],
      child: Consumer<ThemeViewModel>(
        builder: (context, themeVM, _) {
          return MaterialApp(
            title: 'Daily Task Tracker',
            debugShowCheckedModeBanner: false,
            themeMode: themeVM.themeMode,
            theme: ThemeData(
              useMaterial3: true,
              colorSchemeSeed: Colors.blueAccent,
              brightness: Brightness.light,
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorSchemeSeed: Colors.blueAccent,
              brightness: Brightness.dark,
            ),
            home: const AuthGate(),
          );
        },
      ),
    );
  }
}

// 2. Route Guard: ตรวจสอบสถานะการเข้าสู่ระบบ
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();

    if (authVM.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (authVM.isAuthenticated) {
      return const TaskListView();
    }

    return const LoginView();
  }
}