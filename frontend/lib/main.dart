import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/api_client.dart';
import 'core/router.dart';
import 'repositories/auth_repository.dart';
import 'repositories/task_repository.dart';
import 'repositories/theme_repository.dart';
import 'services/auth_service.dart';
import 'services/secure_storage_service.dart';
import 'services/task_api_service.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/task_viewmodel.dart';
import 'viewmodels/theme_viewmodel.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    // Dependency Injection: Service → Repository → ViewModel
    MultiProvider(
      providers: [
        // Services
        Provider<SecureStorageService>(create: (_) => SecureStorageService()),
        Provider<ApiClient>(create: (c) => ApiClient(c.read<SecureStorageService>())),
        Provider<AuthService>(
          create: (c) => AuthService(c.read<SecureStorageService>(), c.read<ApiClient>()),
        ),
        Provider<TaskApiService>(create: (c) => TaskApiService(c.read<ApiClient>())),
        // Repositories
        Provider<AuthRepository>(
          create: (c) => AuthRepository(c.read<AuthService>(), c.read<ApiClient>()),
        ),
        Provider<TaskRepository>(create: (c) => TaskRepository(c.read<TaskApiService>())),
        Provider<ThemeRepository>(create: (c) => ThemeRepository(c.read<SecureStorageService>())),
        // ViewModels
        ChangeNotifierProvider<AuthViewModel>(
          create: (c) => AuthViewModel(c.read<AuthRepository>()),
        ),
        ChangeNotifierProvider<TaskViewModel>(
          create: (c) => TaskViewModel(c.read<TaskRepository>()),
        ),
        ChangeNotifierProvider<ThemeViewModel>(
          create: (c) => ThemeViewModel(c.read<ThemeRepository>()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createRouter(context.read<AuthViewModel>()); // สร้างครั้งเดียว
  }

  @override
  Widget build(BuildContext context) {
    final themeVM = context.watch<ThemeViewModel>();

    return MaterialApp.router(
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
      routerConfig: _router,
    );
  }
}