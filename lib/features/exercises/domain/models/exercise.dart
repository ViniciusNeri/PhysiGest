class Exercise {
  final String id;
  final String title;
  final String description;
  final String videoUrl;
  final String thumbnailUrl;
  final String category;
  final String recommendedRepetitions;

  const Exercise({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.category,
    required this.recommendedRepetitions,
  });

  Exercise copyWith({
    String? id,
    String? title,
    String? description,
    String? videoUrl,
    String? thumbnailUrl,
    String? category,
    String? recommendedRepetitions,
  }) {
    return Exercise(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      category: category ?? this.category,
      recommendedRepetitions:
          recommendedRepetitions ?? this.recommendedRepetitions,
    );
  }
}
