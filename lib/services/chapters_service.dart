import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/chapter.dart';
import 'pocketbase_client.dart';

class ChaptersService {
  Future<List<Chapter>> fetchChapters(String novelId) async {
    try {
      final pb = await getPocketbaseInstance();
      final chapterModels = await pb.collection('chapters').getFullList(
            filter: "novel_id='$novelId'",
            sort: 'chapterNumber',
          );

      if (chapterModels.isEmpty) throw Exception("Không có chương nào!");

      // Cập nhật lượt xem của tiểu thuyết
      await _updateNovelViews(novelId);

      List<Chapter> chapters = [];
      for (var chapterModel in chapterModels) {
        String? content;
        final contentFileName = chapterModel.getStringValue('content');

        if (contentFileName.isNotEmpty) {
          try {
            // Lấy URL nội dung chương
            final contentUrl =
                pb.files.getUrl(chapterModel, contentFileName).toString();
            final response = await http.get(Uri.parse(contentUrl));

            if (response.statusCode == 200) {
              content = utf8.decode(response.bodyBytes);
            } else {
              content = "Lỗi tải nội dung chương";
            }
          } catch (e) {
            content = "Không thể tải nội dung chương";
          }
        } else {
          content = "Chương này chưa có nội dung.";
        }

        chapters.add(
          Chapter.fromJson(
            chapterModel.toJson()..addAll({'content': content}),
          ),
        );
      }

      return chapters;
    } catch (error) {
      print('⚡ Lỗi khi lấy danh sách chương: $error');
      rethrow;
    }
  }

  // Hàm cập nhật lượt xem
  Future<void> _updateNovelViews(String novelId) async {
    try {
      final pb = await getPocketbaseInstance();
      final novel = await pb.collection('novels').getOne(novelId);
      final updatedViews = (novel.data['view'] ?? 0) + 1;

      await pb.collection('novels').update(
        novelId,
        body: {'view': updatedViews},
      );
      print("📈 Lượt xem cập nhật: $updatedViews");
    } catch (error) {
      print("❗ Lỗi khi cập nhật lượt xem: $error");
    }
  }

  Future<Chapter?> addChapter(Chapter chapter) async {
    try {
      final pb = await getPocketbaseInstance();
      final body = chapter.toJson();
      List<http.MultipartFile> files = [];

      if (chapter.content != null && chapter.content!.isNotEmpty) {
        final fileName = 'chapter_${chapter.chapterNumber}.txt';
        final fileBytes = utf8.encode(chapter.content!);

        files.add(
          http.MultipartFile.fromBytes(
            'content',
            fileBytes,
            filename: fileName,
          ),
        );
      }

      final chapterModel = await pb.collection('chapters').create(
            body: body,
            files: files,
          );

      final novel = await pb.collection('novels').getOne(chapter.novelId);
      final updatedChapterCount = (novel.data['chapter'] ?? 0) + 1;

      await pb.collection('novels').update(
        chapter.novelId,
        body: {'chapter': updatedChapterCount},
      );

      return chapter.copyWith(
        id: chapterModel.id,
        created: DateTime.parse(chapterModel.data['created']),
        updated: DateTime.parse(chapterModel.data['updated']),
      );
    } catch (error) {
      print('Lỗi thêm chương mới: $error');
      return null;
    }
  }

  Future<String?> downloadChapterContent(String chapterId) async {
    try {
      final pb = await getPocketbaseInstance();
      final chapter = await pb.collection('chapters').getOne(chapterId);

      final contentFileName = chapter.getStringValue('content');
      if (contentFileName.isEmpty) return "Chương này chưa có nội dung.";

      final contentUrl = pb.files.getUrl(chapter, contentFileName).toString();
      final response = await http.get(Uri.parse(contentUrl));

      if (response.statusCode == 200) {
        return utf8.decode(response.bodyBytes);
      } else {
        print("❗ Lỗi khi tải nội dung chương: ${response.statusCode}");
        return "Lỗi tải nội dung chương.";
      }
    } catch (e) {
      print("⚡ Lỗi khi kết nối hoặc tải chương: $e");
      return "Không thể tải nội dung chương.";
    }
  }
}
