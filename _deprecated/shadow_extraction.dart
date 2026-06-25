class Shadow {
  final String id;
  final String name;
  final String title;
  final String description;
  final String rank; // e.g., 'Knight Grade', 'Elite Knight Grade'
  final String iconPath;
  final DateTime extractedAt;

  const Shadow({
    required this.id,
    required this.name,
    required this.title,
    required this.description,
    required this.rank,
    required this.iconPath,
    required this.extractedAt,
  });
}

final List<Shadow> allAvailableShadows = [
  Shadow(
    id: 'igris',
    name: 'Igris',
    title: 'The Blood-Red Commander',
    description: 'A loyal knight shadow extracted from the Iron Trial.',
    rank: 'Knight Grade',
    iconPath: 'assets/images/shadows/igris.png',
    extractedAt: DateTime.now(),
  ),
  Shadow(
    id: 'tank',
    name: 'Tank',
    title: 'The Ice Bear Alpha',
    description: 'A massive bear shadow extracted from the Wall Trial.',
    rank: 'Elite Knight Grade',
    iconPath: 'assets/images/shadows/tank.png',
    extractedAt: DateTime.now(),
  ),
  Shadow(
    id: 'iron',
    name: 'Iron',
    title: 'The Shield Master',
    description: 'A sturdy shield-bearing shadow extracted from the Elite Trial.',
    rank: 'Knight Grade',
    iconPath: 'assets/images/shadows/iron.png',
    extractedAt: DateTime.now(),
  ),
  Shadow(
    id: 'beru',
    name: 'Beru',
    title: 'The Ant King',
    description: 'The ultimate shadow extracted from the S-Class Evaluation.',
    rank: 'General Grade',
    iconPath: 'assets/images/shadows/beru.png',
    extractedAt: DateTime.now(),
  ),
];
