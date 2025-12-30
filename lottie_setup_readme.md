# Lottie Animations Setup for GoalBuddy

This document explains how to use Lottie animations in your drill sessions app.

## Setup Completed

The following has been completed for you:

1. **Lottie Package Added**: The `lottie` package is already included in `pubspec.yaml`
2. **Assets Path Configured**: `assets/animations/` path is already added to `pubspec.yaml`
3. **Dependencies Installed**: Run `flutter pub get` to ensure all packages are installed
4. **Build Verified**: Successfully tested that the app builds correctly with Lottie integration

## How to Use Lottie Animations

### 1. Adding Animation Files

1. Place your Lottie JSON animation files in the `assets/animations/` directory
2. Examples of animation file names:
   - `dribbling.json`
   - `shooting.json`
   - `passing.json`
   - `defending.json`

### 2. Using the Animation Widgets

The following widgets are available for use:

#### LottieAnimationWidget
A basic widget to display Lottie animations:

```dart
LottieAnimationWidget(
  animationPath: 'assets/animations/my_animation.json',
  width: 300,
  height: 300,
  repeat: true,
  reverse: false,
)
```

### 3. Animation Manager

Use the `AnimationManager` utility class to manage your animations:

```dart
// Get animation path for a drill type
String animationPath = AnimationManager.getAnimationPath('dribbling');

// Check if animation exists
bool hasAnimation = AnimationManager.hasAnimation('shooting');

// Get all available drill types
List<String> drillTypes = AnimationManager.getAvailableDrillTypes();
```

### 4. Drill Category Enum

Use the `DrillCategory` enum for consistent drill categorization:

```dart
DrillCategory category = DrillCategory.dribbling;
String animationPath = category.animationPath;
```

### 5. Creating Drill Session Screens

Use the `DrillSessionScreen` widget to create interactive drill sessions with animations:

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => DrillSessionScreen(
      drillName: 'My Drill',
      animationAssetPath: 'assets/animations/my_animation.json',
    ),
  ),
);
```

## Sample Animation Files

A sample animation file (`sample_animation.json`) has been created in the `assets/animations/` directory to demonstrate the format.

## Adding Your Own Animations

1. Create or obtain Lottie JSON animation files (`.json` format)
2. Place them in the `assets/animations/` directory
3. Update the `AnimationManager.drillAnimations` map in `lib/utils/animation_manager.dart` with new animation paths
4. Use the animations in your drill sessions

## Best Practices

- Keep animation file sizes small for better performance
- Use consistent naming conventions for animation files
- Test animations on different device sizes
- Consider providing fallback animations for missing files
- Use appropriate animation durations for drill sessions

## Troubleshooting

If animations don't appear:

1. Verify the animation file exists in the correct directory
2. Check that the file path is correct
3. Run `flutter clean` and `flutter pub get` again
4. Ensure the animation file is a valid Lottie JSON format

## Files Created/Modified

The following files were created or modified during setup:

1. `lib/widgets/lottie_animation_widget.dart` - Basic Lottie animation widget
2. `lib/screens/drill_session_screen.dart` - Interactive drill session screen with animations
3. `lib/screens/drills_list_screen.dart` - Sample drill list screen
4. `lib/utils/animation_manager.dart` - Utility class for managing animations
5. `assets/animations/sample_animation.json` - Sample Lottie animation file
6. Updated `lib/main.dart` to include new routes
7. This README file with setup instructions