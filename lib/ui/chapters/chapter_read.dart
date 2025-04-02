import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/novel.dart';
import '../../models/chapter.dart';
import 'chapter_manager.dart';

class ChapterRead extends StatefulWidget {
  final Novel novel;
  final int chapterNumber;

  const ChapterRead({
    super.key,
    required this.novel,
    required this.chapterNumber,
  });

  @override
  State<ChapterRead> createState() => _ChapterReadState();
}

class _ChapterReadState extends State<ChapterRead> {
  Chapter? currentChapter;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChapter(widget.chapterNumber);
  }

  Future<void> _loadChapter(int chapterNumber) async {
    setState(() => isLoading = true);

    try {
      final chapterManager =
          Provider.of<ChapterManager>(context, listen: false);

      // Tìm chapter theo novelId và chapterNumber
      currentChapter = chapterManager.items.firstWhere(
        (chapter) =>
            chapter.novelId == widget.novel.id &&
            chapter.chapterNumber == chapterNumber,
        orElse: () => Chapter(
          id: '',
          title: '',
          content: null,
          contentUrl: null,
          novelId: widget.novel.id,
          chapterNumber: chapterNumber,
          created: DateTime.now(),
          updated: DateTime.now(),
        ),
      );

      if (currentChapter!.id.isEmpty) {
        // Nếu không tìm thấy, tải danh sách chương
        await chapterManager.fetchChapters(widget.novel.id);
        currentChapter = chapterManager.items.firstWhere(
          (chapter) =>
              chapter.novelId == widget.novel.id &&
              chapter.chapterNumber == chapterNumber,
          orElse: () => currentChapter!,
        );
      }

      // Nếu chương có id nhưng chưa có nội dung, tải nội dung
      if (currentChapter!.id.isNotEmpty && currentChapter!.content == null) {
        await chapterManager.loadChapterContent(currentChapter!.id);
        setState(() {
          currentChapter = chapterManager.findById(currentChapter!.id);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error when loading chapter: $e")),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _navigateChapter(int newChapterNumber) {
    if (newChapterNumber > 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChapterRead(
            novel: widget.novel,
            chapterNumber: newChapterNumber,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalChapters = widget.novel.chapter;

    return Scaffold(
      appBar: AppBar(
        title: Text('Chapter ${widget.chapterNumber}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadChapter(widget.chapterNumber),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : currentChapter == null
              ? const Center(child: Text("Chapter not found."))
              : Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SingleChildScrollView(
                          child: Text(
                            currentChapter!.content ??
                                "Chapter don't have content.",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: widget.chapterNumber > 1
                              ? () => _navigateChapter(widget.chapterNumber - 1)
                              : null,
                          child: const Text('← Previous chapter'),
                        ),
                        ElevatedButton(
                          onPressed: widget.chapterNumber < totalChapters
                              ? () => _navigateChapter(widget.chapterNumber + 1)
                              : null,
                          child: const Text('Next chapter →'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
    );
  }
}
