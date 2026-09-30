import '../core/result.dart';
import '../models/task_model.dart';
import '../services/task_api_service.dart';

class TaskRepository {
  final TaskApiService _apiService;

  TaskRepository(this._apiService);

  Future<Result<List<TaskModel>>> getTasks() async {
    try {
      final tasks = await _apiService.getTasks();
      return Success(tasks);
    } catch (e) {
      return Failure('Failed to fetch tasks: ${e.toString()}');
    }
  }

  Future<Result<TaskModel>> createTask(TaskModel task) async {
    try {
      final newTask = await _apiService.createTask(task);
      return Success(newTask);
    } catch (e) {
      return Failure('Failed to create task: ${e.toString()}');
    }
  }

  Future<Result<TaskModel>> updateTask(TaskModel task) async {
    try {
      final updatedTask = await _apiService.updateTask(task);
      return Success(updatedTask);
    } catch (e) {
      return Failure('Failed to update task: ${e.toString()}');
    }
  }

  Future<Result<void>> deleteTask(int taskId) async {
    try {
      await _apiService.deleteTask(taskId);
      return const Success(null);
    } catch (e) {
      return Failure('Failed to delete task: ${e.toString()}');
    }
  }
}