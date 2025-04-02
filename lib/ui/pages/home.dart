import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/bottom_navigation.dart';
import '../screens.dart';

class Home extends StatefulWidget {
  static const routeName = '/home';
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Future<void> _fetchNovels;

  @override
  void initState() {
    super.initState();
    _fetchNovels = context.read<NovelManager>().fetchNovels();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        automaticallyImplyLeading: false,
        surfaceTintColor: Colors.transparent,
      ),
      body: FutureBuilder(
        future: _fetchNovels,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return const NovelGrid();
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 0),
    );
  }
}
