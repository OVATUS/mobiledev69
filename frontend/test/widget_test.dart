import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/task_model.dart';

void main() {
  test('TaskModel แปลง JSON ไป-กลับได้ถูกต้อง', () {
    final task = TaskModel.fromJson({
      'id': 1,
      'title': 'อ่านหนังสือ',
      'category': 'STUDY',
      'priority': 'HIGH',
      'due_date': '2026-10-15',
      'is_completed': false,
    });
    expect(task.title, 'อ่านหนังสือ');
    expect(task.priorityRank, 0);
    expect(task.toJson()['due_date'], '2026-10-15');
  });
}