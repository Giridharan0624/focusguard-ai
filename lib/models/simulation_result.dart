class SimulationResult {
  final double originalScore;
  final double improvedScore;
  final Map<String, double> changes;

  const SimulationResult({
    required this.originalScore,
    required this.improvedScore,
    required this.changes,
  });

  double get improvement => originalScore - improvedScore;
}
