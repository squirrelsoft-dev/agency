# Agent Enhancement: Mobile App Builder

## Current State

**File**: `engineering/engineering-mobile-app-builder.md`
**Name**: `Mobile App Builder`
**Description**: `Specialized mobile application developer with expertise in native iOS/Android development and cross-platform frameworks`

## Proposed Changes

### Better Name
**Proposed**: `engineering-mobile-platform-developer`
**Rationale**: "Platform" emphasizes both iOS and Android expertise. "Builder" is less professional than "Developer" in technical roles.

### Better Description
**Proposed**: `Develops native and cross-platform mobile applications for iOS and Android using Swift, Kotlin, React Native, or Flutter. Implements platform-specific features, optimizes performance for mobile constraints, and integrates with native APIs. Use when building mobile apps, implementing platform features, or optimizing mobile UX.`

### Command Awareness
This agent should be aware of and potentially reference these agency commands:
- `/agency:work` - Implements mobile features and app functionality
- `/agency:plan` - Creates mobile app architecture and platform strategy
- `/agency:optimize` - Optimizes app performance, battery, and memory usage
- `/agency:test` - Creates mobile testing strategies across devices
- `/agency:document` - Generates mobile app documentation and API specs
- `/agency:review` - Reviews mobile code for platform best practices
- `/agency:refactor` - Refactors mobile code to modern patterns

## Enhancement Recommendations

### Capability Enhancements
- **App store optimization**: Automated screenshot generation and metadata
- **Crash reporting integration**: Firebase Crashlytics, Bugsnag setup
- **Analytics integration**: Firebase, Amplitude, Mixpanel implementation
- **Push notification systems**: FCM, APNs with segmentation
- **Deep linking**: Universal links and app links implementation
- **In-app purchases**: StoreKit, Google Play Billing integration
- **Offline-first architecture**: Local database sync strategies
- **Platform-specific CI/CD**: Fastlane, GitHub Actions for mobile

### Skill References
Should reference these workflow skills when available:
- `react-native-expert` - For cross-platform development
- `swift-swiftui-expert` - For modern iOS development
- `kotlin-jetpack-expert` - For modern Android development
- `mobile-performance-optimizer` - For app optimization
- `app-store-aso-expert` - For app store optimization

### Tool Access
Current tools seem appropriate, but consider adding:
- **Mobile debugging tools**: Device debugging and inspection
- **Performance profiling tools**: Instruments, Android Profiler
- **App store tools**: Upload and manage app submissions
- **Testing tools**: Device farm access for cross-device testing
- **Analytics tools**: Access to mobile analytics platforms

### Quality Improvements
- Add specific performance budgets for mobile (startup time, memory, battery)
- Include platform-specific design pattern guides (Material vs. HIG)
- Provide examples of successful offline-first architectures
- Add app store submission checklists for both platforms
- Include mobile security best practices (data encryption, secure storage)
- Provide migration guides between cross-platform frameworks
- Add examples of platform-specific feature implementations
- Include device fragmentation handling strategies
- Provide mobile CI/CD pipeline examples with signing and distribution
- Add examples of successful app performance optimization

## Implementation Priority
**Priority**: Medium-High
**Rationale**: Mobile development is critical for apps targeting mobile users. Requires specialized platform knowledge. Should coordinate with backend and design teams.
