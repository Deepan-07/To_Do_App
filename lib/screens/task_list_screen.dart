import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/task_dialog.dart';
import '../models/task.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});
  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  String _search = '';

  Color _priorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.medium:
        return Colors.amber[700]!;
      case TaskPriority.low:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final theme = Theme.of(context);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6FA),
        body: SafeArea(
          child: Column(
            children: [
              // Custom AppBar with solid color (no border radius)
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF2563EB),
                ),
                padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'To Do App',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.logout, color: Colors.white),
                          onPressed: () => auth.signOut(),
                          tooltip: 'Sign out',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TabBar(
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white70,
                      indicatorColor: Colors.white,
                      indicatorWeight: 3,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                      tabs: const [
                        Tab(text: 'All'),
                        Tab(text: 'Open'),
                        Tab(text: 'Completed'),
                      ],
                    ),
                  ],
                ),
              ),
              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search tasks...',
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    onChanged: (val) => setState(() => _search = val),
                  ),
                ),
              ),
              // Task list
              Expanded(
                child: TabBarView(
                  children: [
                    _buildTaskList(context, filter: 'all'),
                    _buildTaskList(context, filter: 'open'),
                    _buildTaskList(context, filter: 'completed'),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF2563EB),
          onPressed: () => showDialog(
            context: context,
            builder: (_) => const TaskDialog(),
          ),
          child: const Icon(Icons.add, color: Colors.white),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  Widget _buildTaskList(BuildContext context, {required String filter}) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, _) {
        final allTasks = taskProvider.tasks;
        List<Task> filtered = allTasks.where((t) {
          final matchesSearch = t.title.toLowerCase().contains(_search.toLowerCase()) || t.description.toLowerCase().contains(_search.toLowerCase());
          return matchesSearch;
        }).toList();
        if (filter == 'open') {
          filtered = filtered.where((t) => !t.isComplete).toList();
        } else if (filter == 'completed') {
          filtered = filtered.where((t) => t.isComplete).toList();
        }
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: filtered.isEmpty
              ? Center(
                  key: const ValueKey('empty'),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.inbox, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No tasks found!', style: TextStyle(fontSize: 20, color: Colors.grey)),
                      SizedBox(height: 8),
                      Text('Tap the + button to add your first task.', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    setState(() {}); // Simulate refresh
                  },
                  child: ListView.separated(
                    key: const ValueKey('list'),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, idx) {
                      final task = filtered[idx];
                      final priority = task.priority ?? TaskPriority.medium;
                      final priorityColor = _priorityColor(priority);
                      final priorityTextStyle = TextStyle(
                        color: priorityColor,
                        fontWeight: FontWeight.bold,
                      );
                      final cardContent = InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => showDialog(
                          context: context,
                          builder: (_) => TaskDialog(task: task),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Priority dot
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4, right: 8),
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: priorityColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                  // Title and trailing icon
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          task.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          task.description,
                                          style: const TextStyle(
                                            color: Colors.black87,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Complete icon
                                  IconButton(
                                    icon: Icon(
                                      task.isComplete ? Icons.check_circle : Icons.radio_button_unchecked,
                                      color: task.isComplete ? Colors.green : Colors.grey,
                                      size: 28,
                                    ),
                                    onPressed: () => taskProvider.toggleComplete(task.id),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    'Due: ${task.dueDate != null ? task.dueDate!.toLocal().toString().split(' ')[0] : 'N/A'}',
                                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    width: 4,
                                    height: 4,
                                    margin: const EdgeInsets.symmetric(horizontal: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[400],
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Priority: ',
                                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                                  ),
                                  Text(
                                    priority.name[0].toUpperCase() + priority.name.substring(1),
                                    style: priorityTextStyle.copyWith(fontSize: 14),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                        child: Dismissible(
                          key: ValueKey(task.id),
                          background: Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          direction: DismissDirection.startToEnd,
                          onDismissed: (_) => taskProvider.deleteTask(task.id),
                          child: cardContent,
                        ),
                      );
                    },
                  ),
                ),
        );
      },
    );
  }
} 