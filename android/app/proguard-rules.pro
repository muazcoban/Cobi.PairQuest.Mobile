# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep your application classes
-keep class com.cobi.pair_quest.** { *; }

# Audioplayers
-keep class xyz.luan.audioplayers.** { *; }

# Gson (if used)
-keepattributes Signature
-keepattributes *Annotation*

# SharedPreferences
-keep class android.content.SharedPreferences { *; }

# Prevent proguard from stripping interface information
-keepattributes Exceptions,InnerClasses,Signature,Deprecated,SourceFile,LineNumberTable,*Annotation*,EnclosingMethod

# Google Play Core (Deferred Components)
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**
