import 'package:flutter/material.dart';
import '../../models/novel.dart';

class NovelReading extends StatefulWidget {
  static const routeName = '/novel_reading';
  final Novel novel;
  const NovelReading({super.key, required this.novel});

  @override
  _NovelReadingState createState() => _NovelReadingState();
}

class _NovelReadingState extends State<NovelReading> {
  double _fontSize = 18.0;
  double _lineHeight = 1.5;
  Color _backgroundColor = Colors.white;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  List<int> _searchResults = [];

  void _openSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Cài đặt hiển thị",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Slider(
                value: _fontSize,
                min: 12.0,
                max: 30.0,
                label: "Cỡ chữ: ${_fontSize.toInt()}",
                onChanged: (value) => setState(() => _fontSize = value),
              ),
              Slider(
                value: _lineHeight,
                min: 1.0,
                max: 2.5,
                label: "Dãn dòng: ${_lineHeight.toStringAsFixed(1)}",
                onChanged: (value) => setState(() => _lineHeight = value),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildColorOption(Colors.white),
                  _buildColorOption(Colors.black87),
                  _buildColorOption(Colors.brown[200]!),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildColorOption(Color color) {
    return GestureDetector(
      onTap: () => setState(() => _backgroundColor = color),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(),
        ),
      ),
    );
  }

  void _searchText(String query) {
    setState(() {
      _searchResults.clear();
      int index = widget.novel.description.indexOf(query);
      while (index != -1) {
        _searchResults.add(index);
        index = widget.novel.description.indexOf(query, index + 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.novel.title),
        actions: [
          IconButton(
              icon: const Icon(Icons.format_size), onPressed: _openSettings),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Tìm kiếm"),
                    content: TextField(
                      controller: _searchController,
                      decoration:
                          const InputDecoration(hintText: "Nhập từ khóa"),
                      onSubmitted: (query) {
                        _searchText(query);
                        Navigator.of(context).pop();
                      },
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text("Hủy"),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Container(
        color: _backgroundColor,
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Text(
            widget.novel.description,
            style: TextStyle(
              fontSize: _fontSize,
              height: _lineHeight,
              color: _backgroundColor == Colors.black87
                  ? Colors.white
                  : Colors.black,
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, size: 32),
              onPressed: () {},
            ),
            Expanded(
              child: Slider(
                value: 0.5,
                min: 0.0,
                max: 1.0,
                onChanged: (value) {},
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, size: 32),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
