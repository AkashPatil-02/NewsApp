import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/user_database.dart';
import 'package:flutter_application_1/providers/userdata.dart';
import 'package:flutter_application_1/screens/dash.dart';
import 'package:flutter_application_1/screens/saved.dart';
import 'package:flutter_application_1/screens/search.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Tabs extends ConsumerStatefulWidget {
  final String uid;
  const Tabs({super.key, required this.uid});

  @override
  ConsumerState<Tabs> createState() => _TabsState();
}

class _TabsState extends ConsumerState<Tabs> {
  int _pageIndex = 0;
  DataSnapshot? snapshot;
  String name = '';

  @override
  void initState() {
    super.initState();
    getName();
  }

  void _selectedPage(int index) {
    setState(() {
      _pageIndex = index;
    });
  }

  void getName() async {
    snapshot = await UserDatabase().read(path: 'userData/${widget.uid}');
    final data = snapshot!.value as Map<dynamic, dynamic>;
    setState(() {
      name = data['name'] ?? 'user';
    });
    ref
        .read(userNotifierProvider.notifier)
        .setUser(uid: widget.uid, name: name);
  }

  late final List<Widget> _pages = [
    DashScreen(),
    const SearchScreen(),
    SavedScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final userinfo = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome $name"),
        actions: [
          // Switch(
          //   thumbIcon: WidgetStateProperty.resolveWith<Icon?>((
          //     Set<WidgetState> states,
          //   ) {
          //     if (states.contains(WidgetState.selected)) {
          //       return const Icon(
          //         Icons.dark_mode,
          //         color: Colors.black,
          //         size: 18,
          //       );
          //     }
          //     return const Icon(Icons.light_mode, size: 18);
          //   }),
          //   value: themeProvider.themeMode == ThemeMode.dark,
          //   onChanged: (value) {
          //     themeProvider.toggleTheme(value);
          //   },
          // ),
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: Icon(
              Icons.logout,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
      body: IndexedStack(index: _pageIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _pageIndex,
        onTap: _selectedPage,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: "Saved"),
        ],
      ),
    );
  }
}
