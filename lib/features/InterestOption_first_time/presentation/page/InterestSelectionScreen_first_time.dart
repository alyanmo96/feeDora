import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InterestSelectionScreen extends StatefulWidget {
  const InterestSelectionScreen({super.key});

  @override
  State<InterestSelectionScreen> createState() =>
      _InterestSelectionScreenState();
}

class _InterestSelectionScreenState extends State<InterestSelectionScreen> {
  final List<InterestOption> _interests = [
    InterestOption(title: "Tech", icon: "💻"),
    InterestOption(title: "Travel", icon: "✈️"),
    InterestOption(title: "Food", icon: "🍝"),
    InterestOption(title: "Health", icon: "🏃‍♂️"),
    InterestOption(title: "Languages", icon: "🌍"),
    InterestOption(title: "AI", icon: "🧠"),
    InterestOption(title: "Animals", icon: "🐾"),
    InterestOption(title: "Sports", icon: "⚽"),
    InterestOption(title: "Cars", icon: "🚗"),
    InterestOption(title: "Music", icon: "🎵"),
    InterestOption(title: "Comedy", icon: "😂"),
    InterestOption(title: "Beauty", icon: "💄"),
    InterestOption(title: "Garden", icon: "🌿"),
    InterestOption(title: "Games", icon: "🎮"), // 🆕 New
    InterestOption(title: "Finance", icon: "💰"),
  ];

  final List<String> _selected = [];

  void _toggleInterest(String title) {
    setState(() {
      if (_selected.contains(title)) {
        _selected.remove(title);
      } else {
        _selected.add(title);
      }
    });
  }

  Future<void> _submit() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance
          .collection('feedUsersDora')
          .doc(uid)
          .set({
            'interests': _selected,
            'timestamp': FieldValue.serverTimestamp(),
            'account user ID': uid,
            'savedPosts': [],
            'username': 'New user account',
            'emailAddress': '',
          });
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Choose Your Interests")),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Select 3 to 5 topics you’re interested in:",
              style: TextStyle(fontSize: 16),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _interests.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                final interest = _interests[index];
                final selected = _selected.contains(interest.title);
                return GestureDetector(
                  onTap: () => _toggleInterest(interest.title),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color:
                          selected
                              ? Colors.blue.shade100
                              : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? Colors.blue : Colors.grey,
                      ),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          interest.icon,
                          style: const TextStyle(fontSize: 32),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          interest.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _selected.length >= 3 ? _submit : null,
              child: const Text("Continue"),
            ),
          ),
        ],
      ),
    );
  }
}

class InterestOption {
  final String title;
  final String icon;

  InterestOption({required this.title, required this.icon});
}
