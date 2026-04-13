class CommentModel {
  final String id;
  final String projectId;
  final String authorName;
  final String authorEmail;
  final String content;
  final int rating;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.projectId,
    required this.authorName,
    required this.authorEmail,
    required this.content,
    required this.rating,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String,
      projectId: json['project_id'] as String,
      authorName: json['author_name'] as String? ?? 'Anonymous',
      authorEmail: json['author_email'] as String? ?? '',
      content: json['content'] as String,
      rating: json['rating'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'author_name': authorName,
      'author_email': authorEmail,
      'content': content,
      'rating': rating,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
