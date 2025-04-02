import 'package:ct312h_project/ui/novels/edit_novel.dart';
import 'package:ct312h_project/ui/novels/novel_manager.dart';
import 'package:ct312h_project/ui/novels/novel_write_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../chapters/edit_chapter.dart';
import '../widgets/bottom_navigation.dart';

class Write extends StatefulWidget {
  static const routeName = '/write';

  const Write({super.key});

  @override
  State<Write> createState() => _WriteState();
}

class _WriteState extends State<Write> {
  late Future<void> _fetchUserNovels;

  @override
  void initState() {
    super.initState();
    _fetchUserNovels = context.read<NovelManager>().fetchUserNovels();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Write'),
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder(
        future: _fetchUserNovels,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return RefreshIndicator(
            onRefresh: () => context.read<NovelManager>().fetchUserNovels(),
            child: const NovelWriteList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Container(
                color: Colors.white,
                child: Wrap(
                  children: <Widget>[
                    ListTile(
                      leading:
                          Icon(Icons.my_library_books, color: Colors.orange),
                      title: Text('Create new novel'),
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          EditNovelScreen.routeName,
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.book, color: Colors.orange),
                      title: Text('Create new chapter'),
                      onTap: () {
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          builder: (BuildContext context) =>
                              CreateChapterDialog(),
                        );
                      },
                    ),
                    const SizedBox(height: 70),
                  ],
                ),
              );
            },
          );
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNav(currentIndex: 2),
    );
  }
}

class NovelWriteList extends StatelessWidget {
  const NovelWriteList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Use Consumer to retrieve and listen for
    // state change signals from ProductsManager
    return Consumer<NovelManager>(builder: (ctx, productsManager, child) {
      return ListView.builder(
        itemCount: productsManager.itemCount,
        itemBuilder: (ctx, i) => Column(
          children: [
            NovelWriteListTile(
              productsManager.items[i],
            ),
            const Divider(),
          ],
        ),
      );
    });
  }
}
