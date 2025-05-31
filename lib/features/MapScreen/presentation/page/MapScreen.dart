import 'package:feedora_app/features/FeedDetailScreen/presentation/page/FeedDetailScreen.dart';
import 'package:feedora_app/features/HomeScreen/domain/entities/FeedPost.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:feedora_app/core/utilities/location_services.dart';
import 'dart:async';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  double _radiusInMeters = 10000; // default 10 km
  bool _useMiles =
      false; // the default for non USA users display distance on Kilometers
  LatLng? _userLocation;
  // ignore: unused_field
  late GoogleMapController _mapController;
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};

  @override
  void initState() {
    super.initState();
    _loadUserLocation();
    _determineUnitSystem(); //Detect if we should use miles
  }

  Future<void> _determineUnitSystem() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final country = placemarks.first.isoCountryCode ?? '';

        // Only these countries use miles
        const mileCountries = ['US', 'LR', 'MM'];

        setState(() {
          _useMiles = mileCountries.contains(country.toUpperCase());
        });
      }
    } catch (e) {
      print('Failed to determine unit system: $e');
      // Default to KM if we can't detect
      setState(() {
        _useMiles = false;
      });
    }
  }

  //This method helps format the radius based on the unit system (KM/mi)
  String _formatRadius() {
    final radius =
        _useMiles
            ? (_radiusInMeters / 1609.34).toInt()
            : (_radiusInMeters / 1000).toInt();
    final unit = _useMiles ? 'mi' : 'km';
    print("Using unit: $unit");
    return '$radius $unit';
  }

  Future<BitmapDescriptor> _getMarkerIcon(String category) async {
    String assetPath;

    switch (category.toLowerCase()) {
      case 'food':
        assetPath = 'assets/images/food_marker.png';
        break;
      case 'technology':
        assetPath = 'assets/images/tech_marker.png';
        break;
      // Add more categories as needed
      default:
        assetPath = 'assets/images/default_marker.png';
    }

    // ignore: deprecated_member_use
    return BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      assetPath,
    );
  }

  Future<void> _loadNearbyPosts() async {
    final userLocation = await LocationServices().getCurrentLocation();

    final snapshot =
        await FirebaseFirestore.instance.collection('feedPostsByAI').get();

    final List<Marker> nearbyMarkers = [];

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final GeoPoint? geoPoint = data['location'];

      if (geoPoint == null) continue;

      final double distanceInMeters = Geolocator.distanceBetween(
        userLocation!.latitude,
        userLocation.longitude,
        geoPoint.latitude,
        geoPoint.longitude,
      );

      // Show only posts within accordding to what user choose 10KM - 150KM
      if (distanceInMeters <= _radiusInMeters) {
        final category = data['category'] ?? 'general';
        final icon = await _getMarkerIcon(category);

        nearbyMarkers.add(
          Marker(
            markerId: MarkerId(doc.id),
            position: LatLng(geoPoint.latitude, geoPoint.longitude),
            icon: icon,
            infoWindow: InfoWindow(
              title: data['title'] ?? '',
              snippet: category,
              onTap: () {
                _showPostPreview(doc);
              },
            ),
          ),
        );
      }
    }

    setState(() {
      _markers = nearbyMarkers.toSet();
      _circles = {
        Circle(
          circleId: const CircleId('radius'),
          center: LatLng(userLocation!.latitude, userLocation.longitude),
          radius: 10000, // 10 km
          strokeColor: Colors.blue,
          strokeWidth: 2,
          // ignore: deprecated_member_use
          fillColor: Colors.blue.withOpacity(0.15),
        ),
      };
    });
  }

  void _showPostPreview(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final post = FeedPost(
      postId: doc.id,
      interest: data['category'] ?? 'General',
      title: data['title'] ?? 'No title',
      imageUrl: data['imageUrl'] ?? '',
      sourceUrl: data['sourceUrl'] ?? '',
      likes:
          (data['likes'] is List)
              ? List<String>.from(data['likes'])
              : <String>[],
      dislikes:
          (data['dislikes'] is List)
              ? List<String>.from(data['dislikes'])
              : <String>[],
    );

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return GestureDetector(
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => FeedDetailScreen(
                      postId: post.postId,
                      title: post.title,
                      imageUrl: post.imageUrl,
                      interest: post.interest,
                      likes: post.likes,
                    ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            height: 200,
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    post.imageUrl,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        post.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '#${post.interest}',
                        style: const TextStyle(color: Colors.blue),
                      ),
                      const SizedBox(height: 8),
                      Text('❤️ ${post.likes.length} likes'),
                      const SizedBox(height: 8),
                      const Text(
                        'Tap to view full post →',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _loadUserLocation() async {
    final location = await LocationServices().getCurrentLocation();
    if (location != null) {
      final userLatLng = LatLng(location.latitude, location.longitude);
      setState(() {
        _userLocation = userLatLng;
      });
      _loadNearbyPosts();
    }
  }

  // ignore: unused_element
  void _updateMarkers(Set<Marker> markers) {
    setState(() {
      _markers = markers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discover Posts Near You')),
      body:
          _userLocation == null
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _userLocation!,
                      zoom: 16,
                    ),
                    onMapCreated: (controller) {
                      _mapController = controller;
                    },
                    markers: _markers,
                    circles: _circles,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    padding: const EdgeInsets.only(bottom: 120),
                  ),

                  Positioned(
                    bottom: 20,
                    left: 16,
                    right: 16,
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Text(
                              'Search Radius: ${_formatRadius()}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Slider(
                              value: _radiusInMeters,
                              min: 10000,
                              max: 150000,
                              divisions: 14,
                              label: _formatRadius(),
                              onChanged: (value) {
                                setState(() {
                                  _radiusInMeters = value;
                                  _loadNearbyPosts(); // reload markers
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}
