# Code Cleanup Plan

## Duplicate Widgets to Remove

### Empty State Widgets (2 duplicates)
- ❌ `lib/presentation/widgets/common/empty_state_widget.dart` - Keep
- ❌ `lib/presentation/widgets/ui_effects/empty_state_widget.dart` - DELETE
- ❌ `lib/presentation/widgets/ui_effects/one_time_animated_icon.dart` - DELETE (duplicate of animated/one_time_animated_icon.dart)

### AI Explanation Widgets (2 duplicates)
- ❌ `lib/presentation/widgets/common/ai_explanation_widget.dart` - Keep
- ❌ `lib/presentation/widgets/ui_effects/ai_explanation_widget.dart` - DELETE

### Neon Card (2 duplicates)
- ❌ `lib/presentation/widgets/animations/neon_card.dart` - Keep
- ❌ `lib/presentation/widgets/ui_effects/neon_card.dart` - DELETE

### Old Card Components (Replace with minimal)
- ❌ `lib/presentation/widgets/cards/enhanced_stat_card.dart` - Replace with minimal_stat_card.dart
- ❌ `lib/presentation/widgets/cards/enhanced_tip_card.dart` - Replace with minimal_tip_card.dart
- ❌ `lib/presentation/widgets/cards/enhanced_subject_card.dart` - Replace with minimal_subject_card.dart
- ❌ `lib/presentation/widgets/cards/compatible_card.dart` - Can be removed if not used

### Unused Animation Widgets
- ❌ `lib/presentation/widgets/animations/flickering_card.dart` - Complex, not minimal
- ❌ `lib/presentation/widgets/animations/welcome_splash.dart` - Not used
- ❌ `lib/presentation/widgets/animations/animated_notification_list.dart` - Check if used

### Unused Navigation
- ❌ `lib/presentation/widgets/navigation/curved_nav_bar.dart` - Replaced with minimal nav
- ❌ `lib/presentation/widgets/navigation/floating_dock_nav_bar.dart` - Not used

### Theme Files
- ❌ `lib/presentation/theme/theme_colors.dart` - Old, replaced with app_colors.dart
- Check all imports of `theme_colors.dart` and replace with `app_colors.dart`

## Files to Update

### Replace theme_colors imports:
1. `lib/presentation/screens/subjects/subject_detail_screen.dart`
2. `lib/presentation/screens/calendar/calendar_screen.dart`
3. `lib/presentation/screens/study_plan/study_plan_screen.dart`
4. `lib/presentation/screens/profile/profile_screen.dart`
5. `lib/presentation/screens/quiz/quiz_setup_screen.dart`
6. `lib/presentation/screens/planner/ai_planner_screen.dart`

## Cleanup Steps

1. ✅ Create minimal components
2. ✅ Redesign dashboard
3. ✅ Redesign navigation
4. ✅ Redesign subjects screen
5. 🔄 Replace old card components
6. 🔄 Remove duplicate widgets
7. 🔄 Update all theme_colors imports
8. 🔄 Remove unused animation widgets
9. 🔄 Remove unused navigation widgets

