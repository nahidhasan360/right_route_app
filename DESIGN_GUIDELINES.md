# Right Routes - Design Guidelines

## Color System (AppColors)

আমাদের প্রজেক্টে সব color `lib/utils/colors.dart` ফাইল থেকে ব্যবহার করতে হবে।

### Available Colors:

```dart
AppColors.orange          // #F58842 - Primary action color (buttons, highlights)
AppColors.purple          // #9DACF5 - Secondary accent color
AppColors.white           // #FFFFFF - Text and icons
AppColors.black           // #000000 - Dark backgrounds
AppColors.darkGray        // #333333 - Card backgrounds
AppColors.medGray         // #606060 - Borders and dividers
AppColors.unactiveColor   // #4A4A6B - Inactive states
AppColors.dividerColor    // #9DACF5 - Dividers
AppColors.checkBoxColor   // #4260F5 - Checkboxes
AppColors.progressbarColor // #FFC700 - Progress indicators
AppColors.editEmailColor  // #9DACF5 - Email edit fields
```

## Typography

### Font Families:
- **League Gothic** - Headers and titles (uppercase)
- **Lato** - Body text and descriptions
- **Bebas Neue** - Special buttons and emphasis

### Font Sizes:
- **32px** - Main page titles (League Gothic)
- **20px** - Section headers (League Gothic)
- **18px** - Button text, card titles (League Gothic/Lato)
- **16px** - Body text, descriptions (Lato)
- **14px** - Secondary text, metadata (Lato)

## Spacing System

### Standard Spacing:
```dart
const SizedBox(height: 30)  // Large section spacing
const SizedBox(height: 20)  // Medium section spacing
const SizedBox(height: 16)  // Small section spacing
const SizedBox(height: 12)  // Tight spacing
const SizedBox(height: 6)   // Minimal spacing

const EdgeInsets.symmetric(horizontal: 20)  // Page padding
const EdgeInsets.all(20)                    // Card padding
const EdgeInsets.symmetric(vertical: 18)    // Button padding
```

## Component Patterns

### 1. Page Structure
```dart
Scaffold(
  body: Container(
    width: double.infinity,
    height: double.infinity,
    decoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage(ImageManager.mapBackground),
        fit: BoxFit.cover,
      ),
    ),
    child: SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              // Content here
            ],
          ),
        ),
      ),
    ),
  ),
  bottomNavigationBar: CustomNavbar(),
)
```

### 2. Logo Section
```dart
const SizedBox(height: 30),
Container(
  width: 225,
  height: 112,
  decoration: BoxDecoration(
    image: DecorationImage(
      image: AssetImage(ImageManager.splashScreenLogo),
      fit: BoxFit.contain,
    ),
  ),
),
const SizedBox(height: 29),
```

### 3. Page Title
```dart
Text(
  'YOUR TITLE HERE',
  style: TextStyle(
    color: AppColors.white,
    fontSize: 32,
    fontFamily: 'League Gothic',
    fontWeight: FontWeight.w400,
    height: 0.88,
    letterSpacing: 1.50,
  ),
  textAlign: TextAlign.center,
),
```

### 4. Description Text
```dart
Text(
  'Your description text here.',
  textAlign: TextAlign.center,
  style: TextStyle(
    color: AppColors.white,
    fontSize: 16,
    fontFamily: 'Lato',
    fontWeight: FontWeight.w400,
    height: 1.44,
  ),
),
```

### 5. Primary Button
```dart
GestureDetector(
  onTap: () {
    // Action here
  },
  child: Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 18),
    decoration: BoxDecoration(
      color: AppColors.orange,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.your_icon,
          color: AppColors.white,
          size: 24,
        ),
        const SizedBox(width: 12),
        Text(
          'BUTTON TEXT',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 18,
            fontFamily: 'League Gothic',
            fontWeight: FontWeight.w400,
            letterSpacing: 1.2,
          ),
        ),
      ],
    ),
  ),
)
```

### 6. Card Component
```dart
Container(
  width: double.infinity,
  padding: const EdgeInsets.all(20),
  decoration: BoxDecoration(
    color: AppColors.darkGray.withValues(alpha: 0.8),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: AppColors.medGray,
      width: 1,
    ),
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Card Title',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontFamily: 'Lato',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Subtitle',
            style: TextStyle(
              color: AppColors.white.withValues(alpha: 0.6),
              fontSize: 14,
              fontFamily: 'Lato',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
      Text(
        'Meta',
        style: TextStyle(
          color: AppColors.white.withValues(alpha: 0.7),
          fontSize: 14,
          fontFamily: 'Lato',
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  ),
)
```

### 7. Section Header
```dart
Align(
  alignment: Alignment.centerLeft,
  child: Text(
    'SECTION TITLE',
    style: TextStyle(
      color: AppColors.white,
      fontSize: 20,
      fontFamily: 'League Gothic',
      fontWeight: FontWeight.w400,
      letterSpacing: 1.2,
    ),
  ),
),
```

## Border Radius Standards
- **12px** - Buttons and cards
- **10px** - Input fields and smaller components

## Opacity/Alpha Values
- **0.8** - Card backgrounds
- **0.7** - Secondary text
- **0.6** - Tertiary text/metadata

## Important Rules

### ✅ DO:
1. Always import and use `AppColors` from `lib/utils/colors.dart`
2. Use `const` for all static widgets and values
3. Use `const SizedBox()` for spacing
4. Use `const EdgeInsets` for padding
5. Follow exact pixel values from design
6. Use `.withValues(alpha: x)` instead of deprecated `.withOpacity(x)`
7. Keep consistent spacing throughout the app
8. Use `SafeArea` for all screens
9. Add `SingleChildScrollView` for scrollable content
10. Include `CustomNavbar()` at bottom when needed

### ❌ DON'T:
1. Don't use hardcoded color values like `Color(0xFF...)` directly
2. Don't use `Colors.white`, use `AppColors.white`
3. Don't use `.withOpacity()` (deprecated), use `.withValues(alpha: x)`
4. Don't use random spacing values
5. Don't forget `const` keyword for static widgets
6. Don't mix font families inconsistently
7. Don't use different border radius values randomly

## Example Import Section
```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import '../../../global_widgets/custom_navbar.dart';
import '../../../utils/assets_manager.dart';
import '../../../utils/colors.dart';
```

## Testing Checklist
- [ ] All colors from AppColors
- [ ] Proper spacing (30, 20, 16, 12, 6)
- [ ] Correct font families
- [ ] Exact font sizes
- [ ] Border radius consistency
- [ ] `const` keywords used
- [ ] No deprecated methods
- [ ] SafeArea implemented
- [ ] Responsive to different screen sizes
- [ ] CustomNavbar included (if needed)

---

**Note:** এই guidelines follow করে নতুন screen design করলে consistency maintain হবে এবং codebase clean থাকবে।
