/// Raw daily weather values returned by Open-Meteo for one location/day.
class WeatherData {
  const WeatherData({
    required this.date,
    required this.latitude,
    required this.longitude,
    required this.elevation,
    required this.tmax,
    required this.tmin,
    required this.rhMean,
    required this.windSpeed10m,
    required this.solarRadiation,
    this.openMeteoEt0,
  });

  final DateTime date;
  final double latitude;
  final double longitude;

  /// Elevation above sea level (m), from the Open-Meteo response.
  final double elevation;
  final double tmax; // °C
  final double tmin; // °C
  final double rhMean; // %
  final double windSpeed10m; // m/s at 10 m
  final double solarRadiation; // Rs, MJ/m²/day
  final double? openMeteoEt0; // mm/day, used only as a reference check
}
