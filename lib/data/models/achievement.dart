/// Achievement model for gamification
class Achievement {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final DateTime? unlockedAt;
  final bool isUnlocked;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    this.unlockedAt,
    this.isUnlocked = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'description': description,
    'icon_name': iconName,
    'unlocked_at': unlockedAt?.toIso8601String(),
  };

  factory Achievement.fromMap(Map<String, dynamic> map) => Achievement(
    id: map['id'],
    name: map['name'],
    description: map['description'],
    iconName: map['icon_name'],
    unlockedAt: map['unlocked_at'] != null 
      ? DateTime.parse(map['unlocked_at']) 
      : null,
    isUnlocked: map['unlocked_at'] != null,
  );

  Achievement copyWithUnlock(DateTime unlockedAt) => Achievement(
    id: id,
    name: name,
    description: description,
    iconName: iconName,
    unlockedAt: unlockedAt,
    isUnlocked: true,
  );
}

/// Predefined achievements
class Achievements {
  Achievements._();

  static final List<Achievement> all = [
    Achievement(
      id: 'first_detection',
      name: 'First Detection',
      description: 'Detect your first team beacon',
      iconName: 'radar',
    ),
    Achievement(
      id: 'century_club',
      name: 'Century Club',
      description: 'Reach 100 total detections',
      iconName: 'star',
    ),
    Achievement(
      id: 'long_watch',
      name: 'Long Watch',
      description: 'Scan continuously for 1 hour',
      iconName: 'timer',
    ),
    Achievement(
      id: 'perfect_calibration',
      name: 'Perfect Calibration',
      description: 'Complete distance calibration',
      iconName: 'settings',
    ),
    Achievement(
      id: 'signal_hunter',
      name: 'Signal Hunter',
      description: 'Detect 10 different devices',
      iconName: 'search',
    ),
  ];
}