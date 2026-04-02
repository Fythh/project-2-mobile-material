import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme/app_theme.dart';
import 'pages/home_page.dart';
import 'pages/material_page.dart';
import 'pages/report_page.dart';
import 'pages/profile_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // GANTI DENGAN URL DAN KEY BARU (YANG SUDAH DIREGENERATE)
  await Supabase.initialize(
    url: 'https://mfozrzbbcpmkrvqifdwv.supabase.co',
    anonKey: 'sb_publishable_k4XBi7vnW7ArLIMZwpqUPw_nQCGEzZ2', // ← ganti dengan key yang udah diregenerate
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MaterialKU',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0; // 0: Beranda, 1: Material, 2: Laporan, 3: Profile

  // Daftar halaman (sesuai 4 menu)
  final List<Widget> _pages = [
    const HomePage(),
    const MaterialListPage(), // ← FIX: ganti MaterialPage jadi MaterialListPage
    const ReportPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle(_currentIndex)), // ← FIX: pakai fungsi buat judul
        centerTitle: true,
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05), // ← FIX: withOpacity diganti
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.gray400,
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              activeIcon: Icon(Icons.inventory_2),
              label: 'Material',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'Laporan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi buat dapetin judul berdasarkan index (biar AppBar dinamis)
  String _getTitle(int index) {
    switch (index) {
      case 0:
        return 'Beranda';
      case 1:
        return 'Material';
      case 2:
        return 'Laporan';
      case 3:
        return 'Profile';
      default:
        return 'MaterialKU';
    }
  }
}