import '../models/social_post_ui.dart';

class SocialMockService {
  static final List<SocialPostUi> _posts = [
    SocialPostUi(
      id: '1',
      userName: 'Lina',
      userPhotoUrl: 'https://i.pravatar.cc/150?img=5',
      imageUrl: 'https://picsum.photos/700/900?random=11',
      caption: 'Amazing place in Morocco! #travel',
      createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
      likesCount: 24,
      commentsCount: 4,
    ),
    SocialPostUi(
      id: '2',
      userName: 'Yassine',
      userPhotoUrl: 'https://i.pravatar.cc/150?img=8',
      imageUrl: 'https://picsum.photos/700/900?random=12',
      caption: 'Sunset vibes 🌅',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      likesCount: 55,
      commentsCount: 9,
    ),
  ];

  static List<SocialPostUi> getPosts() => List<SocialPostUi>.from(_posts);
}