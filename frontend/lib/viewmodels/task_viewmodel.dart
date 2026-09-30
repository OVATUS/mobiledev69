import 'package:flutter/foundation.dart';
import '../core/result.dart';
import '../models/task_model.dart';
import '../repositories/task_repository.dart';

class TaskViewModel extends ChangeNotifier {
  final TaskRepository _repository;

  List<TaskModel> _allTasks = [];
  bool _isLoading = false;
  String? _errorMessage;

  // ฟิลเตอร์สำหรับ Extra Features
  String _searchQuery = '';
  String _selectedCategory = 'ALL';
  String _statusFilter = 'ALL'; // ALL, PENDING, COMPLETED

  TaskViewModel(this._repository);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  String get statusFilter => _statusFilter;

  // คืนค่ารายการงานที่ผ่านการค้นหาและฟิลเตอร์แล้ว
  List<TaskModel> get filteredTasks {
    return _allTasks.where((task) {
      // ตรวจสอบ Search Query
      final matchesSearch = task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          task.description.toLowerCase().contains(_searchQuery.toLowerCase());

      // ตรวจสอบ หมวดหมู่
      final matchesCategory = _selectedCategory == 'ALL' || task.category == _selectedCategory;

      // ตรวจสอบ สถานะเสร็จ/ไม่เสร็จ
      final matchesStatus = _statusFilter == 'ALL' ||
          (_statusFilter == 'COMPLETED' && task.isCompleted) ||
          (_statusFilter == 'PENDING' && !task.isCompleted);

      return matchesSearch && matchesCategory && matchesStatus;
    }).toList();
  }

  // Dashboard Summary Metrics
  int get totalCount => _allTasks.length;
  int get completedCount => _allTasks.where((t) => t.isCompleted).length;
  int get pendingCount => _allTasks.where((t) => !t.isCompleted).length;

  Future<void> loadTasks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getTasks();
    switch (result) {
      case Success(:final data):
        _allTasks = data;
        _errorMessage = null;
      case Failure(:final message):
        _errorMessage = message;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addTask(TaskModel task) async {
    final result = await _repository.createTask(task);
    switch (result) {
      case Success(:final data):
        _allTasks.insert(0, data);
        notifyListeners();
        return true;
      case Failure(:final message):
        _errorMessage = message;
        notifyListeners();
        return false;
    }
  }

  Future<bool> updateTask(TaskModel task) async {
    final result = await _repository.updateTask(task);
    switch (result) {
      case Success(:final data):
        final index = _allTasks.indexWhere((t) => t.id == data.id);
        if (index != -1) {
          _allTasks[index] = data;
          notifyListeners();
        }
        return true;
      case Failure(:final message):
        _errorMessage = message;
        notifyListeners();
        return false;
    }
  }

  Future<void> toggleTaskStatus(TaskModel task) async {
    final updated = task.copyWith(isCompleted: !task.isCompleted);
    await updateTask(updated);
  }

  Future<bool> deleteTask(int taskId) async {
    final result = await _repository.deleteTask(taskId);
    switch (result) {
      case Success():
        _allTasks.removeWhere((t) => t.id == taskId);
        notifyListeners();
        return true;
      case Failure(:final message):
        _errorMessage = message;
        notifyListeners();
        return false;
    }
  }

  // ฟังก์ชันควบคุม Filter
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategoryFilter(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setStatusFilter(String status) {
    _statusFilter = status;
    notifyListeners();
  }
}