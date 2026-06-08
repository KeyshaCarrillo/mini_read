class PlanCapabilities {
  final String id;
  final int maxProfiles;
  final int maxDevices;
  final int coinsDaily;
  final bool basicAI;
  final bool advancedAI;

  const PlanCapabilities({
    required this.id,
    required this.maxProfiles,
    required this.maxDevices,
    required this.coinsDaily,
    required this.basicAI,
    required this.advancedAI,
  });

  static const free = PlanCapabilities(
    id: 'free',
    maxProfiles: 4,
    maxDevices: 2,
    coinsDaily: 20,
    basicAI: true,
    advancedAI: false,
  );

  static const plus = PlanCapabilities(
    id: 'plus',
    maxProfiles: 6,
    maxDevices: 3,
    coinsDaily: 50,
    basicAI: true,
    advancedAI: true,
  );

  static const premium = PlanCapabilities(
    id: 'premium',
    maxProfiles: 8,
    maxDevices: 5,
    coinsDaily: 100,
    basicAI: true,
    advancedAI: true,
  );

  static PlanCapabilities from(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'plus':
        return plus;
      case 'premium':
        return premium;
      default:
        return free;
    }
  }
}
