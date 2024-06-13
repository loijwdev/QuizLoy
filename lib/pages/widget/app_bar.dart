import 'package:flutter/material.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Padding(
        padding: const EdgeInsets.only(top: 0, bottom: 0),
        child: Image.asset(
          'assets/logo/logo.png',
          width: 110,
          fit: BoxFit.fitWidth,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(
          color: const Color(0x1A000000),
          height: 0,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
