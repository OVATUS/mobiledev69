import 'package:flutter/foundation.dart';

import '../core/result.dart';
import '../models/task_model.dart';
import '../repositories/task_repository.dart';

enum TaskSort { newest, dueDate, priority }

class TaskViewModel extends ChangeNotifier {
  final TaskRepository _repository;

  TaskViewModel(this._repository);

  List<TaskModel> _allTasks = [];
  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _loadError; // โหลดรายการไม่ได้ → แสดงเต็มจอพร้อมปุ่มลองใหม่
  String? _actionError; // เพิ่ม/แก้/ลบไม่ได้ → View แสดงเป็น SnackBar

  // ตัวกรอง (Extra Feature: ค้นหา/กรอง/เรียงลำดับ)
  String _searchQuery = '';
  String _selectedCategory = 'ALL';
  String _statusFilter = 'ALL'; // ALL, PENDING, COMPLETED
  TaskSort _sort = TaskSort.newest;

  bool get isLoading => _isLoading;
  bool get hasLoaded => _hasLoaded;
  String? get loadError => _loadError;
  String? get actionError => _actionError;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  String get statusFilter => _statusFilter;
  TaskSort get sort => _sort;

  int get totalCount => _allTasks.length;
  int get completedCount => _allTasks.where((t) => t.isCompleted).length;
  int get pendingCount => _allTasks.where((t) => !t.isCompleted).length;

  List<TaskModel> get filteredTasks {
    final query = _searchQuery.toLowerCase();
    final result = _allTasks.where((task) {
      final matchesSearch = task.title.toLowerCase().contains(query) ||
          task.description.toLowerCase().contains(query);
      final matchesCategory = _selectedCategory == 'ALL' || task.category == _selectedCategory;
      final matchesStatus = _statusFilter == 'ALL' ||
          (_statusFilter == 'COMPLETED' && task.isCompleted) ||
          (_statusFilter == 'PENDING' && !task.isCompleted);
      return matchesSearch && matchesCategory && matchesStatus;
    }).toList();

    switch (_sort) {
      case TaskSort.newest:
        break; // backend เรียงใหม่สุดมาให้แล้ว
      case TaskSort.dueDate:
        // งานที่ไม่มีกำหนดส่งไว้ท้ายสุด
        result.sort((a, b) {
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        });
      case TaskSort.priority:
        result.sort((a, b) => a.priorityRank.compareTo(b.priorityRank));
    }
    return result;
  }

  TaskModel? findById(int id) {
    for (final task in _allTasks) {
      if (task.id == id) return task;
    }
    return null;
  }

  Future<void> loadTasks() async {
    _isLoading = true;
    _loadError = null;
    notifyListeners();

    final result = await _repository.getTasks();
    switch (result) {
      case Success(:final data):
        _allTasks = data;
      case Failure(:final message):
        _loadError = message;
    }
    _isLoading = false;
    _hasLoaded = true;
    notifyListeners();
  }

  Future<bool> addTask(TaskModel task) async {
    final result = await _repository.createTask(task);
    switch (result) {
      case Success(:final data):
        _allTasks.insert(0, data);
        _actionError = null;
        notifyListeners();
        return true;
      case Failure(:final message):
        _actionError = message;
        return false;
    }
  }

  Future<bool> updateTask(TaskModel task) async {
    final result = await _repository.updateTask(task);
    switch (result) {
      case Success(:final data):
        final index = _allTasks.indexWhere((t) => t.id == data.id);
        if (index != -1) _allTasks[index] = data;
        _actionError = null;
        notifyListeners();
        return true;
      case Failure(:final message):
        _actionError = message;
        return false;
    }
  }

  Future<bool> toggleTaskStatus(TaskModel task) {
    return updateTask(task.copyWith(isCompleted: !task.isCompleted));
  }

  Future<bool> deleteTask(int taskId) async {
    final result = await _repository.deleteTask(taskId);
    switch (result) {
      case Success():
        _allTasks.removeWhere((t) => t.id == taskId);
        _actionError = null;
        notifyListeners();
        return true;
      case Failure(:final message):
        _actionError = message;
        return false;
    }
  }

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

  void setSort(TaskSort sort) {
    _sort = sort;
    notifyListeners();
  }
}