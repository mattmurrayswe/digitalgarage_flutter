import 'package:flutter/material.dart';

class LogoAppBar extends StatelessWidget implements PreferredSizeWidget {
  const LogoAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 140,
      leadingWidth: 130,
      leading: Padding(
        padding: const EdgeInsets.only(left: 26.0),
        child: Image.asset('assets/logo.png', fit: BoxFit.contain),
      ),
      title: const Text(''),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF070707), Colors.black],
          ),
        ),
      ),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, color: Color(0xFF0C0C0C)),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(140);
}
