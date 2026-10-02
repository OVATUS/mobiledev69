import '../core/api_client.dart';
import '../models/task_model.dart';

class TaskApiService {
  final ApiClient _api;

  TaskApiService(this._api);

  Future<List<TaskModel>> getTasks() async {
    final response = await _api.dio.get('/api/tasks/');
    final list = response.data as List;
    return list.map((item) => TaskModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<TaskModel> createTask(TaskModel task) async {
    final response = await _api.dio.post('/api/tasks/', data: task.toJson());
    return TaskModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<TaskModel> updateTask(TaskModel task) async {
    final response = await _api.dio.put('/api/tasks/${task.id}/', data: task.toJson());
    return TaskModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteTask(int taskId) async {
    await _api.dio.delete('/api/tasks/$taskId/');
  }
}