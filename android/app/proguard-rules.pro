# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile

# Keep OkHttp classes for image_cropper/UCrop
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**

# Keep UCrop classes
-keep class com.yalantis.ucrop.** { *; }
-dontwarn com.yalantis.ucrop.**

# Keep image_cropper classes
-keep class io.flutter.plugins.imagecropper.** { *; }
-dontwarn io.flutter.plugins.imagecropper.**

# Keep Google Play Core classes for Flutter
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Keep Google Play Services classes
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# Keep Gson classes for JSON parsing
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**

# Keep classes with @Keep annotation
-keep @androidx.annotation.Keep class * {*;}
-keepclassmembers class * {
    @androidx.annotation.Keep *;
}

# General Android rules
-keep class androidx.** { *; }
-dontwarn androidx.**

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep enum values
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}