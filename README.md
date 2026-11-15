# ETo Estimator

Flutter (Android) app estimating today's reference evapotranspiration (ETo)
for your location with FAO-56 Penman-Monteith, using Open-Meteo (no API key).

Flow: Welcome → Get Location → Confirm dialog → Results (all inputs and
intermediates, Open-Meteo ET0 as a reference check) → Calculate dialog.

## Setup & run
```
flutter create --platforms=android --project-name eto_estimator .
del test\widget_test.dart        # (rm test/widget_test.dart on macOS/Linux)
dart run tool/setup_android.dart # adds permissions + minSdk 23
flutter pub get
flutter analyze
flutter test
flutter run
flutter build apk --release      # -> build/app/outputs/flutter-apk/app-release.apk
```

## Structure
`lib/core/eto_calculator.dart` pure FAO-56 functions · `lib/models` data classes ·
`lib/services` geolocator + Open-Meteo (dio) · `lib/presentation/<screen>` UI ·
`presentation/state` Provider.

## Notes
- Open-Meteo daily variables used: temperature_2m_max/min,
  relative_humidity_2m_mean, wind_speed_10m_mean (m/s),
  shortwave_radiation_sum, et0_fao_evapotranspiration; elevation is read from
  the response.
- ea = e°(Tmin)·RHmean/100 (documented in the code). G = 0 for daily steps.
- Values are model data for the day, not station measurements.
