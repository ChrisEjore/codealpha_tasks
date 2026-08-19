import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class KanbanScreen extends StatefulWidget {
  const KanbanScreen({Key? key}) : super(key: key);

  @override
  State<KanbanScreen> createState() => _KanbanScreenState();
}

class _KanbanScreenState extends State<KanbanScreen> {
  WebSocketChannel? _channel;
  bool _isConnected = false;
  String searchQuery = '';

  final Map<String, List<Map<String, dynamic>>> columns = {
    'To Do': [
      {
        'id': '101',
        'title': 'Add WebSockets',
        'subtitle': 'Connect Flutter frontend to Django Channels',
        'tag': 'Backend',
        'tagColor': Colors.purpleAccent,
        'date': 'Aug 20',
        'subtasks': [
          {'title': 'Configure ASGI entrypoint', 'done': true},
          {'title': 'Setup Consumer routing', 'done': true},
        ],
        'priority': 'High',
      },
      {
        'id': '102',
        'title': 'User Authentication',
        'subtitle': 'Implement JWT login and token refresh',
        'tag': 'Security',
        'tagColor': Colors.redAccent,
        'date': 'Aug 21',
        'subtasks': [
          {'title': 'JWT Middleware', 'done': false},
        ],
        'priority': 'Medium',
      },
    ],
    'In Progress': [
      {
        'id': '201',
        'title': 'Build Asana Clone UI',
        'subtitle': 'Design responsive dark mode Kanban cards',
        'tag': 'Frontend',
        'tagColor': Colors.cyanAccent,
        'date': 'Aug 19',
        'subtasks': [
          {'title': 'Horizontal board layout', 'done': true},
          {'title': 'Drag and drop handlers', 'done': true},
          {'title': 'Interactive task dialogs', 'done': true},
        ],
        'priority': 'High',
      },
    ],
    'Completed': [
      {
        'id': '301',
        'title': 'Setup Django Backend',
        'subtitle': 'Configure Daphne server and ASGI routing',
        'tag': 'DevOps',
        'tagColor': Colors.greenAccent,
        'date': 'Aug 15',
        'subtasks': [
          {'title': 'Install Daphne package', 'done': true},
          {'title': 'Test WebSocket handshake', 'done': true},
        ],
        'priority': 'High',
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
  }

  void _connectWebSocket() {
    try {
      _channel = WebSocketChannel.connect(
        Uri.parse('ws://127.0.0.1:8000/ws/kanban/'),
      );

      setState(() => _isConnected = true);

      _channel!.stream.listen(
            (message) {
          _handleIncomingWebSocketMessage(message);
        },
        onError: (error) {
          setState(() => _isConnected = false);
          debugPrint('WebSocket Error: $error');
        },
        onDone: () {
          setState(() => _isConnected = false);
          debugPrint('WebSocket Closed');
        },
      );
    } catch (e) {
      setState(() => _isConnected = false);
      debugPrint('Connection exception: $e');
    }
  }

  void _handleIncomingWebSocketMessage(dynamic message) {
    try {
      final data = jsonDecode(message);
      if (data['event'] == 'MOVE_TASK') {
        final String taskId = data['task_id'];
        final String targetColumn = data['new_status'];
        _moveTaskLocally(taskId, targetColumn);
      }
    } catch (e) {
      debugPrint('Parsing error: $e');
    }
  }

  void _moveTaskLocally(String taskId, String targetColumn) {
    if (!columns.containsKey(targetColumn)) return;

    Map<String, dynamic>? foundTask;
    String? sourceColumn;

    for (var entry in columns.entries) {
      final index = entry.value.indexWhere((task) => task['id'] == taskId);
      if (index != -1) {
        foundTask = entry.value[index];
        sourceColumn = entry.key;
        break;
      }
    }

    if (foundTask != null && sourceColumn != null && sourceColumn != targetColumn) {
      setState(() {
        columns[sourceColumn]!.removeWhere((task) => task['id'] == taskId);
        columns[targetColumn]!.add(foundTask!);
      });
    }
  }

  void _moveTask(Map<String, dynamic> task, String fromColumn, String toColumn) {
    if (fromColumn == toColumn) return;

    setState(() {
      columns[fromColumn]!.removeWhere((item) => item['id'] == task['id']);
      columns[toColumn]!.add(task);
    });

    _sendWebSocketUpdate(task['id']!, toColumn);
  }

  void _sendWebSocketUpdate(String taskId, String newStatus) {
    final payload = {
      'event': 'MOVE_TASK',
      'task_id': taskId,
      'new_status': newStatus,
      'timestamp': DateTime.now().toIso8601String(),
    };

    if (_channel != null && _isConnected) {
      _channel!.sink.add(jsonEncode(payload));
    }
    debugPrint('WebSocket Sent: ${jsonEncode(payload)}');
  }

  void _addNewTaskModal(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String selectedTag = 'Frontend';
    String selectedColumn = columns.keys.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1B26),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
                top: 24, left: 20, right: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Create Task', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(controller: titleController, style: const TextStyle(color: Colors.white), decoration: _inputDecoration('Task Title')),
                  const SizedBox(height: 12),
                  TextField(controller: descController, style: const TextStyle(color: Colors.white), decoration: _inputDecoration('Description')),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedTag,
                          dropdownColor: const Color(0xFF222436),
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration('Category'),
                          items: ['Frontend', 'Backend', 'DevOps', 'Security', 'Design']
                              .map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                          onChanged: (val) => setModalState(() => selectedTag = val!),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedColumn,
                          dropdownColor: const Color(0xFF222436),
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration('Column'),
                          items: columns.keys
                              .map((col) => DropdownMenuItem(value: col, child: Text(col))).toList(),
                          onChanged: (val) => setModalState(() => selectedColumn = val!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purpleAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        if (titleController.text.trim().isNotEmpty) {
                          setState(() {
                            columns[selectedColumn]!.add({
                              'id': DateTime.now().millisecondsSinceEpoch.toString(),
                              'title': titleController.text.trim(),
                              'subtitle': descController.text.trim(),
                              'tag': selectedTag,
                              'tagColor': _getTagColor(selectedTag),
                              'date': 'Today',
                              'subtasks': [],
                              'priority': 'Medium',
                            });
                          });
                          Navigator.pop(ctx);
                        }
                      },
                      child: const Text('Add Task to Board', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  Color _getTagColor(String tag) {
    switch (tag) {
      case 'Backend': return Colors.purpleAccent;
      case 'Frontend': return Colors.cyanAccent;
      case 'DevOps': return Colors.greenAccent;
      case 'Security': return Colors.redAccent;
      default: return Colors.orangeAccent;
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: const Color(0xFF222436),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
    );
  }

  @override
  void dispose() {
    _channel?.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12131C),
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Asana Workspace', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _isConnected ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  CircleAvatar(radius: 3, backgroundColor: _isConnected ? Colors.green : Colors.red),
                  const SizedBox(width: 4),
                  Text(
                    _isConnected ? 'Live' : 'Offline',
                    style: TextStyle(color: _isConnected ? Colors.green : Colors.red, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1A1B26),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              onChanged: (val) => setState(() => searchQuery = val.toLowerCase()),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search tasks by title or tag...',
                hintStyle: TextStyle(color: Colors.grey.shade600),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF12131C),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(16.0),
          children: columns.keys.map((title) => _buildKanbanColumn(title)).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addNewTaskModal(context),
        backgroundColor: Colors.purpleAccent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Task', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildKanbanColumn(String columnTitle) {
    final allTasks = columns[columnTitle] ?? [];
    final tasks = allTasks.where((t) {
      final title = (t['title'] as String).toLowerCase();
      final tag = (t['tag'] as String).toLowerCase();
      return title.contains(searchQuery) || tag.contains(searchQuery);
    }).toList();

    return DragTarget<Map<String, dynamic>>(
      onWillAcceptWithDetails: (details) => details.data['fromColumn'] != columnTitle,
      onAcceptWithDetails: (details) {
        final task = details.data['task'] as Map<String, dynamic>;
        final fromColumn = details.data['fromColumn'] as String;
        _moveTask(task, fromColumn, columnTitle);
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: 310.0,
          margin: const EdgeInsets.only(right: 16.0),
          decoration: BoxDecoration(
            color: candidateData.isNotEmpty ? const Color(0xFF252738) : const Color(0xFF1A1B26),
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: candidateData.isNotEmpty ? Colors.purpleAccent : const Color(0xFF2A2C3D),
              width: candidateData.isNotEmpty ? 2.0 : 1.0,
            ),
          ),
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(columnTitle, style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: const Color(0xFF252738), borderRadius: BorderRadius.circular(10)),
                        child: Text('${tasks.length}', style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14.0),
              Expanded(
                child: ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return LongPressDraggable<Map<String, dynamic>>(
                      data: {'task': task, 'fromColumn': columnTitle},
                      feedback: Material(
                        color: Colors.transparent,
                        child: SizedBox(width: 290.0, child: _buildTaskCard(task, columnTitle, isDragging: true)),
                      ),
                      childWhenDragging: Opacity(opacity: 0.25, child: _buildTaskCard(task, columnTitle)),
                      child: _buildTaskCard(task, columnTitle),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task, String currentColumn, {bool isDragging = false}) {
    final Color tagColor = (task['tagColor'] as Color?) ?? Colors.purpleAccent;
    final List subtasks = (task['subtasks'] as List?) ?? [];
    final int doneCount = subtasks.where((s) => s['done'] == true).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: const Color(0xFF222436),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: const Color(0xFF2D3047), width: 1.0),
        boxShadow: isDragging ? [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 12, spreadRadius: 2)] : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: tagColor.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
            child: Text(task['tag'] ?? 'General', style: TextStyle(color: tagColor, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 8),
          Text(task['title'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          if (task['subtitle'] != null && (task['subtitle'] as String).isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(task['subtitle']!, style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.playlist_add_check, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text('$doneCount/${subtasks.length}', style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                  const SizedBox(width: 12),
                  Icon(Icons.calendar_today_rounded, size: 12, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(task['date'] ?? 'Today', style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                ],
              ),
              const CircleAvatar(
                radius: 11,
                backgroundColor: Colors.purpleAccent,
                child: Text('E', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          )
        ],
      ),
    );
  }
}