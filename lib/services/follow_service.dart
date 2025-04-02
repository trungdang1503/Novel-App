import 'pocketbase_client.dart';

class FollowService {
  Future<bool> followNovel(String novelId) async {
    try {
      final pb = await getPocketbaseInstance();
      final userId = pb.authStore.record!.id;
      await pb.collection('follows').create(body: {
        'user_id': userId,
        'novel_id': novelId,
      });
      return true;
    } catch (e) {
      print('Error following novel: $e');
      return false;
    }
  }

  Future<bool> unfollowNovel(String followId) async {
    try {
      final pb = await getPocketbaseInstance();
      await pb.collection('follows').delete(followId);
      return true;
    } catch (e) {
      print('Error unfollowing novel: $e');
      return false;
    }
  }

  Future<List<String>> getFollowedNovels(String userId) async {
    try {
      final pb = await getPocketbaseInstance();
      final result = await pb.collection('follows').getList(
            filter: 'user_id = "$userId"',
          );

      return result.items
          .map((item) => item.data['novel_id'] as String)
          .toList();
    } catch (e) {
      print('Error fetching followed novels: $e');
      return [];
    }
  }

  Future<bool> isFollowing(String novelId) async {
    try {
      final pb = await getPocketbaseInstance();
      final userId = pb.authStore.record!.id;
      final result = await pb.collection('follows').getList(
            filter: 'user_id = "$userId" && novel_id = "$novelId"',
            perPage: 1,
          );
      return result.items.isNotEmpty;
    } catch (e) {
      print('Error checking follow status: $e');
      return false;
    }
  }

  Future<String?> getFollowId(String novelId) async {
    try {
      final pb = await getPocketbaseInstance();
      final userId = pb.authStore.record!.id;
      final result = await pb.collection('follows').getList(
            filter: 'user_id = "$userId" && novel_id = "$novelId"',
            perPage: 1,
          );

      if (result.items.isNotEmpty) {
        return result.items.first.id; // Trả về followId thay vì true/false
      }
      return null;
    } catch (e) {
      print('Error getting follow ID: $e');
      return null;
    }
  }
}
