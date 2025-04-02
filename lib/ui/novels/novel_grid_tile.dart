import 'package:flutter/material.dart';
import 'package:ct312h_project/models/novel.dart';
import 'package:ct312h_project/ui/screens.dart';

class NovelGridTile extends StatelessWidget {
  const NovelGridTile(
    this.novel, {
    super.key,
  });

  final Novel novel;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        footer: NovelGridFooter(novel: novel),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              NovelDetail.routeName,
              arguments: novel.id,
            );
          },
          child: Image.network(
            novel.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class NovelGridFooter extends StatelessWidget {
  const NovelGridFooter({super.key, required this.novel});

  final Novel novel;

  @override
  Widget build(BuildContext context) {
    return GridTileBar(
      backgroundColor: Colors.white70,
      title: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          novel.title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: Colors.black),
        ),
      ),
    );
  }
}
