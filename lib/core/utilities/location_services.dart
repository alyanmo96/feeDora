import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationServices {
  // ignore: body_might_complete_normally_nullable
  Future<Position?> getCurrentLocation() async {
    final status = await Permission.location.request();

    if (status.isGranted) {
      return await Geolocator.getCurrentPosition(
        // ignore: deprecated_member_use
        desiredAccuracy: LocationAccuracy.high,
      );
    } else {
      // throw Exception("Location permission not granted");
      if (status.isDenied || status.isPermanentlyDenied) {
        // Show dialog or return null
        return null;
      }
    }
  }

  Future<void> createPostWithLocation(
    String title,
    String imageUrl,
    String category,
  ) async {
    final position = await Geolocator.getCurrentPosition(
      // ignore: deprecated_member_use
      desiredAccuracy: LocationAccuracy.high,
    );

    final docRef = FirebaseFirestore.instance.collection('feed').doc();
    await docRef.set({
      'title': title,
      'imageUrl': imageUrl,
      'category': category,
      'likes': [],
      'location': GeoPoint(position.latitude, position.longitude),
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
