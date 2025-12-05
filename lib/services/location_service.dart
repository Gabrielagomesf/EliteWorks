import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  static Future<bool> checkPermission() async {
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

  static Future<Position?> getCurrentPosition() async {
    try {
      bool hasPermission = await checkPermission();
      if (!hasPermission) {
        return null;
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getCurrentAddress() async {
    try {
      Position? position = await getCurrentPosition();
      if (position == null) {
        return null;
      }

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'address': [
            place.street,
            place.subThoroughfare,
          ].where((e) => e != null && e.isNotEmpty).join(', '),
          'city': place.locality ?? place.subAdministrativeArea ?? '',
          'state': place.administrativeArea ?? '',
          'zipCode': place.postalCode ?? '',
          'fullAddress': [
            place.street,
            place.subThoroughfare,
            place.locality,
            place.administrativeArea,
            place.postalCode,
          ].where((e) => e != null && e.isNotEmpty).join(', '),
        };
      }

      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'address': '',
        'city': '',
        'state': '',
        'zipCode': '',
        'fullAddress': '${position.latitude}, ${position.longitude}',
      };
    } catch (e) {
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> searchAddresses(String query) async {
    try {
      List<Location> locations = await locationFromAddress(query);
      List<Map<String, dynamic>> results = [];

      for (Location location in locations) {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          location.latitude,
          location.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          results.add({
            'latitude': location.latitude,
            'longitude': location.longitude,
            'address': [
              place.street,
              place.subThoroughfare,
            ].where((e) => e != null && e.isNotEmpty).join(', '),
            'city': place.locality ?? place.subAdministrativeArea ?? '',
            'state': place.administrativeArea ?? '',
            'zipCode': place.postalCode ?? '',
            'fullAddress': [
              place.street,
              place.subThoroughfare,
              place.locality,
              place.administrativeArea,
              place.postalCode,
            ].where((e) => e != null && e.isNotEmpty).join(', '),
          });
        }
      }

      return results;
    } catch (e) {
      return [];
    }
  }

  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  static String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toStringAsFixed(0)}m';
    } else {
      return '${(distanceInMeters / 1000).toStringAsFixed(1)}km';
    }
  }
}

