import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {
  final int currentIndex;
  const NavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      elevation: 0,
      selectedItemColor: const Color(0xFF192965),
      unselectedItemColor: const Color(0xFF8F9BB3),
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: 'Beranda',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment_rounded),
          label: 'Peminjaman',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_rounded),
          label: 'Profil',
        ),
      ],
      currentIndex: currentIndex,
      onTap: (i) {
        // Ganti navigasi sesuai kebutuhan
        if (i == 0) {
          Navigator.pushReplacementNamed(context, '/user/home');
        } else if (i == 1) {
          Navigator.pushReplacementNamed(context, '/user/peminjaman');
        } else if (i == 2) {
          Navigator.pushReplacementNamed(context, '/user/profil');
        }
      },
    );
  }
}