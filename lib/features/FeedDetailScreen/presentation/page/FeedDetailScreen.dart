import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FeedDetailScreen extends StatelessWidget {
  final String postId;
  final String title;
  final String imageUrl;
  final String interest;
  final List<String> likes;

  const FeedDetailScreen({
    super.key,
    required this.postId,
    required this.title,
    required this.imageUrl,
    required this.interest,
    required this.likes,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('#$interest')),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance
                .collection('feedPostsByAI')
                .doc(postId)
                .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final content = data['content'] ?? 'No description available.';
          final sourceUrl = data['sourceUrl'] ?? '';
          final postLikes = List<String>.from(data['likes'] ?? []);
          final postDislikes = List<String>.from(data['dislikes'] ?? []);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(imageUrl),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(content, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: [
                    Chip(label: Text('#$interest')),
                    Chip(label: Text('👍 ${postLikes.length}')),
                    Chip(label: Text('👎 ${postDislikes.length}')),
                  ],
                ),
                const SizedBox(height: 20),
                if (sourceUrl.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: () async {
                      final uri = Uri.parse(sourceUrl);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Could not launch URL')),
                        );
                      }
                    },
                    icon: const Icon(Icons.link),
                    label: const Text('Read more from source'),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
