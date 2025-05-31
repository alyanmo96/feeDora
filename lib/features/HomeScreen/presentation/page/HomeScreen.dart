import 'package:feedora_app/features/ChatWithFeeDoraScreen/presentation/page/ChatWithFeeDoraScreen.dart';
import 'package:feedora_app/features/HomeScreen/presentation/widgets/buildTrendingPage.dart';
import 'package:feedora_app/features/ProfileScreen/presentation/page/ProfileScreen.dart';
import 'package:feedora_app/features/SearchFeed/presentation/page/SearchFeedScreen.dart';
import 'package:feedora_app/features/HomeScreen/presentation/widgets/buildFeedPage.dart';
import 'package:feedora_app/features/MapScreen/presentation/page/MapScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final PageController _pageController = PageController();
  int _currentPage = 0; //bottom navigation bar
  List<String> _interests = [];
  String? _selectedCategory;
  // ignore: unused_field
  bool _trendingLoading = true;
  List<String> _trendingCategories = [];

  @override
  void initState() {
    super.initState();
    _pageController; // Not required but good to initialize explicitly
    _loadUserInterests();
    _loadTrendingCategories();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pageController.dispose(); // Dispose the PageController
    super.dispose();
  }

  Future<void> _loadTrendingCategories() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('feedPostsByAI').get();
      final categoryCounts = <String, int>{};

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final category = data['category'] ?? 'General';
        categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
      }

      final sorted =
          categoryCounts.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

      final topCategories = sorted.take(5).map((e) => e.key).toList();

      if (mounted) {
        setState(() {
          _trendingCategories = topCategories;
          _trendingLoading = false;
        });
      }
    } catch (e) {
      print('Error loading trending categories: $e');
      if (mounted) setState(() => _trendingLoading = false);
    }
  }

  Future<void> _loadUserInterests() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final doc =
          await FirebaseFirestore.instance
              .collection('feedUsersDora')
              .doc(uid)
              .get();
      final List interests = doc.data()?['interests'] ?? [];
      setState(() {
        _interests = List<String>.from(interests);
      });
    } catch (e) {
      print('Error loading interests: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text("FeeDora"),
            SizedBox(width: 100),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                showSearch(context: context, delegate: SearchFeedDelegate());
              },
            ),
            SizedBox(width: 10),
            IconButton(
              icon: const Icon(Icons.map),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MapScreen()),
                );
              },
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline),
              tooltip: "Chat with FeeDora",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ChatWithFeeDoraScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        children: [
          BuildFeedPage(
            interests: _interests,
            selectedCategory: _selectedCategory,
            scrollController: _scrollController,
            trendingCategories: _trendingCategories,
            onCategorySelected: (category) {
              setState(() {
                _selectedCategory = category;
              });
            },
            onRefresh: _loadUserInterests,
          ),

          const BuildTrendingPage(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPage,
        onTap: (index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          setState(() {
            _currentPage = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.trending_up), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }
}
