import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/task_model.dart';
import '../../viewmodels/task_viewmodel.dart';
import 'task_form_dialog.dart';

/// ฟังก์ชันที่หน้า List และหน้า Detail ใช้ร่วมกัน

void showAppSnackBar(ScaffoldMessengerState messenger, String message, {bool isError = false}) {
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red.shade700 : null,
      behavior: SnackBarBehavior.floating,
    ));
}

/// เปิดฟอร์มเพิ่ม (task == null) หรือแก้ไขงาน
void openTaskForm(BuildContext context, {TaskModel? task}) {
  final taskVM = context.read<TaskViewModel>();
  final messenger = ScaffoldMessenger.of(context);

  showDialog(
    context: context,
    builder: (_) => TaskFormDialog(
      initialTask: task,
      onSave: (savedTask) async {
        final ok = task == null
            ? await taskVM.addTask(savedTask)
            : await taskVM.updateTask(savedTask);
        if (ok) {
          showAppSnackBar(messenger, task == null ? 'เพิ่มงานแล้ว' : 'บันทึกการแก้ไขแล้ว');
        } else {
          showAppSnackBar(messenger, taskVM.actionError ?? 'บันทึกไม่สำเร็จ', isError: true);
        }
      },
    ),
  );
}

/// ถามยืนยันก่อนลบ — คืนค่า true ถ้าลบสำเร็จ
Future<bool> confirmAndDeleteTask(BuildContext context, int taskId) async {
  final taskVM = context.read<TaskViewModel>();
  final messenger = ScaffoldMessenger.of(context);

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('ยืนยันการลบ'),
      content: const Text('คุณแน่ใจหรือไม่ว่าต้องการลบงานนี้?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('ยกเลิก')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('ลบ'),
        ),
      ],
    ),
  );
  if (confirmed != true) return false;

  final ok = await taskVM.deleteTask(taskId);
  if (ok) {
    showAppSnackBar(messenger, 'ลบงานแล้ว');
  } else {
    showAppSnackBar(messenger, taskVM.actionError ?? 'ลบไม่สำเร็จ', isError: true);
  }
  return ok;
}

/// สลับสถานะเสร็จ/ยังไม่เสร็จ
Future<void> toggleTaskStatus(BuildContext context, TaskModel task) async {
  final taskVM = context.read<TaskViewModel>();
  final messenger = ScaffoldMessenger.of(context);
  final ok = await taskVM.toggleTaskStatus(task);
  if (!ok) {
    showAppSnackBar(messenger, taskVM.actionError ?? 'อัปเดตสถานะไม่สำเร็จ', isError: true);
  }
}