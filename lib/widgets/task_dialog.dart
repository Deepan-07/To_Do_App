import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class TaskDialog extends StatefulWidget {
  final Task? task;
  const TaskDialog({super.key, this.task});

  @override
  State<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  DateTime? _dueDate;
  late TaskPriority _priority;

  @override
  void initState() {
    super.initState();
    _title = widget.task?.title ?? '';
    _description = widget.task?.description ?? '';
    _dueDate = widget.task?.dueDate;
    _priority = widget.task?.priority ?? TaskPriority.medium;
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.task != null;
    return AlertDialog(
      title: Text(isEdit ? 'Edit Task' : 'Add Task'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => v == null || v.isEmpty ? 'Enter a title' : null,
                onSaved: (v) => _title = v!,
              ),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (v) => v == null || v.isEmpty ? 'Enter a description' : null,
                onSaved: (v) => _description = v!,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Due Date:'),
                  const SizedBox(width: 8),
                  Text(_dueDate == null ? 'None' : _dueDate!.toLocal().toString().split(' ')[0]),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _dueDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) setState(() => _dueDate = picked);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Priority:'),
                  const SizedBox(width: 8),
                  DropdownButton<TaskPriority>(
                    value: _priority,
                    items: TaskPriority.values.map((p) {
                      return DropdownMenuItem(
                        value: p,
                        child: Text(p.name[0].toUpperCase() + p.name.substring(1)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _priority = val);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              final taskProvider = Provider.of<TaskProvider>(context, listen: false);
              if (isEdit) {
                final updated = widget.task!
                  ..title = _title
                  ..description = _description
                  ..dueDate = _dueDate
                  ..priority = _priority;
                taskProvider.updateTask(updated);
              } else {
                final newTask = Task(
                  id: const Uuid().v4(),
                  title: _title,
                  description: _description,
                  dueDate: _dueDate,
                  priority: _priority,
                );
                taskProvider.addTask(newTask);
              }
              Navigator.of(context).pop();
            }
          },
          child: Text(isEdit ? 'Update' : 'Add'),
        ),
      ],
    );
  }
} 