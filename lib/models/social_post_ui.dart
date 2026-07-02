class SocialPostUi {
  final String id;
  final String userName;
  final String userPhotoUrl;
  final String imageUrl;
  final String caption;
  final DateTime createdAt;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final bool isSaved;

  const SocialPostUi({
    required this.id,
    required this.userName,
    required this.userPhotoUrl,
    required this.imageUrl,
    required this.caption,
    required this.createdAt,
    required this.likesCount,
    required this.commentsCount,
    this.isLiked = false,
    this.isSaved = false,
  });

  SocialPostUi copyWith({
    String? id,
    String? userName,
    String? userPhotoUrl,
    String? imageUrl,
    String? caption,
    DateTime? createdAt,
    int? likesCount,
    int? commentsCount,
    bool? isLiked,
    bool? isSaved,
  }) {
    return SocialPostUi(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      caption: caption ?? this.caption,
      createdAt: createdAt ?? this.createdAt,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}