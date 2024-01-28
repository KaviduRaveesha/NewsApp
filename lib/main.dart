// main.dart

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'screens/top_stories_screen.dart';
import 'screens/category_screen.dart';
import 'screens/popular_screen.dart';
import 'screens/video_screen.dart';
import 'screens/live_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LK News App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _isRefreshing = false; // Track whether the refresh is in progress

  final List<Widget> _screens = [
    TopStoriesScreen(),
    const CategoryScreen(),
    const PopularScreen(),
    const ImageScreen(),
     NewsApp(),
  ];

  // Add a TextEditingController for the search functionality
  final TextEditingController _searchController = TextEditingController();

  Future<void> _handleRefresh() async {
    // Simulate a refresh delay
    setState(() {
      _isRefreshing = true;
    });

    await Future.delayed(const Duration(seconds: 2)); // Simulate refresh for 2 seconds

    setState(() {
      _isRefreshing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: 'Top Stories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Popular',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library),
            label: 'Media',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
        ],
      ),
      tabBuilder: (BuildContext context, int index) {
        return CupertinoTabView(
          builder: (BuildContext context) {
            return CupertinoPageScaffold(
              navigationBar: CupertinoNavigationBar(
                middle: _currentIndex == 1
                    ? CupertinoTextField(
                  controller: _searchController,
                  placeholder: 'Search',
                  onChanged: (String value) {
                    // Handle search here
                    // You can use _searchController.text to get the search query
                    print('Search: $value');
                  },
                )
                    : const Text('LK News App'),
                trailing: IconButton(
                  icon: _isRefreshing
                      ? const CupertinoActivityIndicator()
                      : const Icon(Icons.refresh),
                  onPressed: _isRefreshing
                      ? null
                      : () {
                    // Handle refresh here
                    print('Refresh button tapped');
                    _handleRefresh();
                  },
                ),
              ),
              child: _screens[index],
            );
          },
        );
      },
    );
  }
}
