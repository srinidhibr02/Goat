/// Categories a temple can belong to.
enum TempleCategory {
  all('All'),
  shaiva('Shaiva'),
  vaishnava('Vaishnava'),
  shakti('Shakti'),
  sikh('Sikh'),
  jain('Jain'),
  buddhist('Buddhist'),
  other('Other');

  const TempleCategory(this.displayName);

  final String displayName;

  /// Parses a string (case-insensitive) to a [TempleCategory].
  /// Falls back to [TempleCategory.other] for unknown values.
  static TempleCategory fromString(String s) {
    return TempleCategory.values.firstWhere(
      (c) => c.name.toLowerCase() == s.toLowerCase(),
      orElse: () => TempleCategory.other,
    );
  }
}
