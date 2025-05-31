import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feedora_app/features/HomeScreen/domain/entities/FeedPost.dart';
import 'package:feedora_app/features/HomeScreen/presentation/widgets/build_feed_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BuildTrendingPage extends StatelessWidget {
  const BuildTrendingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String uid = FirebaseAuth.instance.currentUser!.uid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            '🔥 Trending',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: FutureBuilder<QuerySnapshot>(
            future:
                FirebaseFirestore.instance
                    .collection('feedPostsByAI')
                    .orderBy('likes', descending: true)
                    .limit(10)
                    .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text('No trending posts available.'),
                );
              }

              final posts =
                  snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return FeedPost(
                      postId: doc.id,
                      interest: data['category'] ?? 'General',
                      title: data['title'] ?? 'No title',
                      imageUrl: data['imageUrl'] ?? '',
                      sourceUrl: data['sourceUrl'] ?? '',
                      likes:
                          (data['likes'] is List)
                              ? List<String>.from(data['likes'])
                              : <String>[],
                      dislikes:
                          (data['dislikes'] is List)
                              ? List<String>.from(data['dislikes'])
                              : <String>[],
                    );
                  }).toList();

              // Nested FutureBuilder to fetch saved posts
              return FutureBuilder<DocumentSnapshot>(
                future:
                    FirebaseFirestore.instance
                        .collection('feedUsersDora')
                        .doc(uid)
                        .get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final savedPosts = List<String>.from(
                    userSnapshot.data!.get('savedPosts') ?? [],
                  );

                  return ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      final isSaved = savedPosts.contains(post.postId);

                      return BuildFeedCard(
                        post: post,
                        isLiked: post.likes.contains(uid),
                        isSaved: isSaved,
                        onLike: () async {
                          final postRef = FirebaseFirestore.instance
                              .collection('feedPostsByAI')
                              .doc(post.postId);
                          final userRef = FirebaseFirestore.instance
                              .collection('feedUsersDora')
                              .doc(uid);

                          if (post.likes.contains(uid)) {
                            await postRef.update({
                              'likes': FieldValue.arrayRemove([uid]),
                            });
                            await userRef.update({
                              'likedPosts': FieldValue.arrayRemove([
                                post.postId,
                              ]),
                            });
                          } else {
                            await postRef.update({
                              'likes': FieldValue.arrayUnion([uid]),
                              'dislikes': FieldValue.arrayRemove([
                                uid,
                              ]), // 🛠 fix here
                            });
                            await userRef.update({
                              'likedPosts': FieldValue.arrayUnion([
                                post.postId,
                              ]),
                            });
                          }
                        },

                        onSave: () async {
                          final userRef = FirebaseFirestore.instance
                              .collection('feedUsersDora')
                              .doc(uid);

                          if (isSaved) {
                            await userRef.update({
                              'savedPosts': FieldValue.arrayRemove([
                                post.postId,
                              ]),
                            });
                          } else {
                            await userRef.update({
                              'savedPosts': FieldValue.arrayUnion([
                                post.postId,
                              ]),
                            });
                          }
                        },
                        isDisliked: post.dislikes.contains(uid),
                        onDislike: () async {
                          final postRef = FirebaseFirestore.instance
                              .collection('feedPostsByAI')
                              .doc(post.postId);

                          if (post.dislikes.contains(uid)) {
                            await postRef.update({
                              'dislikes': FieldValue.arrayRemove([uid]),
                            });
                          } else {
                            await postRef.update({
                              'dislikes': FieldValue.arrayUnion([uid]),
                              'likes': FieldValue.arrayRemove([
                                uid,
                              ]), // optionally remove like
                            });
                          }
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
