# Add project specific ProGuard rules here.

# Keep BLE classes
-keep class android.bluetooth.** { *; }
-keep class com.bleguard.scanner.** { *; }

# Keep Gson serialization
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Room database
-keep class * extends androidx.room.RoomDatabase
-dontwarn androidx.room.paging.**
