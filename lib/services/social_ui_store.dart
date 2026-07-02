import '../models/social_post_ui.dart';
import 'social_mock_service.dart';

class SocialUiStore {
  SocialUiStore._();
  static final SocialUiStore instance = SocialUiStore._();

  final List<SocialPostUi> _posts = SocialMockService.getPosts();

  List<SocialPostUi> get allPosts => List<SocialPostUi>.from(_posts);

  List<SocialPostUi> get savedPosts =>
      _posts.where((p) => p.isSaved).toList();

  void toggleSave(String postId) {
    final i = _posts.indexWhere((p) => p.id == postId);
    if (i == -1) return;
    final p = _posts[i];
    _posts[i] = p.copyWith(isSaved: !p.isSaved);
  }

  void replacePost(SocialPostUi post) {
    final i = _posts.indexWhere((p) => p.id == post.id);
    if (i == -1) return;
    _posts[i] = post;
  }

  void toggleLike(String postId) {
    final i = _posts.indexWhere((p) => p.id == postId);
    if (i == -1) return;
    final p = _posts[i];
    final nextLiked = !p.isLiked;
    _posts[i] = p.copyWith(
      isLiked: nextLiked,
      likesCount: nextLiked ? p.likesCount + 1 : p.likesCount - 1,
    );
  }
}