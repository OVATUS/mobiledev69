import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/task_viewmodel.dart';
import '../viewmodels/theme_viewmodel.dart';
import 'widgets/task_card.dart';
import 'widgets/task_form_dialog.dart';

class TaskListView extends StatefulWidget {
  const TaskListView({super.key});

  @override
  State<TaskListView> createState() => _TaskListViewState();
}

class _TaskListViewState extends State<TaskListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskViewModel>().loadTasks();
    });
  }

  void _openTaskForm([TaskModel? task]) {
    final taskVM = context.read<TaskViewModel>();
    showDialog(
      context: context,
      builder: (_) => TaskFormDialog(
        initialTask: task,
        onSave: (savedTask) {
          if (task == null) {
            taskVM.addTask(savedTask);
          } else {
            taskVM.updateTask(savedTask);
          }
        },
      ),
    );
  }

  void _confirmDelete(int taskId) {
    final taskVM = context.read<TaskViewModel>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: const Text('คุณแน่ใจหรือไม่ว่าต้องการลบงานนี้?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ยกเลิก')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              taskVM.deleteTask(taskId);
            },
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final taskVM = context.watch<TaskViewModel>();
    final themeVM = context.watch<ThemeViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Tasks', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: 'สลับธีม',
            icon: Icon(themeVM.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeVM.toggleTheme(),
          ),
          IconButton(
            tooltip: 'ออกจากระบบ',
            icon: const Icon(Icons.logout),
            onPressed: () => authVM.logout(),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              // Dashboard Metrics
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                child: Row(
                  children: [
                    _buildSummaryCard('ทั้งหมด', taskVM.totalCount, Colors.blue),
                    const SizedBox(width: 8),
                    _buildSummaryCard('รอดำเนินการ', taskVM.pendingCount, Colors.orange),
                    const SizedBox(width: 8),
                    _buildSummaryCard('เสร็จแล้ว', taskVM.completedCount, Colors.green),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'ค้นหางาน...',
                    prefixIcon: const Icon(Icons.search),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onChanged: (val) => taskVM.setSearchQuery(val),
                ),
              ),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    for (final cat in ['ALL', 'PERSONAL', 'WORK', 'STUDY'])
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(cat == 'ALL' ? 'ทุกหมวดหมู่' : cat),
                          selected: taskVM.selectedCategory == cat,
                          onSelected: (_) => taskVM.setCategoryFilter(cat),
                        ),
                      ),
                  ],
                ),
              ),
              const Divider(height: 16),

              // Task List Area
              Expanded(
                child: taskVM.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : taskVM.errorMessage != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(taskVM.errorMessage!, style: const TextStyle(color: Colors.red)),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () => taskVM.loadTasks(),
                                  child: const Text('ลองใหม่'),
                                ),
                              ],
                            ),
                          )
                        : taskVM.filteredTasks.isEmpty
                            ? const Center(child: Text('ไม่มีรายการงาน'))
                            : ListView.builder(
                                itemCount: taskVM.filteredTasks.length,
                                itemBuilder: (context, index) {
                                  final task = taskVM.filteredTasks[index];
                                  return TaskCard(
                                    task: task,
                                    onToggleStatus: (_) => taskVM.toggleTaskStatus(task),
                                    onEdit: () => _openTaskForm(task),
                                    onDelete: () => _confirmDelete(task.id!),
                                  );
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openTaskForm(),
        icon: const Icon(Icons.add),
        label: const Text('เพิ่มงาน'),
      ),
    );
  }
}