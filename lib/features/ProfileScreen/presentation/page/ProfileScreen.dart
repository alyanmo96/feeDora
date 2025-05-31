import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feedora_app/features/InterestSelectionScreen/presentation/page/InterestSelectionScreen.dart';
import 'package:feedora_app/features/LikedPostsScreen/presentation/page/LikedPostsScreen.dart';
import 'package:feedora_app/features/SavedPostsScreen/presentation/page/SavedPostsScreen.dart';
import 'package:feedora_app/features/SettingsScreen/presentation/page/SettingsScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<DocumentSnapshot>(
          future:
              FirebaseFirestore.instance
                  .collection('feedUsersDora')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('User data not found'));
            }

            final userData = snapshot.data!.data() as Map<String, dynamic>;
            final username = userData['username'] ?? 'No username';
            final profileImage = userData['profileImage'];

            return Column(
              children: [
                const SizedBox(height: 40),
                CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      profileImage != null
                          ? NetworkImage(profileImage)
                          : const NetworkImage(
                            'https://www.gravatar.com/avatar/placeholder?d=mp',
                          ),
                ),
                const SizedBox(height: 16),
                Text(
                  username,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(),

                /// Edit Interests
                ListTile(
                  leading: const Icon(Icons.interests),
                  title: const Text('Edit Interests'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => InterestSelectionScreen(),
                      ),
                    );
                  },
                ),

                /// Liked Posts
                ListTile(
                  leading: const Icon(Icons.favorite),
                  title: const Text('Liked Posts'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LikedPostsScreen(),
                      ),
                    );
                  },
                ),

                /// Saved Posts
                ListTile(
                  leading: const Icon(Icons.bookmark),
                  title: const Text('Saved Posts'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SavedPostsScreen(),
                      ),
                    );
                  },
                ),

                /// Settings
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings and Privacy'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
