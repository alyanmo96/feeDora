import 'package:flutter/material.dart';
import 'package:feedora_app/features/FeedDetailScreen/presentation/page/FeedDetailScreen.dart';
import 'package:feedora_app/features/HomeScreen/domain/entities/FeedPost.dart';

class BuildPostHighlights extends StatelessWidget {
  final List<FeedPost> posts;

  const BuildPostHighlights({super.key, required this.posts});

  @override
  Widget build(BuildContext context) {
    final highlights = posts.take(5).toList();

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: highlights.length,
        itemBuilder: (context, index) {
          final post = highlights[index];

          return GestureDetector(
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
            child: Container(
              width: 140,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(post.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              alignment: Alignment.bottomLeft,
              padding: const EdgeInsets.all(8),
              child: Text(
                post.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  backgroundColor: Colors.black45,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
