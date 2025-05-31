import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feedora_app/features/HomeScreen/domain/entities/FeedPost.dart';
import 'package:feedora_app/features/HomeScreen/presentation/widgets/build_feed_card.dart';
import 'package:feedora_app/features/HomeScreen/presentation/widgets/buildPostHighlights.dart';
import 'package:feedora_app/features/HomeScreen/presentation/widgets/buildTrendingTopics.dart';
import 'package:feedora_app/features/HomeScreen/presentation/widgets/buildCategoryChips.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BuildFeedPage extends StatelessWidget {
  final List<String> interests;
  final String? selectedCategory;
  final ScrollController scrollController;
  final List<String> trendingCategories;
  final Function(String?) onCategorySelected;
  final Future<void> Function() onRefresh;

  const BuildFeedPage({
    super.key,
    required this.interests,
    required this.selectedCategory,
    required this.scrollController,
    required this.trendingCategories,
    required this.onCategorySelected,
    required this.onRefresh,
  });

  Stream<QuerySnapshot> _getFeedStream() {
    final feedRef = FirebaseFirestore.instance.collection('feedPostsByAI');

    if (selectedCategory != null) {
      return feedRef.where('category', isEqualTo: selectedCategory).snapshots();
    }

    if (interests.isNotEmpty) {
      return feedRef
          .where('category', whereIn: interests.take(10).toList())
          .snapshots();
    }

    return feedRef.limit(10).snapshots(); // fallback
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _getFeedStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No feed available for your interests.'),
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

        final uid = FirebaseAuth.instance.currentUser!.uid;

        return FutureBuilder<DocumentSnapshot>(
          future:
              FirebaseFirestore.instance
                  .collection('feedUsersDora')
                  .doc(uid)
                  .get(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              return const Center(child: Text('User data not found.'));
            }

            final userData = userSnapshot.data!.data() as Map<String, dynamic>?;

            if (userData == null || !userData.containsKey('savedPosts')) {
              return const Center(child: Text('Saved posts field missing.'));
            }

            final savedPosts = List<String>.from(
              userSnapshot.data!.get('savedPosts') ?? [],
            );

            return RefreshIndicator(
              onRefresh: onRefresh,
              child: Column(
                children: [
                  BuildPostHighlights(posts: posts),
                  const SizedBox(height: 10),
                  BuildTrendingTopics(trendingCategories: trendingCategories),
                  const SizedBox(height: 10),
                  BuildCategoryChips(
                    interests: interests,
                    selectedCategory: selectedCategory,
                    onCategorySelected: onCategorySelected,
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        return BuildFeedCard(
                          post: post,
                          isLiked: post.likes.contains(uid),
                          isDisliked: post.dislikes.contains(uid),
                          isSaved: savedPosts.contains(post.postId),
                          onSave: () async {
                            final userRef = FirebaseFirestore.instance
                                .collection('feedUsersDora')
                                .doc(uid);
                            if (savedPosts.contains(post.postId)) {
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
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
