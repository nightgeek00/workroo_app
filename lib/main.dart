import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'provider/visa_provider.dart';
import 'screens/home_screen.dart';
import 'screens/visa_screen.dart';
import 'screens/postcode_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => VisaProvider())],
      child: const WorkrooApp(),
    ),
  );
}

class WorkrooApp extends StatelessWidget {
  const WorkrooApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workroo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const VisaScreen(),
    const PostcodeScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _pages[_index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.article_outlined), label: 'Visa'),
          NavigationDestination(icon: Icon(Icons.public_outlined), label: 'Postcode'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}
