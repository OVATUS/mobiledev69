import '../core/error_mapper.dart';
import '../core/result.dart';
import '../models/task_model.dart';
import '../services/task_api_service.dart';

class TaskRepository {
  final TaskApiService _apiService;

  TaskRepository(this._apiService);

  Future<Result<List<TaskModel>>> getTasks() async {
    try {
      return Success(await _apiService.getTasks());
    } catch (e) {
      return Failure(mapErrorToMessage(e));
    }
  }

  Future<Result<TaskModel>> createTask(TaskModel task) async {
    try {
      return Success(await _apiService.createTask(task));
    } catch (e) {
      return Failure(mapErrorToMessage(e));
    }
  }

  Future<Result<TaskModel>> updateTask(TaskModel task) async {
    try {
      return Success(await _apiService.updateTask(task));
    } catch (e) {
      return Failure(mapErrorToMessage(e));
    }
  }

  Future<Result<void>> deleteTask(int taskId) async {
    try {
      await _apiService.deleteTask(taskId);
      return const Success(null);
    } catch (e) {
      return Failure(mapErrorToMessage(e));
    }
  }
}