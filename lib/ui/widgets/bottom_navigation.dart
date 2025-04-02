import 'package:flutter/material.dart';
import '../screens.dart';
import '../pages/home.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;

  const BottomNav({super.key, required this.currentIndex});

  void _onItemTapped(BuildContext context, int index) {
    final pages = [Home(), const Search(), Write(), Library(), Profile()];

    if (index != currentIndex) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => pages[index],
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        BottomNavigationBarItem(icon: Icon(Icons.edit), label: 'Write'),
        BottomNavigationBarItem(
            icon: Icon(Icons.my_library_books), label: 'Library'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
      onTap: (index) => _onItemTapped(context, index),
    );
  }
}
