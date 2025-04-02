import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/bottom_navigation.dart';
import '../screens.dart';

class Library extends StatefulWidget {
  static const routeName = '/libray';
  const Library({super.key});

  @override
  State<Library> createState() => _LibraryState();
}

class _LibraryState extends State<Library> {
  late Future<void> _fetchNovelWithFollowStatus;

  @override
  void initState() {
    super.initState();
    _fetchNovelWithFollowStatus =
        context.read<NovelManager>().fetchFollowedNovels();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Libary'),
        automaticallyImplyLeading: false,
        surfaceTintColor: Colors.transparent,
      ),
      body: FutureBuilder(
        future: _fetchNovelWithFollowStatus,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return const NovelGrid();
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: 3,
      ),
    );
  }
}
