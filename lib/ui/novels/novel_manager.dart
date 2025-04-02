import 'package:flutter/foundation.dart';
import '../../models/novel.dart';
import '../../services/novels_service.dart';

class NovelManager with ChangeNotifier {
  final NovelsService _novelService = NovelsService();
  List<Novel> _items = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  int get itemCount => _items.length;

  List<Novel> get items => [..._items];

  Novel? findById(String id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (error) {
      return null;
    }
  }

  Future<void> addNovel(Novel novel, List<String> tags) async {
    final newNovel = await _novelService.addNovel(novel, tags);
    if (newNovel != null) {
      _items.add(newNovel);
      notifyListeners();
    }
  }

  Future<void> updateNovel(Novel novel, List<String> tags) async {
    final index = _items.indexWhere((item) => item.id == novel.id);
    if (index >= 0) {
      final updatedNovel = await _novelService.updateNovel(novel, tags);
      if (updatedNovel != null) {
        _items[index] = updatedNovel;
        notifyListeners();
      }
    }
  }

  Future<void> deleteNovel(String id) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0 && await _novelService.deleteNovel(id)) {
      _items.removeAt(index);
      notifyListeners();
    }
  }

  Future<void> fetchNovels() async {
    _isLoading = true;
    notifyListeners();

    try {
      _items = await _novelService.fetchNovel();
    } catch (e) {
      print("Lỗi tải dữ liệu: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUserNovels() async {
    _items = await _novelService.fetchNovel(
      filteredByUser: true,
    );
    notifyListeners();
  }

  Future<void> fetchFollowedNovels() async {
    _isLoading = true;
    notifyListeners();

    try {
      _items = await _novelService.fetchFollowedNovels();
    } catch (e) {
      print("Lỗi tải tiểu thuyết đã theo dõi: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
