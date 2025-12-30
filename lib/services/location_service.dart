import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Service for handling location operations.
class LocationService {
  /// Check and request location permissions.
  Future<bool> checkAndRequestPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Get current position.
  Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await checkAndRequestPermissions();
      if (!hasPermission) return null;

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
    } catch (e) {
      return null;
    }
  }

  /// Get current position as GeoPoint.
  Future<GeoPoint?> getCurrentGeoPoint() async {
    final position = await getCurrentPosition();
    if (position == null) return null;
    return GeoPoint(position.latitude, position.longitude);
  }

  /// Calculate distance between two points in kilometers.
  double calculateDistance({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
  }

  /// Calculate distance between two GeoPoints in kilometers.
  double calculateGeoPointDistance(GeoPoint point1, GeoPoint point2) {
    return calculateDistance(
      lat1: point1.latitude,
      lon1: point1.longitude,
      lat2: point2.latitude,
      lon2: point2.longitude,
    );
  }

  /// Convert kilometers to miles.
  double kmToMiles(double km) => km * 0.621371;

  /// Convert miles to kilometers.
  double milesToKm(double miles) => miles * 1.60934;

  /// Check if a point is within a radius of another point.
  bool isWithinRadius({
    required GeoPoint center,
    required GeoPoint point,
    required double radiusKm,
  }) {
    return calculateGeoPointDistance(center, point) <= radiusKm;
  }
}
