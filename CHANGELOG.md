## 1.4.0

- Rename Android package to `uz.plugin.easy_pdf_viewer` and implement `EasyPdfViewerPlugin` for the Android embedder.
- Migrate widgets from `flutter/material.dart` to the `material_ui` package (`material_ui: ^1.0.1`).
- Raise minimum SDK constraints: `flutter: ">=3.47.0"`, `sdk: ">=3.13.0 <4.0.0"`.
- Fix deprecated `ScrollView.cacheExtent` usage; use `scrollCacheExtent` (`ScrollCacheExtent.pixels`) instead.
- Bump Android Gradle Plugin to `9.0.1`, Kotlin to `2.3.20`, Gradle wrapper to `9.1.0`, `compileSdk` to `37`.
- Fix invalid Groovy-style single quotes in `android/settings.gradle.kts`.
- Fix `.kotlin/` ignore pattern in `example/android/.gitignore`.
- Update `analysis_lints` to `^1.1.0` and scope analyzer excludes to platform build folders.

## 1.3.3

- Fix CocoaPods build by resolving non-existent `RunnerTests` target lookup failure in the iOS example project.
- Fix CocoaPods integration base configuration warning by configuring the `Profile` build configuration to use `Profile.xcconfig`.
- Set minimum Flutter SDK constraint to `flutter: ">=3.41.0"`.

## 1.3.2

- Migrate Android build files from Groovy DSL to Kotlin DSL (`.gradle` → `.gradle.kts`).
- Update Gradle wrapper and Android Gradle Plugin versions.

## 1.3.1

- Restore CocoaPods support alongside Swift Package Manager for backward compatibility.

## 1.3.0

- Migrate iOS to Swift Package Manager (SPM).
- Rewrite iOS native implementation in Swift; remove CocoaPods and ObjC bridge.
- Drop `flutter_cache_manager` dependency (built-in cache retained).

## 1.2.0

- Remove `flutter_cache_manager` dependency and keep built-in caching support.

## 1.0.8

- Add param onZoomChanged to PDFViewer

## 1.0.7

- Upgrade some deps
- Modify example code

## 1.0.6

- Fix setState being called wrong

## 1.0.5

- Fix missing parameter

## 1.0.4

- Fix deprecated API

## 1.0.3

- Add progress status

## 1.0.2

- Support multiple files

## 1.0.1

- Support the v2 Android embedder.

## 1.0.0

- fix lazyload after fork
