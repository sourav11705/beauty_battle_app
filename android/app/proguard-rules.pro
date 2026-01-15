# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Image Cropper / uCrop
-dontwarn com.yalantis.ucrop**
-keep class com.yalantis.ucrop** { *; }
-keep interface com.yalantis.ucrop** { *; }

# OkIo (Used by uCrop)
-dontwarn okio**
-keep class okio** { *; }
-keep interface okio** { *; }

# Google Play Services (Deferred Components)
-dontwarn com.google.android.play.**
-keep class com.google.android.play.** { *; }