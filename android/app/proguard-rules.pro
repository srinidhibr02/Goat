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
