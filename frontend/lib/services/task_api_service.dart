import 'package:dio/dio.dart';
import '../core/constants.dart';
import '../models/task_model.dart';
import 'secure_storage_service.dart';

class TaskApiService {
  final Dio _dio = Dio();
  final SecureStorageService _storageService;

  TaskApiService(this._storageService) {
    _dio.options.baseUrl = AppConstants.backendBaseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);

    // ใส่ Interceptor เพื่อแนบ Bearer Access Token อัตโนมัติทุก Request
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storageService.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  Future<List<TaskModel>> getTasks() async {
    final response = await _dio.get('/api/tasks/');
    final List list = response.data as List;
    return list.map((item) => TaskModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<TaskModel> createTask(TaskModel task) async {
    final response = await _dio.post('/api/tasks/', data: task.toJson());
    return TaskModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<TaskModel> updateTask(TaskModel task) async {
    final response = await _dio.put('/api/tasks/${task.id}/', data: task.toJson());
    return TaskModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteTask(int taskId) async {
    await _dio.delete('/api/tasks/$taskId/');
  }
}