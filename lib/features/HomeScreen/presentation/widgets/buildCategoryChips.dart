import 'package:flutter/material.dart';

class BuildCategoryChips extends StatelessWidget {
  final List<String> interests;
  final String? selectedCategory;
  final void Function(String?) onCategorySelected;

  const BuildCategoryChips({
    super.key,
    required this.interests,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final categories =
        interests.isEmpty
            ? ['General', 'Tech', 'Health', 'Science', 'Art', 'Travel']
            : interests;

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          for (final category in categories)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                label: Text(category),
                selected: selectedCategory == category,
                onSelected: (selected) {
                  onCategorySelected(selected ? category : null);
                },
              ),
            ),
          if (selectedCategory != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ActionChip(
                label: const Text("Clear Filter"),
                onPressed: () => onCategorySelected(null),
              ),
            ),
        ],
      ),
    );
  }
}
