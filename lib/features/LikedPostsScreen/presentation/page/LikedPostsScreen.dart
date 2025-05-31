import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feedora_app/features/FeedDetailScreen/presentation/page/FeedDetailScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LikedPostsScreen extends StatefulWidget {
  // ignore: use_super_parameters
  const LikedPostsScreen({Key? key}) : super(key: key);

  @override
  State<LikedPostsScreen> createState() => _LikedPostsScreenState();
}

class _LikedPostsScreenState extends State<LikedPostsScreen> {
  List<_FeedPost> _likedPosts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLikedPosts();
  }

  Future<void> _loadLikedPosts() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    try {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('feedUsersDora')
              .doc(uid)
              .get();
      final List<dynamic> likedPostIds = userDoc.data()?['likedPosts'] ?? [];

      if (likedPostIds.isEmpty) {
        setState(() {
          _likedPosts = [];
          _loading = false;
        });
        return;
      }

      final List<_FeedPost> posts = [];

      for (String postId in likedPostIds) {
        final doc =
            await FirebaseFirestore.instance
                .collection('feedPostsByAI')
                .doc(postId)
                .get();
        if (doc.exists) {
          final data = doc.data()!;
          posts.add(
            _FeedPost(
              postId: doc.id,
              interest: data['category'] ?? 'Unknown',
              title: data['title'] ?? 'No title',
              imageUrl: data['imageUrl'] ?? '',
            ),
          );
        }
      }

      setState(() {
        _likedPosts = posts;
        _loading = false;
      });
    } catch (e) {
      print('Error loading liked posts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Liked Posts')),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _likedPosts.isEmpty
              ? const Center(child: Text('You haven\'t liked any posts yet.'))
              : ListView.builder(
                itemCount: _likedPosts.length,
                itemBuilder: (context, index) {
                  final post = _likedPosts[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => FeedDetailScreen(
                                postId: post.postId,
                                title: post.title,
                                imageUrl: post.imageUrl,
                                interest: post.interest,
                                likes: const [],
                              ),
                        ),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.network(post.imageUrl),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              post.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: Text("#${post.interest}"),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}

class _FeedPost {
  final String postId;
  final String interest;
  final String title;
  final String imageUrl;

  _FeedPost({
    required this.postId,
    required this.interest,
    required this.title,
    required this.imageUrl,
  });
}
