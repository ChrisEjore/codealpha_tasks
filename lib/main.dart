import 'package:flutter/material.dart';
import "package:http/http.dart" as http;


void main() {
  runApp(const BeatzApp());
}

class BeatzApp extends StatelessWidget {
  const BeatzApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beatz',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D0E15),
        cardColor: const Color(0xFF181928),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF007F), // Cyber Neon Pink
          secondary: Color(0xFFCCFF00), // Electric Acid Lime
        ),
      ),
      home: const BeatzFeedScreen(),
    );
  }
}

class BeatzFeedScreen extends StatefulWidget {
  const BeatzFeedScreen({super.key});

  @override
  State<BeatzFeedScreen> createState() => _BeatzFeedScreenState();
}

class _BeatzFeedScreenState extends State<BeatzFeedScreen> {
  final TextEditingController _postController = TextEditingController();

  // Local state representing feed items fetched from Django API
  List<Map<String, dynamic>> posts = [
    {
      'id': 1,
      'username': 'dj_pulse',
      'content': 'Dropping a new electro-funk track tonight! 🎧🔥',
      'likes': 12,
      'isLiked': false,
      'time': '10m ago'
    },
    {
      'id': 2,
      'username': 'synth_wave',
      'content': 'Looking for collaborators on an ambient synthwave EP. Hit me up!',
      'likes': 8,
      'isLiked': true,
      'time': '1h ago'
    },
  ];

  void _addPost() {
    if (_postController.text.trim().isEmpty) return;

    setState(() {
      posts.insert(0, {
        'id': DateTime.now().millisecondsSinceEpoch,
        'username': 'you',
        'content': _postController.text,
        'likes': 0,
        'isLiked': false,
        'time': 'Just now'
      });
      _postController.clear();
    });
  }

  void _toggleLike(int index) {
    setState(() {
      if (posts[index]['isLiked']) {
        posts[index]['likes']--;
        posts[index]['isLiked'] = false;
      } else {
        posts[index]['likes']++;
        posts[index]['isLiked'] = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0E15),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'BEATZ',
          style: TextStyle(
            color: Color(0xFFFF007F),
            fontWeight: FontWeight(30),
            fontSize: 28,
            letterSpacing: 3,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF181928),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFCCFF00).withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _postController,
                    maxLines: 2,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Drop your rhythm...',
                      hintStyle: TextStyle(color: Color(0xFFA0A5C0)),
                      border: InputBorder.none,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: _addPost,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF007F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('Post to Beatz', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Feed List
            Expanded(
              child: ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final item = posts[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF181928),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '@${item['username']}',
                          style: const TextStyle(
                            color: Color(0xFFCCFF00),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item['content'],
                          style: const TextStyle(color: Color(0xFFF3F4F8), fontSize: 15),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item['time'],
                              style: const TextStyle(color: Color(0xFFA0A5C0), fontSize: 12),
                            ),
                            InkWell(
                              onTap: () => _toggleLike(index),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: item['isLiked'] ? const Color(0xFFFF007F) : Colors.transparent,
                                  border: Border.all(color: const Color(0xFFFF007F)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.favorite,
                                      size: 16,
                                      color: item['isLiked'] ? Colors.white : const Color(0xFFFF007F),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${item['likes']}',
                                      style: TextStyle(
                                        color: item['isLiked'] ? Colors.white : const Color(0xFFFF007F),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
