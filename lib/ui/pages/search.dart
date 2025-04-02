import 'package:ct312h_project/ui/widgets/bottom_navigation.dart';
import 'package:flutter/material.dart';
import '../../models/novel.dart';
import '../novels/novel_manager.dart';
import '../novels/novel_detail.dart';

class Search extends StatefulWidget {
  static const routeName = '/search';

  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final TextEditingController _searchController = TextEditingController();
  List<Novel> _filteredNovels = [];
  final NovelManager _novelManager = NovelManager();
  String _searchTerm = '';
  List<String> _allTags = [];
  String? _selectedTag;

  @override
  void initState() {
    super.initState();
    _loadNovels();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadNovels() async {
    await _novelManager.fetchNovels();
    setState(() {
      _filteredNovels = _novelManager.items;
      _allTags =
          _novelManager.items.expand((novel) => novel.tags).toSet().toList();
    });
  }

  void _onSearchChanged() {
    setState(() {
      _searchTerm = _searchController.text.toLowerCase();
      _applyFilters();
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredNovels = _novelManager.items.where((novel) {
        final matchesSearch = novel.title.toLowerCase().contains(_searchTerm) ||
            novel.description.toLowerCase().contains(_searchTerm) ||
            novel.tags.any((tag) => tag.toLowerCase().contains(_searchTerm));

        final matchesTag =
            _selectedTag == null || novel.tags.contains(_selectedTag);

        return matchesSearch && matchesTag;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Enter novel name, description or tag',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          if (_allTags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButton<String?>(
                hint: const Text('Select tag'),
                value: _selectedTag,
                isExpanded: true,
                onChanged: (value) {
                  setState(() {
                    _selectedTag = value;
                    _applyFilters();
                  });
                },
                items: [
                  const DropdownMenuItem(value: null, child: Text('All tag')),
                  ..._allTags.map((tag) => DropdownMenuItem(
                        value: tag,
                        child: Text(tag),
                      ))
                ],
              ),
            ),
          Expanded(
            child: _filteredNovels.isEmpty && _searchTerm.isNotEmpty
                ? const Center(
                    child:
                        Text('Dont find any novels matching the search term'),
                  )
                : ListView.builder(
                    itemCount: _filteredNovels.length,
                    itemBuilder: (context, index) {
                      final novel = _filteredNovels[index];
                      return ListTile(
                        leading: novel.hasFeaturedImage()
                            ? Image.network(
                                novel.imageUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.book),
                        title: Text(novel.title,
                            style: TextStyle(color: Colors.white)),
                        subtitle: Text(novel.description,
                            style: TextStyle(color: Colors.white)),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            NovelDetail.routeName,
                            arguments: novel.id,
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: 1,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
