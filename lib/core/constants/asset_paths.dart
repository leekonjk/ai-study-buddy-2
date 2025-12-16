/// Centralized asset path references.
/// Only paths from allowed directories: UI/UX, Flow, requirements.
library;

class AssetPaths {
  AssetPaths._();

  // UI/UX assets - used for onboarding, empty states, illustrations
  static const String uiUxBase = 'lib/assets/UI/UX';

  // Flow assets - architecture diagrams (documentation only, not runtime)
  static const String flowBase = 'lib/assets/Flow';

  // Requirements assets - specification references (documentation only)
  static const String requirementsBase = 'lib/assets/requirements';
}
