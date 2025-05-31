import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class InterestSelectionScreen extends StatefulWidget {
  @override
  _InterestSelectionScreenState createState() =>
      _InterestSelectionScreenState();
}

class _InterestSelectionScreenState extends State<InterestSelectionScreen> {
  final List<String> _availableInterests = [
    'Tech',
    'Languages',
    'Travel',
    'Art',
    'Science',
    'Health',
    'Finance',
    'Sports',
    'AI',
    'Books',
    'Food',
    'Animals',
    'Cars',
    'Music',
    'Comedy',
    'Beauty',
    'Garden',
    'Games',
    'Finance',
  ];

  Set<String> _selectedInterests = {};

  @override
  void initState() {
    super.initState();
    _loadUserInterests();
  }

  Future<void> _loadUserInterests() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc =
        await FirebaseFirestore.instance
            .collection('feedUsersDora')
            .doc(user.uid)
            .get();
    if (doc.exists && doc.data()?['interests'] != null) {
      setState(() {
        _selectedInterests = Set<String>.from(doc['interests']);
      });
    }
  }

  Future<void> _saveInterests() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('feedUsersDora')
        .doc(user.uid)
        .set({
          'interests': _selectedInterests.toList(),
        }, SetOptions(merge: true));

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Interests updated!')));

    Navigator.pop(context); // Go back to HomeScreen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Your Interests')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Wrap(
              spacing: 10.0,
              runSpacing: 10.0,
              children:
                  _availableInterests.map((interest) {
                    final isSelected = _selectedInterests.contains(interest);
                    return FilterChip(
                      label: Text(interest),
                      selected: isSelected,
                      onSelected: (bool selected) {
                        setState(() {
                          if (selected) {
                            _selectedInterests.add(interest);
                          } else {
                            _selectedInterests.remove(interest);
                          }
                        });
                      },
                    );
                  }).toList(),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _saveInterests,
              child: Text('Save Interests'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
