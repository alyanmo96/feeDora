import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:feedora_app/features/HomeScreen/presentation/page/HomeScreen.dart';
import 'package:feedora_app/features/InterestOption_first_time/presentation/page/InterestSelectionScreen_first_time.dart';
import 'package:feedora_app/features/VerifyEmailLinkScreen/presentation/page/VerifyEmailLinkScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

Future<String?> getEmailFromLocalStorage() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('emailForSignIn');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FeeDora',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: const SplashLoginHandler(),
      routes: {
        "/interests": (context) => const InterestSelectionScreen(),
        "/home": (context) => const HomeScreen(),
        "/verify":
            (context) => const Scaffold(
              body: Center(child: Text("Opening verification...")),
            ),
      },
    );
  }
}

class SplashLoginHandler extends StatefulWidget {
  const SplashLoginHandler({super.key});

  @override
  State<SplashLoginHandler> createState() => _SplashLoginHandlerState();
}

class _SplashLoginHandlerState extends State<SplashLoginHandler> {
  bool _linkHandled = false;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    await _handleDynamicLinks();
    if (!_linkHandled) _checkLoginAndNavigate();
  }

  void _checkLoginAndNavigate() {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null && user.email != null) {
      debugPrint("✅ Already logged in: ${user.email}");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/home');
      });
    } else {
      debugPrint("🕵️ No user found. Attempting anonymous login...");
      _handleAnonymousLogin();
    }
  }

  Future<void> _handleAnonymousLogin() async {
    try {
      if (FirebaseAuth.instance.currentUser == null) {
        await FirebaseAuth.instance.signInAnonymously();
        debugPrint('✅ Anonymous login successful');
        await FirebaseAuth.instance.signInAnonymously();
        final uid = FirebaseAuth.instance.currentUser?.uid;
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('anonymousUid', uid!);
      }

      if (context.mounted && !_linkHandled) {
        Navigator.pushReplacementNamed(context, "/interests");
      }
    } catch (e) {
      debugPrint('❌ Anonymous login failed: $e');
    }
  }

  Future<void> _handleDynamicLinks() async {
    final auth = FirebaseAuth.instance;

    try {
      final initialData = await FirebaseDynamicLinks.instance.getInitialLink();
      final deepLink = initialData?.link;
      if (deepLink != null) {
        debugPrint("🔗 Initial dynamic link detected: $deepLink");
        await _handleSignInWithLink(auth, deepLink);
      }

      FirebaseDynamicLinks.instance.onLink
          .listen((dynamicLinkData) async {
            final link = dynamicLinkData.link;
            debugPrint("📥 Received dynamic link while app is open: $link");
            await _handleSignInWithLink(auth, link);
          })
          .onError((error) {
            debugPrint('❌ Error listening to dynamic links: $error');
          });
    } catch (e) {
      debugPrint('❌ Error initializing dynamic links: $e');
    }
  }

  Future<void> _handleSignInWithLink(FirebaseAuth auth, Uri deepLink) async {
    final email = await getEmailFromLocalStorage();
    final isValid = auth.isSignInWithEmailLink(deepLink.toString());

    debugPrint("📡 Verifying email link...");
    if (isValid && email != null && context.mounted) {
      _linkHandled = true;
      print(
        '------------------------------------erifying email link...---------1---------------------------------------------------------------------------------------------------------------------------------------',
      );
      print(
        '------------------------------------erifying email link...---------2---------------------------------------------------------------------------------------------------------------------------------------',
      );
      print('email: $email');
      print('context.mounted: ' + context.mounted.toString());
      print('deepLink: ' + deepLink.toString());
      print(
        '------------------------------------erifying email link...---------3---------------------------------------------------------------------------------------------------------------------------------------',
      );
      print(
        '------------------------------------erifying email link...---------4---------------------------------------------------------------------------------------------------------------------------------------',
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => VerifyEmailLinkScreen(emailLink: deepLink.toString()),
        ),
      );
    } else {
      debugPrint("⚠️ Invalid link or missing email");
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
