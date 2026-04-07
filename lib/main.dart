import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pages/dashboard/dashboard_page.dart';
import 'pages/members/members_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// import 'pages/loans/loans_page.dart';
// import 'pages/transactions/transactions_page.dart';
// import 'pages/reports/reports_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url:
        'https://qzvknysszgpeykudxohs.supabase.co', // from Supabase API settings
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF6dmtueXNzemdwZXlrdWR4b2hzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU0NDkwMzcsImV4cCI6MjA5MTAyNTAzN30.YBPmzOkk3Y0n1S6GEUqBklC_JpaB91P5hEmnPZg2Abo', // from Supabase API settings
  );

  runApp(const PautangApp());
}

class PautangApp extends StatelessWidget {
  const PautangApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PAUTANG - Lending App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue[800],
          foregroundColor: Colors.white,
          elevation: 2,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      home: const MainPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const MembersPage(),
    // const LoansPage(),
    // const TransactionsPage(),
    // const ReportsPage(),
  ];

  final List<String> _titles = [
    'Dashboard',
    'Members',
    'Loans',
    'Transactions',
    'Reports',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        centerTitle: true,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue[800],
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Members',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.money),
            label: 'Loans',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
        ],
      ),
    );
  }
}
