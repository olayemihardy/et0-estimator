import 'package:dio/dio.dart';

import '../models/weather_data.dart';

/// Error with a user-friendly [message].
class WeatherException implements Exception {
  const WeatherException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Fetches today's daily weather from the Open-Meteo Forecast API (no key).
class WeatherService {
  WeatherService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
            ));

  final Dio _dio;
  static const _baseUrl = 'https://api.open-meteo.com/v1/forecast';
  static const _dailyVariables = [
    'temperature_2m_max',
    'temperature_2m_min',
    'relative_humidity_2m_mean',
    'wind_speed_10m_mean',
    'shortwave_radiation_sum',
    'et0_fao_evapotranspiration',
  ];

  Future<WeatherData> fetchToday(double lat, double lon) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        _baseUrl,
        queryParameters: {
          'latitude': lat,
          'longitude': lon,
          'daily': _dailyVariables.join(','),
          'wind_speed_unit': 'ms',
          'timezone': 'auto',
          'forecast_days': 1,
        },
      );
      return _parse(response.data ?? const {}, lat, lon);
    } on DioException catch (e) {
      const offline = {
        DioExceptionType.connectionError,
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
      };
      if (offline.contains(e.type)) {
        throw const WeatherException(
            'No internet connection. Check your network and try again.');
      }
      throw WeatherException(
          'The weather service failed (HTTP ${e.response?.statusCode ?? 'n/a'}). '
          'Please try again later.');
    } on WeatherException {
      rethrow;
    } catch (_) {
      throw const WeatherException('Unexpected weather data format received.');
    }
  }

  WeatherData _parse(Map<String, dynamic> json, double lat, double lon) {
    final daily = json['daily'] as Map<String, dynamic>?;
    if (daily == null) {
      throw const WeatherException('Weather response had no daily data.');
    }

    double? first(String key) {
      final list = daily[key] as List<dynamic>?;
      final value = (list == null || list.isEmpty) ? null : list.first;
      return (value as num?)?.toDouble();
    }

    double need(String key) =>
        first(key) ?? (throw WeatherException('Missing value for $key.'));

    final time = (daily['time'] as List<dynamic>).first as String;
    return WeatherData(
      date: DateTime.parse(time),
      latitude: lat,
      longitude: lon,
      elevation: (json['elevation'] as num?)?.toDouble() ?? 0,
      tmax: need('temperature_2m_max'),
      tmin: need('temperature_2m_min'),
      rhMean: need('relative_humidity_2m_mean'),
      windSpeed10m: need('wind_speed_10m_mean'),
      solarRadiation: need('shortwave_radiation_sum'),
      openMeteoEt0: first('et0_fao_evapotranspiration'),
    );
  }
}
