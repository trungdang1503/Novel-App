import '/models/novel.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens.dart';

class NovelGrid extends StatelessWidget {
  const NovelGrid({super.key});

  @override
  Widget build(BuildContext context) {
    // Read List<Product> from ProductsManager
    final novels = context.select<NovelManager, List<Novel>>(
        (novelManager) => novelManager.items);

    return GridView.builder(
      padding: const EdgeInsets.all(10.0),
      itemCount: novels.length,
      itemBuilder: (ctx, i) => NovelGridTile(novels[i]),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
    );
  }
}
