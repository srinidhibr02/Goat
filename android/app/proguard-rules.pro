# ── Flutter & Dart ────────────────────────────────────────────────────────────
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# ── Firebase ──────────────────────────────────────────────────────────────────
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# ── Firebase Crashlytics ──────────────────────────────────────────────────────
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception
-keep class com.google.firebase.crashlytics.** { *; }

# ── Kotlin serialization ──────────────────────────────────────────────────────
-keepattributes *Annotation*, InnerClasses
-dontnote kotlinx.serialization.AnnotationsKt

# ── OSMDroid (Explore map) ────────────────────────────────────────────────────
-keep class org.osmdroid.** { *; }

# ── General Android ───────────────────────────────────────────────────────────
-keepattributes Signature
-keepattributes Exceptions
-dontwarn java.lang.invoke.**
-dontwarn **$$Lambda$*

# ── Flutter Play Store Split / Deferred Components ────────────────────────────
# This app does not use deferred components. Suppress R8 warnings about
# Play Core classes referenced by Flutter's embedding but not used at runtime.
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

# ── Shared Preferences ───────────────────────────────────────────────────────
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# ── Keep all Parcelable implementations ──────────────────────────────────────
-keepclassmembers class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator CREATOR;
}

# ── Keep enums (used by Riverpod providers) ──────────────────────────────────
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}
