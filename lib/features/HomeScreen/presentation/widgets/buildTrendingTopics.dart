import 'package:flutter/material.dart';
import 'package:feedora_app/features/CategoryFeedScreen/presentation/page/CategoryFeedScreen.dart';

class BuildTrendingTopics extends StatelessWidget {
  final List<String> trendingCategories;

  const BuildTrendingTopics({super.key, required this.trendingCategories});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: trendingCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final category = trendingCategories[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CategoryFeedScreen(category: category),
                ),
              );
            },
            child: Chip(
              label: Text('#$category'),
              backgroundColor: Colors.blue.shade100,
            ),
          );
        },
      ),
    );
  }
}
