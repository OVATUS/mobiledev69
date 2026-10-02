import 'package:go_router/go_router.dart';

import '../viewmodels/auth_viewmodel.dart';
import '../views/login_view.dart';
import '../views/splash_view.dart';
import '../views/task_detail_view.dart';
import '../views/task_list_view.dart';

/// Route Guard: ทุกหน้ายกเว้น /login ต้องล็อกอินก่อน
GoRouter createRouter(AuthViewModel auth) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: auth, // auth เปลี่ยนเมื่อไหร่ ตรวจ redirect ใหม่ทันที
    redirect: (context, state) {
      final location = state.matchedLocation;

      if (auth.isInitializing) {
        return location == '/splash' ? null : '/splash';
      }
      if (!auth.isAuthenticated) {
        return location == '/login' ? null : '/login';
      }
      if (location == '/login' || location == '/splash') {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashView()),
      GoRoute(path: '/login', builder: (context, state) => const LoginView()),
      GoRoute(
        path: '/',
        builder: (context, state) => const TaskListView(),
        routes: [
          GoRoute(
            path: 'tasks/:id',
            builder: (context, state) => TaskDetailView(
              taskId: int.tryParse(state.pathParameters['id'] ?? ''),
            ),
          ),
        ],
      ),
    ],
  );
}