/// FAO-56 Penman-Monteith reference evapotranspiration.
///
/// Pure functions only (no UI, no I/O). Equation numbers refer to
/// Allen et al. (1998), FAO Irrigation and Drainage Paper 56.
library;

import 'dart:math' as math;

import '../models/eto_result.dart';
import '../models/weather_data.dart';

const double _stefanBoltzmann = 4.903e-9; // MJ K⁻⁴ m⁻² day⁻¹
const double _albedo = 0.23; // reference grass crop
const double _solarConstant = 0.0820; // MJ m⁻² min⁻¹

/// Mean air temperature (°C).
double meanTemperature(double tmax, double tmin) => (tmax + tmin) / 2;

/// Saturation vapour pressure e°(T) in kPa (Eq. 11).
double saturationVaporPressure(double t) =>
    0.6108 * math.exp(17.27 * t / (t + 237.3));

/// Mean saturation vapour pressure es (Eq. 12), kPa.
double meanSaturationVaporPressure(double tmax, double tmin) =>
    (saturationVaporPressure(tmax) + saturationVaporPressure(tmin)) / 2;

/// Actual vapour pressure ea (kPa).
///
/// Design choice: only a daily MEAN relative humidity is available from
/// Open-Meteo, so ea = e°(Tmin) * RHmean / 100. Using e°(Tmin) as the
/// reference follows the FAO-56 idea that the dew point is close to Tmin,
/// and avoids over-estimating ea when a mean RH is combined with e°(Tmean).
double actualVaporPressure(double tmin, double rhMean) =>
    saturationVaporPressure(tmin) * rhMean / 100;

/// Slope of the saturation vapour pressure curve Δ (Eq. 13), kPa/°C.
double slopeVaporPressureCurve(double tmean) =>
    4098 * saturationVaporPressure(tmean) / math.pow(tmean + 237.3, 2);

/// Atmospheric pressure P (Eq. 7), kPa, from elevation z in metres.
double atmosphericPressure(double z) =>
    101.3 * math.pow((293 - 0.0065 * z) / 293, 5.26);

/// Psychrometric constant γ (Eq. 8), kPa/°C.
double psychrometricConstant(double z) => 0.000665 * atmosphericPressure(z);

/// Wind speed at 2 m from a 10 m measurement (Eq. 47), m/s.
double windSpeedAt2m(double u10) => u10 * 4.87 / math.log(67.8 * 10 - 5.42);

/// Extraterrestrial radiation Ra (Eqs. 21-25), MJ/m²/day.
double extraterrestrialRadiation(double latitudeDeg, int dayOfYear) {
  final phi = latitudeDeg * math.pi / 180;
  final dr = 1 + 0.033 * math.cos(2 * math.pi / 365 * dayOfYear); // Eq. 23
  final delta = 0.409 * math.sin(2 * math.pi / 365 * dayOfYear - 1.39); // Eq. 24
  // Sunset hour angle (Eq. 25); argument clamped for polar day/night.
  final x = (-math.tan(phi) * math.tan(delta)).clamp(-1.0, 1.0);
  final ws = math.acos(x);
  return (24 * 60 / math.pi) *
      _solarConstant *
      dr *
      (ws * math.sin(phi) * math.sin(delta) +
          math.cos(phi) * math.cos(delta) * math.sin(ws)); // Eq. 21
}

/// Clear-sky radiation Rso (Eq. 37), MJ/m²/day.
double clearSkyRadiation(double ra, double z) => (0.75 + 2e-5 * z) * ra;

/// Net shortwave radiation Rns (Eq. 38), MJ/m²/day.
double netShortwaveRadiation(double rs) => (1 - _albedo) * rs;

/// Net longwave radiation Rnl (Eq. 39), MJ/m²/day.
double netLongwaveRadiation({
  required double tmax,
  required double tmin,
  required double ea,
  required double rs,
  required double rso,
}) {
  final tk4 = (math.pow(tmax + 273.16, 4) + math.pow(tmin + 273.16, 4)) / 2;
  // Relative shortwave radiation, limited to <= 1 as FAO-56 requires.
  final ratio = rso <= 0 ? 0.5 : (rs / rso).clamp(0.0, 1.0);
  return _stefanBoltzmann *
      tk4 *
      (0.34 - 0.14 * math.sqrt(ea)) *
      (1.35 * ratio - 0.35);
}

/// Daily reference evapotranspiration ETo (Eq. 6), mm/day.
///
/// [rn] net radiation and [g] soil heat flux in MJ/m²/day, [u2] wind at 2 m
/// in m/s, [ea] in kPa, [elevation] in metres.
double referenceEto({
  required double tmax,
  required double tmin,
  required double ea,
  required double u2,
  required double rn,
  required double elevation,
  double g = 0,
}) {
  final tmean = meanTemperature(tmax, tmin);
  final es = meanSaturationVaporPressure(tmax, tmin);
  final delta = slopeVaporPressureCurve(tmean);
  final gamma = psychrometricConstant(elevation);
  final numerator =
      0.408 * delta * (rn - g) + gamma * 900 / (tmean + 273) * u2 * (es - ea);
  final denominator = delta + gamma * (1 + 0.34 * u2);
  return numerator / denominator;
}

/// Day of year (1-366) for [date].
int dayOfYear(DateTime date) =>
    DateTime.utc(date.year, date.month, date.day)
        .difference(DateTime.utc(date.year, 1, 1))
        .inDays +
    1;

/// Runs the whole chain from Open-Meteo data to ETo and keeps every
/// intermediate value for display.
EtoResult calculateEto(WeatherData w) {
  const g = 0.0; // soil heat flux is negligible for daily steps
  final tmean = meanTemperature(w.tmax, w.tmin);
  final es = meanSaturationVaporPressure(w.tmax, w.tmin);
  final ea = actualVaporPressure(w.tmin, w.rhMean);
  final u2 = windSpeedAt2m(w.windSpeed10m);
  final ra = extraterrestrialRadiation(w.latitude, dayOfYear(w.date));
  final rso = clearSkyRadiation(ra, w.elevation);
  final rnl = netLongwaveRadiation(
      tmax: w.tmax, tmin: w.tmin, ea: ea, rs: w.solarRadiation, rso: rso);
  final rn = netShortwaveRadiation(w.solarRadiation) - rnl;
  final eto = referenceEto(
    tmax: w.tmax,
    tmin: w.tmin,
    ea: ea,
    u2: u2,
    rn: rn,
    g: g,
    elevation: w.elevation,
  );
  return EtoResult(
    tmax: w.tmax,
    tmin: w.tmin,
    tmean: tmean,
    rhMean: w.rhMean,
    u2: u2,
    rs: w.solarRadiation,
    ra: ra,
    rn: rn,
    g: g,
    es: es,
    ea: ea,
    delta: slopeVaporPressureCurve(tmean),
    gamma: psychrometricConstant(w.elevation),
    eto: eto,
  );
}
