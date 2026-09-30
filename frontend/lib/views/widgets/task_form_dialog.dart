import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/task_model.dart';

class TaskFormDialog extends StatefulWidget {
  final TaskModel? initialTask;
  final Function(TaskModel) onSave;

  const TaskFormDialog({
    super.key,
    this.initialTask,
    required this.onSave,
  });

  @override
  State<TaskFormDialog> createState() => _TaskFormDialogState();
}

class _TaskFormDialogState extends State<TaskFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late String _selectedCategory;
  late String _selectedPriority;
  DateTime? _selectedDueDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTask?.title ?? '');
    _descController = TextEditingController(text: widget.initialTask?.description ?? '');
    _selectedCategory = widget.initialTask?.category ?? 'PERSONAL';
    _selectedPriority = widget.initialTask?.priority ?? 'MEDIUM';
    _selectedDueDate = widget.initialTask?.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final task = TaskModel(
        id: widget.initialTask?.id,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        category: _selectedCategory,
        priority: _selectedPriority,
        dueDate: _selectedDueDate,
        isCompleted: widget.initialTask?.isCompleted ?? false,
      );
      widget.onSave(task);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return AlertDialog(
      title: Text(widget.initialTask == null ? 'เพิ่มงานใหม่' : 'แก้ไขงาน'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'ชื่องาน *',
                    hintText: 'กรอกชื่องานของคุณ',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'กรุณากรอกชื่องาน';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'รายละเอียด',
                    hintText: 'รายละเอียดเพิ่มเติม (ไม่บังคับ)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'หมวดหมู่',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'PERSONAL', child: Text('Personal (ส่วนตัว)')),
                    DropdownMenuItem(value: 'WORK', child: Text('Work (งาน)')),
                    DropdownMenuItem(value: 'STUDY', child: Text('Study (การเรียน)')),
                  ],
                  onChanged: (val) => setState(() => _selectedCategory = val!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedPriority,
                  decoration: const InputDecoration(
                    labelText: 'ระดับความสำคัญ',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'LOW', child: Text('Low (ต่ำ)')),
                    DropdownMenuItem(value: 'MEDIUM', child: Text('Medium (ปานกลาง)')),
                    DropdownMenuItem(value: 'HIGH', child: Text('High (สูง)')),
                  ],
                  onChanged: (val) => setState(() => _selectedPriority = val!),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event),
                  title: Text(
                    _selectedDueDate == null
                        ? 'กำหนดส่ง: ไม่ได้ระบุ'
                        : 'กำหนดส่ง: ${dateFormat.format(_selectedDueDate!)}',
                  ),
                  trailing: TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDueDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2035),
                      );
                      if (picked != null) {
                        setState(() => _selectedDueDate = picked);
                      }
                    },
                    child: const Text('เลือกวันที่'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('ยกเลิก'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('บันทึก'),
        ),
      ],
    );
  }
}