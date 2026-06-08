class UserLibraryState {
  final bool isPremium;
  final String uid;
  final String name;
  final String email;
  final String photoUrl;
  final String bio;
  final List<String> favoriteGenres;
  final String membership;
  final int maxProfiles;
  final int maxDevices;
  final int coinsDaily;
  final bool basicAI;
  final bool advancedAI;
  final DateTime? createdAt;
  final String subscriptionStatus;
  final String selectedProfileId;

  const UserLibraryState({
    required this.isPremium,
    this.uid = '',
    this.name = '',
    this.email = '',
    this.photoUrl = '',
    this.bio = '',
    this.favoriteGenres = const [],
    this.membership = 'free',
    this.maxProfiles = 4,
    this.maxDevices = 2,
    this.coinsDaily = 20,
    this.basicAI = true,
    this.advancedAI = false,
    this.createdAt,
    this.subscriptionStatus = 'active',
    this.selectedProfileId = '',
  });
}
