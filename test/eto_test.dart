import 'package:eto_estimator/core/eto_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('FAO-56 Example 18 gives about 3.9 mm/day', () {
    final eto = referenceEto(
      tmax: 21.5,
      tmin: 12.3,
      ea: 1.409,
      u2: 2.078,
      rn: 13.28,
      elevation: 100,
    );
    expect(eto, closeTo(3.9, 0.1));
  });

  test('intermediate values match FAO-56 Example 18', () {
    expect(meanSaturationVaporPressure(21.5, 12.3), closeTo(1.997, 0.005));
    expect(slopeVaporPressureCurve(16.9), closeTo(0.122, 0.002));
    expect(psychrometricConstant(100), closeTo(0.0666, 0.0005));
  });

  test('wind speed is reduced from 10 m to 2 m height', () {
    expect(windSpeedAt2m(10), closeTo(7.48, 0.02));
  });

  test('extraterrestrial radiation matches FAO-56 Example 8 (20°S, 3 Sep)', () {
    expect(extraterrestrialRadiation(-20, 246), closeTo(32.2, 0.3));
  });
}
