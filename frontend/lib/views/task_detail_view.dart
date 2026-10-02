import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../viewmodels/task_viewmodel.dart';
import 'widgets/task_actions.dart';

class TaskDetailView extends StatefulWidget {
  final int? taskId;

  const TaskDetailView({super.key, required this.taskId});

  @override
  State<TaskDetailView> createState() => _TaskDetailViewState();
}

class _TaskDetailViewState extends State<TaskDetailView> {
  @override
  void initState() {
    super.initState();
    // เปิดหน้านี้ตรงๆ (เช่น รีเฟรชหน้า) จะยังไม่มีข้อมูล → โหลดก่อน
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<TaskViewModel>();
      if (!vm.hasLoaded) vm.loadTasks();
    });
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          SizedBox(width: 110, child: Text(label, style: const TextStyle(color: Colors.grey))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TaskViewModel>();
    final id = widget.taskId;
    final task = id == null ? null : vm.findById(id);

    if (task == null) {
      final stillLoading = vm.isLoading || !vm.hasLoaded;
      return Scaffold(
        appBar: AppBar(title: const Text('รายละเอียดงาน')),
        body: Center(
          child: stillLoading
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(vm.loadError ?? 'ไม่พบงานนี้ อาจถูกลบไปแล้ว'),
                    const SizedBox(height: 12),
                    ElevatedButton(onPressed: _goBack, child: const Text('กลับไปหน้ารายการ')),
                  ],
                ),
        ),
      );
    }

    final dateFormat = DateFormat('dd MMM yyyy');
    final dateTimeFormat = DateFormat('dd MMM yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('รายละเอียดงาน'),
        actions: [
          IconButton(
            tooltip: 'แก้ไข',
            icon: const Icon(Icons.edit),
            onPressed: () => openTaskForm(context, task: task),
          ),
          IconButton(
            tooltip: 'ลบ',
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () async {
              final deleted = await confirmAndDeleteTask(context, task.id!);
              if (deleted && mounted) _goBack();
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                task.title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                task.description.isEmpty ? 'ไม่มีรายละเอียด' : task.description,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const Divider(height: 32),
              _infoRow(Icons.folder_outlined, 'หมวดหมู่', task.category),
              _infoRow(Icons.flag_outlined, 'ความสำคัญ', task.priority),
              _infoRow(Icons.event, 'กำหนดส่ง',
                  task.dueDate == null ? 'ไม่ได้ระบุ' : dateFormat.format(task.dueDate!)),
              _infoRow(Icons.check_circle_outline, 'สถานะ',
                  task.isCompleted ? 'เสร็จแล้ว' : 'ยังไม่เสร็จ'),
              if (task.createdAt != null)
                _infoRow(Icons.schedule, 'สร้างเมื่อ', dateTimeFormat.format(task.createdAt!)),
              if (task.updatedAt != null)
                _infoRow(Icons.update, 'แก้ไขล่าสุด', dateTimeFormat.format(task.updatedAt!)),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => toggleTaskStatus(context, task),
                icon: Icon(task.isCompleted ? Icons.undo : Icons.check),
                label: Text(task.isCompleted ? 'ทำเครื่องหมายว่ายังไม่เสร็จ' : 'ทำเครื่องหมายว่าเสร็จแล้ว'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}