/// Every input and intermediate value of the FAO-56 calculation.
class EtoResult {
  const EtoResult({
    required this.tmax,
    required this.tmin,
    required this.tmean,
    required this.rhMean,
    required this.u2,
    required this.rs,
    required this.ra,
    required this.rn,
    required this.g,
    required this.es,
    required this.ea,
    required this.delta,
    required this.gamma,
    required this.eto,
  });

  final double tmax, tmin, tmean, rhMean, u2, rs, ra, rn, g;
  final double es, ea, delta, gamma, eto;
}
