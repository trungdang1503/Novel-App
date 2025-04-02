import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';
import '../models/novel.dart';
import 'pocketbase_client.dart';
import 'follow_service.dart';

class NovelsService {
  final FollowService _followService = FollowService();

  String _getFeaturedImageUrl(PocketBase pb, RecordModel productModel) {
    final featuredImageName = productModel.getStringValue('featuredImage');
    return pb.files.getUrl(productModel, featuredImageName).toString();
  }

  Future<Novel?> addNovel(Novel novel, List<String> tags) async {
    try {
      final pb = await getPocketbaseInstance();
      final userId = pb.authStore.record!.id;

      // Chuẩn bị dữ liệu gửi lên PocketBase
      final body = {
        ...novel.toJson(),
        'userId': userId,
        'tags': tags, // Lưu danh sách tag ID vào trường tags
      };

      // Gửi dữ liệu và upload ảnh nếu có
      final novelModel = await pb.collection('novels').create(
            body: body,
            files: novel.featuredImage != null
                ? [
                    http.MultipartFile.fromBytes(
                      'featuredImage',
                      await novel.featuredImage!.readAsBytes(),
                      filename: novel.featuredImage!.uri.pathSegments.last,
                    ),
                  ]
                : [],
          );

      // Trả về Novel mới với thông tin đã cập nhật
      return novel.copyWith(
        id: novelModel.id,
        imageUrl: _getFeaturedImageUrl(pb, novelModel),
      );
    } catch (error) {
      print('Error adding novel: $error');
      return null;
    }
  }

  Future<List<Novel>> fetchNovel({bool filteredByUser = false}) async {
    final List<Novel> novels = [];

    try {
      final pb = await getPocketbaseInstance();
      final userId = pb.authStore.record!.id;
      final novelModels = await pb.collection('novels').getFullList(
            filter: filteredByUser ? "userId='$userId'" : null,
          );

      for (final novelModel in novelModels) {
        // Lấy danh sách tag ids từ model
        final tagIds = List<String>.from(novelModel.data['tags'] ?? []);

        // Lấy tên tag từ bảng tags theo danh sách id
        final List<String> tagNames = [];
        for (final tagId in tagIds) {
          final tagRecord = await pb.collection('tags').getOne(tagId);
          tagNames.add(tagRecord.data['name'] ?? '');
        }

        novels.add(
          Novel.fromJson(
            novelModel.toJson()
              ..addAll({
                'imageUrl': _getFeaturedImageUrl(pb, novelModel),
                'tags': tagNames,
              }),
          ),
        );
      }
      return novels;
    } catch (error) {
      print('Error fetching novels: $error');
      return novels;
    }
  }

  Future<Novel?> updateNovel(Novel novel, List<String> tags) async {
    try {
      final pb = await getPocketbaseInstance();
      final body = {
        ...novel.toJson(),
        'tag': tags,
      };
      final novelModel = await pb.collection('novels').update(
            novel.id,
            body: body,
            files: novel.featuredImage != null
                ? [
                    await http.MultipartFile.fromBytes(
                      'featuredImage',
                      await novel.featuredImage!.readAsBytes(),
                      filename: novel.featuredImage!.uri.pathSegments.last,
                    ),
                  ]
                : [],
          );

      return novel.copyWith(
        imageUrl: novel.featuredImage != null
            ? _getFeaturedImageUrl(pb, novelModel)
            : novel.imageUrl,
      );
    } catch (error) {
      return null;
    }
  }

  Future<bool> deleteNovel(String id) async {
    try {
      final pb = await getPocketbaseInstance();
      await pb.collection('novels').delete(id);
      return true;
    } catch (error) {
      print('Error deleting novel: $error');
      return false;
    }
  }

  Future<List<Novel>> fetchFollowedNovels() async {
    try {
      final pb = await getPocketbaseInstance();
      final userId = pb.authStore.record!.id;
      final followedNovelIds = await _followService.getFollowedNovels(userId);

      final List<Novel> followedNovels = [];
      for (final novelId in followedNovelIds) {
        final novelModel = await pb.collection('novels').getOne(novelId);
        final tagIds = List<String>.from(novelModel.data['tags'] ?? []);
        final List<String> tagNames = [];
        for (final tagId in tagIds) {
          final tagRecord = await pb.collection('tags').getOne(tagId);
          tagNames.add(tagRecord.data['name'] ?? '');
        }
        followedNovels.add(
          Novel.fromJson(
            novelModel.toJson()
              ..addAll({
                'imageUrl': _getFeaturedImageUrl(pb, novelModel),
                'tags': tagNames,
              }),
          ),
        );
      }

      return followedNovels;
    } catch (e) {
      print('Error fetching followed novels: $e');
      return [];
    }
  }
}
