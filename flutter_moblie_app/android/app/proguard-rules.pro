# Flutter
-keep class io.flutter.** { *; }
-keep class com.google.android.material.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Google Play Core
-keep class com.google.android.play.core.** { *; }

# Keep all native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep Parcelable
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Your app
-keep class com.thoutha.mobile.** { *; }

# Showcase / onboarding tooltips
-keep class com.simform.showcaseview.** { *; }

# Easy Localization
-keep class com.aissat.easy_localization.** { *; }

# Dio HTTP client
-keep class io.flutter.plugins.** { *; }

# Generic signatures are retained when class name is kept
-keepattributes Signature
-keepattributes RuntimeVisibleAnnotations

# Preserve line numbers for debugging
-keepattributes SourceFile,LineNumberTable

# Suppress warnings for missing Play Core classes
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task


