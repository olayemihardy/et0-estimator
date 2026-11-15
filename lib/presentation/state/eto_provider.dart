import 'package:flutter/foundation.dart';

import '../../core/eto_calculator.dart';
import '../../models/eto_result.dart';
import '../../models/weather_data.dart';
import '../../services/location_service.dart';
import '../../services/weather_service.dart';

enum LoadStatus { idle, loading, success, error }

/// App state shared by the Location and Results screens.
class EtoProvider extends ChangeNotifier {
  EtoProvider({LocationService? location, WeatherService? weather})
      : locationService = location ?? LocationService(),
        _weatherService = weather ?? WeatherService();

  final LocationService locationService;
  final WeatherService _weatherService;

  double? latitude;
  double? longitude;
  bool locating = false;
  LocationException? locationError;

  LoadStatus status = LoadStatus.idle;
  String? weatherError;
  WeatherData? weather;
  EtoResult? result;

  /// Gets the device position. Returns true on success.
  Future<bool> locate() async {
    locating = true;
    locationError = null;
    notifyListeners();
    try {
      final pos = await locationService.getCurrentPosition();
      latitude = pos.latitude;
      longitude = pos.longitude;
      return true;
    } on LocationException catch (e) {
      locationError = e;
      return false;
    } finally {
      locating = false;
      notifyListeners();
    }
  }

  /// Fetches today's weather for the stored position and computes ETo.
  Future<void> loadWeather() async {
    if (latitude == null || longitude == null) return;
    status = LoadStatus.loading;
    weatherError = null;
    notifyListeners();
    try {
      weather = await _weatherService.fetchToday(latitude!, longitude!);
      result = calculateEto(weather!);
      status = LoadStatus.success;
    } on WeatherException catch (e) {
      weatherError = e.message;
      status = LoadStatus.error;
    }
    notifyListeners();
  }
}
