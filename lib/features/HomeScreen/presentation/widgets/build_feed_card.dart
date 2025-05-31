import 'package:feedora_app/features/CategoryFeedScreen/presentation/page/CategoryFeedScreen.dart';
import 'package:feedora_app/features/FeedDetailScreen/presentation/page/FeedDetailScreen.dart';
import 'package:feedora_app/features/HomeScreen/domain/entities/FeedPost.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class BuildFeedCard extends StatelessWidget {
  final FeedPost post;
  final bool isLiked;
  final VoidCallback onLike;
  final bool isDisliked;
  final VoidCallback onDislike;
  final bool isSaved;
  final VoidCallback onSave;

  const BuildFeedCard({
    super.key,
    required this.post,
    required this.isLiked,
    required this.onLike,
    required this.isDisliked,
    required this.onDislike,
    required this.isSaved,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => FeedDetailScreen(
                        postId: post.postId,
                        title: post.title,
                        interest: post.interest,
                        imageUrl: post.imageUrl,
                        likes: post.likes,
                      ),
                ),
              );
            },
            child: Image.network(post.imageUrl),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              post.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CategoryFeedScreen(category: post.interest),
                  ),
                );
              },
              child: Text(
                '#${post.interest}',
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const SizedBox(width: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder:
                    (child, animation) =>
                        ScaleTransition(scale: animation, child: child),
                child: Row(
                  children: [
                    IconButton(
                      key: ValueKey<bool>(isLiked),
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : Colors.grey,
                      ),
                      onPressed: onLike,
                    ),
                    IconButton(
                      icon: Icon(
                        isDisliked
                            ? Icons.thumb_down
                            : Icons.thumb_down_outlined,
                        color: isDisliked ? Colors.red : Colors.grey,
                      ),
                      onPressed: onDislike,
                    ),
                    Text('${post.dislikes.length}'),
                    // Share Button
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () {
                        // Customize the share message as needed.
                        Share.share(
                          "Check out this post: ${post.title}\nRead more at: ${post.sourceUrl}",
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        isSaved ? Icons.bookmark : Icons.bookmark_border,
                        color: isSaved ? Colors.blue : null,
                      ),
                      onPressed: onSave,
                    ),
                  ],
                ),
              ),
              Text('${post.likes.length}'),
            ],
          ),
        ],
      ),
    );
  }
}
