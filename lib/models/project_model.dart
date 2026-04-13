class ProjectModel {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final List<String> galleryUrls;
  final bool isHidden;
  final double avgRating;
  final int totalRatings;

  ProjectModel({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    this.galleryUrls = const [],
    required this.isHidden,
    required this.avgRating,
    required this.totalRatings,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['image_url'] as String?,
      galleryUrls: (json['gallery_urls'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      isHidden: json['is_hidden'] as bool? ?? false,
      avgRating: (json['avg_rating'] ?? 0).toDouble(),
      totalRatings: json['total_ratings'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'gallery_urls': galleryUrls,
      'is_hidden': isHidden,
      'avg_rating': avgRating,
      'total_ratings': totalRatings,
    };
  }
}
