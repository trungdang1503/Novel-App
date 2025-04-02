import 'package:flutter/material.dart';

class AppBanner extends StatelessWidget {
  const AppBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 200.0),
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 94.0,
      ),
      child: Text(
        'Novel App',
        style: TextStyle(
          color: Theme.of(context).textTheme.titleLarge?.color,
          fontSize: 50,
          fontFamily: 'Anton',
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }
}
