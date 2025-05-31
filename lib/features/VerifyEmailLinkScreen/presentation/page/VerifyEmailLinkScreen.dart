import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VerifyEmailLinkScreen extends StatefulWidget {
  final String emailLink;

  // ignore: use_super_parameters
  const VerifyEmailLinkScreen({required this.emailLink, Key? key})
    : super(key: key);

  @override
  _VerifyEmailLinkScreenState createState() => _VerifyEmailLinkScreenState();
}

class _VerifyEmailLinkScreenState extends State<VerifyEmailLinkScreen> {
  String message = 'Verifying email...';

  @override
  void initState() {
    print(
      '--------------------------------------------------------------------1---------------------------------------------------------------------------',
    );
    print(
      '--------------------------------------------------------------------2---------------------------------------------------------------------------',
    );
    print(
      '--------------------------------------------------------------------1---------------------------------------------------------------------------',
    );
    print(
      '--------------------------------------------------------------------2---------------------------------------------------------------------------',
    );
    print(
      '--------------------------------------------------------------------1---------------------------------------------------------------------------',
    );
    print(
      '--------------------------------------------------------------------2---------------------------------------------------------------------------',
    );
    print('message: $message');
    // ignore: avoid_print, prefer_interpolation_to_compose_strings
    print('emailLink: ' + widget.emailLink);
    print(
      '--------------------------------------------------------------------1---------------------------------------------------------------------------',
    );
    print(
      '--------------------------------------------------------------------2---------------------------------------------------------------------------',
    );
    print(
      '--------------------------------------------------------------------1---------------------------------------------------------------------------',
    );
    print(
      '--------------------------------------------------------------------2---------------------------------------------------------------------------',
    );
    print(
      '--------------------------------------------------------------------1---------------------------------------------------------------------------',
    );
    print(
      '--------------------------------------------------------------------2---------------------------------------------------------------------------',
    );
    super.initState();
    _verifyEmailLink();

    print(
      '--------------------------------------------------------------------_verifyEmailLink()---After----------------------------------------------------------------------',
    );
  }

  Future<void> _verifyEmailLink() async {
    try {
      print(
        '--------------------------------------------------------------------_verifyEmailLink()--1-------------------------------------------------------------------------',
      );
      final auth = FirebaseAuth.instance;
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('emailForSignIn') ?? '';

      print("📨 Email: $email");
      print("🔗 EmailLink: ${widget.emailLink}");

      print(
        '--------------------------------------------------------------------_verifyEmailLink()--2-------------------------------------------------------------------------',
      );
      // ignore: await_only_futures
      final isValid = await auth.isSignInWithEmailLink(widget.emailLink);

      if (isValid && email.isNotEmpty) {
        print(
          '--------------------------------------------------------------------_verifyEmailLink()--3-------------------------------------------------------------------------',
        );
        final userCred = await auth.signInWithEmailLink(
          email: email,
          emailLink: widget.emailLink,
        );
        print("✅ Signed in as: ${userCred.user?.email}");

        setState(() => message = "✅ Signed in as ${userCred.user?.email}");
        // FIRESTORE USER MIGRATION HERE
        final firestore = FirebaseFirestore.instance;
        final newUid = userCred.user?.uid;
        final oldUid = prefs.getString('anonymousUid');

        // Get old user data if exists
        if (oldUid != null && oldUid != newUid) {
          final oldDoc =
              await firestore.collection('feedUsersDora').doc(oldUid).get();

          if (oldDoc.exists) {
            final data = oldDoc.data();
            await firestore
                .collection('feedUsersDora')
                .doc(newUid)
                .set(data ?? {});
            print('✅ Migrated user data from $oldUid to $newUid');

            // Optional: clean up old anonymous Firestore document
            await firestore.collection('feedUsersDora').doc(oldUid).delete();
            print('🧹 Deleted old anonymous user data for $oldUid');
            // Update email field in Firestore
            await firestore.collection('feedUsersDora').doc(newUid).update({
              'emailAddress': userCred.user?.email ?? '',
            });
          } else {
            // Just create an empty doc
            await firestore.collection('feedUsersDora').doc(newUid).set({
              'savedPosts': [],
              'interests': [],
            });
            print('📄 Created new user doc for $newUid');
          }
        }
        //remove old data
        prefs.remove('anonymousUid');
        prefs.remove('emailForSignIn');
        await Future.delayed(const Duration(seconds: 2));
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        print("❌ Invalid email link or email is missing");
        setState(() => message = "❌ Invalid or expired sign-in link.");
      }
    } catch (e) {
      print("❌ Error verifying link: $e");
      setState(() => message = "❌ Error: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (message == 'Verifying email...')
              const Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Verifying email...'),
                ],
              )
            else
              Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
