class FeedPost {
  final String postId;
  final String interest;
  final String title;
  final String imageUrl;
  final String sourceUrl;
  final List<String> likes;
  final List<String> dislikes;

  FeedPost({
    required this.postId,
    required this.interest,
    required this.title,
    required this.imageUrl,
    required this.sourceUrl,
    required this.likes,
    required this.dislikes,
  });
}
