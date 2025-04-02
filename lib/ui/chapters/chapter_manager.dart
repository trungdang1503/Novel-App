import 'package:flutter/foundation.dart';
import '../../models/chapter.dart';
import '../../services/chapters_service.dart';

class ChapterManager with ChangeNotifier {
  final ChaptersService _chapterService = ChaptersService();
  List<Chapter> _items = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  int get itemCount => _items.length;

  List<Chapter> get items => [..._items];

  Chapter? findById(String id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (error) {
      return null;
    }
  }

  Future<void> addChapter(Chapter chapter) async {
    try {
      final newChapter = await _chapterService.addChapter(chapter);
      if (newChapter != null) {
        _items.add(newChapter);
        notifyListeners();
      }
    } catch (e) {
      print("Lỗi thêm chương mới: $e");
    }
  }

  Future<void> fetchChapters(String novelId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _items = await _chapterService.fetchChapters(novelId);
      notifyListeners();
    } catch (e) {
      print("❗ Lỗi tải dữ liệu chương: $e");
      _items = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadChapterContent(String chapterId) async {
    try {
      final chapter = findById(chapterId);
      if (chapter == null) return;

      final content = await _chapterService.downloadChapterContent(chapterId);
      if (content != null) {
        updateChapterContent(chapter, content);
      } else {
        print("⚡ Không tải được nội dung chương.");
      }
    } catch (error) {
      print("❗ Lỗi khi tải nội dung chương: $error");
    }
  }

  Future<void> updateChapterContent(Chapter chapter, String newContent) async {
    try {
      final updatedChapter = chapter.copyWith(content: newContent);
      final index = _items.indexWhere((c) => c.id == chapter.id);
      if (index >= 0) {
        _items[index] = updatedChapter;
        notifyListeners();
      }
    } catch (error) {
      print("Lỗi cập nhật chương: $error");
    }
  }
}
