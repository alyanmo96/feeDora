import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  File? _profileImage; //for the new image
  String? _profileImageUrl; //for display the current image

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc =
          await FirebaseFirestore.instance
              .collection('feedUsersDora')
              .doc(uid)
              .get();
      final data = doc.data();
      if (data != null) {
        _usernameController.text = data['username'] ?? '';
        _emailController.text = data['emailAddress'] ?? '';
        _profileImageUrl = data['profileImage'];

        // 👇 show alert only AFTER loading email
        if (_emailController.text.isEmpty) {
          Future.delayed(Duration.zero, () {
            showDialog(
              context: context,
              builder:
                  (_) => AlertDialog(
                    title: const Text("Secure Your Account"),
                    content: const Text(
                      "You haven’t added your email address yet. Do this to sync your saved data across devices.",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Later"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Add Now"),
                      ),
                    ],
                  ),
            );
          });
        }
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedImage == null) return;

    final file = File(pickedImage.path);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ref = FirebaseStorage.instance
        .ref()
        .child('profileImages')
        .child('${user.uid}.jpg');

    await ref.putFile(file);
    final imageUrl = await ref.getDownloadURL();

    await FirebaseFirestore.instance
        .collection('feedUsersDora')
        .doc(user.uid)
        .update({'profileImageUrl': imageUrl});

    setState(() {
      _profileImage = file;
      _profileImageUrl = imageUrl;
    });
  }

  void _shareApp(BuildContext context) {
    Share.share(
      'Check out Feedora – a cool new way to discover local and global stories! 📲 Download now: https://example!!!!!!!!!.com',
      subject: 'Join me on Feedora!',
    );
  }

  void _showAboutApp(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Feedora',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2025 Feedora Inc. All rights reserved.',
      children: const [
        Padding(
          padding: EdgeInsets.only(top: 10),
          child: Text(
            'Feedora is a discovery-first social app that lets you explore local stories, trending topics, and connect through categorized content. 🌍✨',
          ),
        ),
      ],
    );
  }

  Future<void> _saveProfileWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _loading = true);

    String? imageUrl;
    if (_profileImage != null) {
      final ref = FirebaseStorage.instance.ref().child(
        'profile_images/$uid.jpg',
      );
      await ref.putFile(_profileImage!);
      imageUrl = await ref.getDownloadURL();
    }

    await FirebaseFirestore.instance
        .collection('feedUsersDora')
        .doc(uid)
        .update({
          'username': _usernameController.text.trim(),
          'emailAddress': _emailController.text.trim(),
          if (imageUrl != null) 'profileImage': imageUrl,
        });

    setState(() => _loading = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Profile updated')));
  }

  void _showWhyEmailDialog() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Why Add Your Email?'),
            content: const Text(
              "Adding your email helps you restore your account if you switch devices.\n\n"
              "This includes restoring:\n- Your interests\n- Saved posts\n- Profile image\n- Liked/disliked posts",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Got it"),
              ),
            ],
          ),
    );
  }

  sendSignInLink(String email) async {
    await FirebaseAuth.instance.sendSignInLinkToEmail(
      email: email,
      actionCodeSettings: ActionCodeSettings(
        url: 'https://feedoraapp.page.link/verify',
        handleCodeInApp: true,
        iOSBundleId: 'com.example.feedoraApp',
        androidPackageName: 'com.example.feedora_app',
        androidInstallApp: true,
        androidMinimumVersion: '21',
      ),
    );

    print('Link sent!');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('emailForSignIn', email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          _profileImageUrl != null
                              ? NetworkImage(_profileImageUrl!)
                              : const NetworkImage(
                                'https://www.gravatar.com/avatar/placeholder?d=mp',
                              ),
                    ),
                    const SizedBox(height: 20),
                    Form(
                      key: _formKey,
                      child: TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(),
                        ),
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Username required'
                                    : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.email),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          // ignore: curly_braces_in_flow_control_structures
                          return 'Email required';
                        if (!value.contains('@')) return 'Enter valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.verified),
                      label: const Text("Verify Email"),
                      onPressed: () async {
                        final email = _emailController.text.trim();
                        if (email.isNotEmpty && email.contains('@')) {
                          await sendSignInLink(email);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Enter a valid email first"),
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveProfileWithEmail,
                      child: const Text('Save Changes'),
                    ),
                    const Divider(height: 40),
                    ListTile(
                      leading: const Icon(Icons.email_outlined),
                      title: const Text('Why Add Email?'),
                      onTap: _showWhyEmailDialog,
                    ),

                    ListTile(
                      leading: const Icon(Icons.share),
                      title: const Text('Share with Friends'),
                      onTap: () => _shareApp(context),
                    ),
                    ListTile(
                      leading: const Icon(Icons.support_agent),
                      title: const Text('Contact Support'),
                      onTap: _showContactSupportDialog,
                    ),
                    ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: const Text('About the App'),
                      onTap: () => _showAboutApp(context),
                    ),
                  ],
                ),
              ),
    );
  }

  void _showContactSupportDialog() async {
    // ignore: no_leading_underscores_for_local_identifiers
    final TextEditingController _supportMessageController =
        TextEditingController();
    final deviceInfo = DeviceInfoPlugin();
    String deviceDescription = 'Unknown device'; //ios or Android or...
    String version = 'unknown';
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      deviceDescription =
          '${androidInfo.model} (Android ${androidInfo.version.release})';
      version = androidInfo.version.release;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      deviceDescription =
          '${iosInfo.utsname.machine} (iOS ${iosInfo.systemVersion})';
      version = iosInfo.systemVersion.toString();
    }
    final info = await PackageInfo.fromPlatform();
    final buildNumber = info.buildNumber;
    final username = _usernameController.text.trim();
    final isAnonymous = FirebaseAuth.instance.currentUser?.isAnonymous ?? true;
    final locale =
        Localizations.localeOf(context).toLanguageTag(); // e.g., "en-US"

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Contact Support'),
            content: TextFormField(
              controller: _supportMessageController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Describe your issue or feedback',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final message = _supportMessageController.text.trim();
                  if (message.isEmpty) return;
                  if (message.length < 5) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a longer message.'),
                      ),
                    );
                    return;
                  }

                  final uid = FirebaseAuth.instance.currentUser?.uid;
                  final email = _emailController.text.trim();

                  await FirebaseFirestore.instance
                      .collection('feedSupportCollectionDora')
                      .add({
                        'uid': uid,
                        'emailAddress': email.isNotEmpty ? email : null,
                        'timestamp': FieldValue.serverTimestamp(),
                        'description': message,
                        'device': deviceDescription,
                        'appVersion': '$version+$buildNumber',
                        'username': username,
                        'isAnonymous': isAnonymous,
                        'platform':
                            Platform.operatingSystem, // 'android' or 'ios'
                        'locale': locale,
                      });

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Message sent to support ✅')),
                  );
                },
                child: const Text('Send'),
              ),
            ],
          ),
    );
  }
}
