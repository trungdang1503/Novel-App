import '/models/novel.dart';
import 'package:flutter/material.dart';
import '../chapters/chapter_read.dart';
import '../../services/follow_service.dart';

class NovelDetail extends StatefulWidget {
  static const routeName = '/novel_detail';

  final Novel novel;
  const NovelDetail(this.novel, {super.key});

  @override
  _NovelDetailState createState() => _NovelDetailState();
}

class _NovelDetailState extends State<NovelDetail> {
  bool isFollowing = false;
  final FollowService _followService = FollowService();

  @override
  void initState() {
    super.initState();
    _checkFollowStatus();
  }

  Future<void> _checkFollowStatus() async {
    bool following = await _followService.isFollowing(widget.novel.id);
    setState(() => isFollowing = following);
  }

  Future<void> _toggleFollow() async {
    if (isFollowing) {
      final followId = await _followService.getFollowId(widget.novel.id);
      if (followId != null) {
        bool result = await _followService.unfollowNovel(followId);
        if (result) setState(() => isFollowing = false);
      }
    } else {
      bool result = await _followService.followNovel(widget.novel.id);
      if (result) setState(() => isFollowing = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final novel = widget.novel;

    // Check if the novel does not exist
    if (novel.id.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Novel does not exist!')),
        body: const Center(
          child: Text(
            'Novel not found!',
            style: TextStyle(color: Colors.red, fontSize: 18),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Novel detail')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display cover image from URL
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: novel.imageUrl.isNotEmpty
                    ? Image.network(
                        novel.imageUrl,
                        width: 180,
                        height: 270,
                        fit: BoxFit.cover,
                      )
                    : const Icon(
                        Icons.book,
                        size: 150,
                        color: Colors.white70,
                      ),
              ),
            ),

            const SizedBox(height: 20),
            // Display title
            Text(
              novel.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 10),
            // Display tags
            _buildTagList(novel.tags),
            _buildInfoRow(Icons.remove_red_eye, "View", novel.view.toString()),
            _buildInfoRow(Icons.book, "Chapters", novel.chapter.toString()),
            _buildInfoRow(Icons.date_range, "Created", novel.created),
            _buildInfoRow(Icons.update, "Updated", novel.updated),

            const Divider(color: Colors.white70),
            _buildActionButtons(),
            const SizedBox(height: 10),
            _buildContinueReadButton(),

            const SizedBox(height: 20),
            const Text(
              "Description",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 5),
            Text(
              novel.description,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              "Chapters list",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            _buildChapterList(novel.chapter),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 5),
        Text("$label: ",
            style: const TextStyle(fontSize: 16, color: Colors.white70)),
        Text(value,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
      ],
    );
  }

  Widget _buildTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        tag,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }

  Widget _buildTagList(List<String> tags) {
    if (tags.isEmpty) {
      return const Text(
        "No tags available",
        style: TextStyle(color: Colors.white70, fontSize: 14),
      );
    }
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: tags
          .where((tag) => tag.isNotEmpty)
          .map((tag) => _buildTag(tag))
          .toList(),
    );
  }

  Widget _buildChapterList(int chapters) {
    return Column(
      children: List.generate(
        chapters,
        (index) {
          int chapterNumber = chapters - index; // Đảo ngược danh sách chương
          return ListTile(
            title: Text("Chapter $chapterNumber",
                style: const TextStyle(color: Colors.white)),
            subtitle: const Text("Created: Updating...",
                style: TextStyle(color: Colors.white70)),
            trailing: const Icon(Icons.arrow_forward_ios,
                color: Colors.white70, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChapterRead(
                    novel: widget.novel,
                    chapterNumber: chapterNumber,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // Điều hướng tới Chapter 1
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChapterRead(
                    novel: widget.novel,
                    chapterNumber: 1,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            icon: const Icon(Icons.menu_book, color: Colors.white),
            label:
                const Text("Read now", style: TextStyle(color: Colors.white)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _toggleFollow,
            style: ElevatedButton.styleFrom(
                backgroundColor: isFollowing ? Colors.orange : Colors.red),
            icon: Icon(isFollowing ? Icons.check : Icons.add,
                color: Colors.white),
            label: Text(isFollowing ? "Following" : "Follow",
                style: const TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _buildContinueReadButton() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            icon: const Icon(Icons.send, color: Colors.white),
            label: const Text("Continue read",
                style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}
