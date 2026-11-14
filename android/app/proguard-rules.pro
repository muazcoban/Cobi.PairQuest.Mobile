# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep your application classes
-keep class com.cobistudio.pairquest.** { *; }

# Audioplayers
-keep class xyz.luan.audioplayers.** { *; }

# Gson: flutter_local_notifications caches scheduled notifications with it.
# Without these rules R8 strips the generic types and cancelling or scheduling
# a notification throws "TypeToken must be created with a type argument".
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# SharedPreferences
-keep class android.content.SharedPreferences { *; }

# Prevent proguard from stripping interface information
-keepattributes Exceptions,InnerClasses,Signature,Deprecated,SourceFile,LineNumberTable,*Annotation*,EnclosingMethod

# Google Play Core (Deferred Components)
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**
