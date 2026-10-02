import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/task_viewmodel.dart';
import '../viewmodels/theme_viewmodel.dart';
import 'widgets/task_actions.dart';
import 'widgets/task_card.dart';

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

  Widget _buildSummaryCard(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text('$count',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskArea(TaskViewModel taskVM) {
    if (taskVM.isLoading && !taskVM.hasLoaded) {
      return const Center(child: CircularProgressIndicator());
    }
    if (taskVM.loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 56, color: Colors.redAccent),
              const SizedBox(height: 12),
              Text(taskVM.loadError!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: taskVM.isLoading ? null : () => taskVM.loadTasks(),
                icon: const Icon(Icons.refresh),
                label: const Text('ลองใหม่'),
              ),
            ],
          ),
        ),
      );
    }
    final tasks = taskVM.filteredTasks;
    if (tasks.isEmpty) {
      return Center(
        child: Text(taskVM.totalCount == 0
            ? 'ยังไม่มีงาน กด "เพิ่มงาน" เพื่อเริ่มต้น'
            : 'ไม่พบงานที่ตรงกับตัวกรอง'),
      );
    }
    return RefreshIndicator(
      onRefresh: taskVM.loadTasks,
      child: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return TaskCard(
            task: task,
            onTap: () => context.push('/tasks/${task.id}'),
            onToggleStatus: (_) => toggleTaskStatus(context, task),
            onEdit: () => openTaskForm(context, task: task),
            onDelete: () => confirmAndDeleteTask(context, task.id!),
          );
        },
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Daily Tasks', style: TextStyle(fontWeight: FontWeight.bold)),
            if (authVM.user != null)
              Text('สวัสดี ${authVM.user!.name}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.normal)),
          ],
        ),
        actions: [
          PopupMenuButton<TaskSort>(
            tooltip: 'เรียงลำดับ',
            icon: const Icon(Icons.sort),
            initialValue: taskVM.sort,
            onSelected: taskVM.setSort,
            itemBuilder: (_) => const [
              PopupMenuItem(value: TaskSort.newest, child: Text('ใหม่ล่าสุด')),
              PopupMenuItem(value: TaskSort.dueDate, child: Text('กำหนดส่งใกล้สุด')),
              PopupMenuItem(value: TaskSort.priority, child: Text('ความสำคัญสูงสุด')),
            ],
          ),
          IconButton(
            tooltip: 'สลับธีม',
            icon: Icon(themeVM.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: themeVM.toggleTheme,
          ),
          IconButton(
            tooltip: 'ออกจากระบบ',
            icon: const Icon(Icons.logout),
            onPressed: authVM.isBusy ? null : authVM.logout,
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'ค้นหางาน...',
                    prefixIcon: const Icon(Icons.search),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onChanged: taskVM.setSearchQuery,
                ),
              ),
              // กรองหมวดหมู่
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
              // กรองสถานะ
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'ALL', label: Text('ทั้งหมด')),
                    ButtonSegment(value: 'PENDING', label: Text('ยังไม่เสร็จ')),
                    ButtonSegment(value: 'COMPLETED', label: Text('เสร็จแล้ว')),
                  ],
                  selected: {taskVM.statusFilter},
                  onSelectionChanged: (s) => taskVM.setStatusFilter(s.first),
                ),
              ),
              const Divider(height: 16),
              Expanded(child: _buildTaskArea(taskVM)),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => openTaskForm(context),
        icon: const Icon(Icons.add),
        label: const Text('เพิ่มงาน'),
      ),
    );
  }
}