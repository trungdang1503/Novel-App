import '/models/tags.dart';
import 'pocketbase_client.dart';

class TagsService {
  Future<Tags?> addTag(String name) async {
    try {
      final pb = await getPocketbaseInstance();

      final tagModel = await pb.collection('tags').create(
        body: {'name': name},
      );

      return Tags.fromJson(tagModel.toJson());
    } catch (error) {
      print('Error adding tag: $error');
      return null;
    }
  }

  Future<List<Tags>> fetchTags() async {
    try {
      final pb = await getPocketbaseInstance();
      final tagModels = await pb.collection('tags').getFullList();
      return tagModels
          .map((tagModel) => Tags.fromJson(tagModel.toJson()))
          .toList();
    } catch (error) {
      print('Error fetching tags: $error');
      return [];
    }
  }

  Future<bool> deleteTag(String id) async {
    try {
      final pb = await getPocketbaseInstance();
      await pb.collection('tags').delete(id);
      return true;
    } catch (error) {
      print('Error deleting tag: $error');
      return false;
    }
  }

  getTags() {}
}
