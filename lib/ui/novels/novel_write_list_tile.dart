import 'package:ct312h_project/models/novel.dart';
import 'package:ct312h_project/ui/screens.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NovelWriteListTile extends StatelessWidget {
  final Novel novel;

  const NovelWriteListTile(this.novel, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(novel.title),
      textColor: Colors.white,
      leading: CircleAvatar(
        backgroundImage: NetworkImage(novel.imageUrl),
      ),
      trailing: SizedBox(
        width: 100,
        child: Row(
          children: <Widget>[
            // Bắt sự kiện cho nút edit
            EditWriteListButton(
              onPressed: () {
                // Navigate to EditProductScreen
                Navigator.of(context).pushNamed(
                  EditNovelScreen.routeName,
                  arguments: novel.id,
                );
              },
            ),
            // Bắt sự kiện cho nút delete
            DeleleWriteListButton(
              onPressed: () {
                // Read ProductsManager to delete a product
                context.read<NovelManager>().deleteNovel(novel.id);
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Novel deleted',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class DeleleWriteListButton extends StatelessWidget {
  const DeleleWriteListButton({
    super.key,
    this.onPressed,
  });

  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.delete),
      onPressed: onPressed,
      color: Theme.of(context).colorScheme.error,
    );
  }
}

class EditWriteListButton extends StatelessWidget {
  const EditWriteListButton({
    super.key,
    this.onPressed,
  });

  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.edit),
      onPressed: onPressed,
      color: Theme.of(context).colorScheme.primary,
    );
  }
}
