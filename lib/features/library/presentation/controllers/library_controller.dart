import 'home_controller.dart';

export 'home_controller.dart' show OnboardingProfileDraft;

class LibraryController extends HomeController {
  static const int maxProfiles = HomeController.maxProfiles;

  LibraryController({
    required super.repository,
    required super.getBooks,
    required super.getProfiles,
  });
}
