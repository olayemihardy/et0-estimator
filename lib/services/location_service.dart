import 'package:geolocator/geolocator.dart';

/// Why obtaining a location failed.
enum LocationProblem { serviceDisabled, denied, deniedForever, unavailable }

/// Error with a user-friendly [message].
class LocationException implements Exception {
  const LocationException(this.problem, this.message);
  final LocationProblem problem;
  final String message;
  @override
  String toString() => message;
}

/// Wraps `geolocator`: checks service + permission, then reads the position.
class LocationService {
  Future<Position> getCurrentPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationException(LocationProblem.serviceDisabled,
          'Location services are turned off. Please enable GPS and try again.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw const LocationException(LocationProblem.denied,
          'Location permission was denied. The app needs it to find your weather.');
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(LocationProblem.deniedForever,
          'Location permission is permanently denied. Enable it in the app settings.');
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
    } catch (_) {
      throw const LocationException(LocationProblem.unavailable,
          'Could not determine your location. Move to an open area and retry.');
    }
  }

  Future<void> openAppSettings() => Geolocator.openAppSettings();
  Future<void> openLocationSettings() => Geolocator.openLocationSettings();
}
