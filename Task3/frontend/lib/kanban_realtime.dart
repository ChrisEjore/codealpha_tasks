import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class RealtimeKanbanBoard extends StatefulWidget {
  final String projectId;

  RealtimeKanbanBoard({required this.projectId});

  @override
  _RealtimeKanbanBoardState createState() => _RealtimeKanbanBoardState();
}

class _RealtimeKanbanBoardState extends State<RealtimeKanbanBoard> {
  late final WebSocketChannel _channel;

  @override
  void initState() {
    super.initState();
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://127.0.0.1:8000/ws/projects/${widget.projectId}/'),
    );
    _channel.stream.listen((message) {
      final data = jsonDecode(message);
      _handleIncomingRealtimeUpdate(data);
    });
  }

  void _handleIncomingRealtimeUpdate(Map<String, dynamic> data) {
    String type = data['type'];

    if (type == 'TASK_MOVED') {
      setState(() {
        // Update local task state when another user moves a card
      });
      _showInAppNotification("Task '${data['task_title']}' moved to ${data['new_status']}");
    } else if (type == 'NEW_COMMENT') {
      _showInAppNotification("New comment from ${data['author']}: ${data['text']}");
    }
  }

  void _showInAppNotification(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.notifications_active, color: Colors.white),
            SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.blueAccent,
        duration: Duration(seconds: 4),
      ),
    );
  }

  void _broadcastTaskMove(String taskId, String taskTitle, String newStatus) {
    final payload = jsonEncode({
      'type': 'TASK_MOVED',
      'task_id': taskId,
      'task_title': taskTitle,
      'new_status': newStatus,
    });
    _channel.sink.add(jsonEncode(payload));
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Live Project Board')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _broadcastTaskMove('12', 'Setup PostgreSQL', 'DONE'),
          child: Text('Simulate Drag-and-Drop Task Move'),
        ),
      ),
    );
  }
}