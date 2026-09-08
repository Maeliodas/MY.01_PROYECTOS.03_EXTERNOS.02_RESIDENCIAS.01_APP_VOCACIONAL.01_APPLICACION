pluginManagement {
<<<<<<< HEAD
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }
=======
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        val localPropertiesFile = java.io.File(rootDir, "local.properties")
        if (localPropertiesFile.exists()) {
            localPropertiesFile.reader().use { properties.load(it) }
        }
        properties.getProperty("flutter.sdk")
            ?: error("flutter.sdk not set in android/local.properties")
    }
>>>>>>> c77126d02bbecfd46df322bb41ea0935bba4d1d3

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
<<<<<<< HEAD
    id("com.android.application") version "9.1.0" apply false
    id("org.jetbrains.kotlin.android") version "2.4.0" apply false
}

include(":app")
=======
    // Usamos la versión mínima requerida por tu Flutter SDK (8.11.1)
    id("com.android.application") version "9.0.1" apply false
    // Declaramos explícitamente Kotlin Gradle Plugin (KGP)
    id("org.jetbrains.kotlin.android") version "2.3.20" apply false
}

include(":app")
>>>>>>> c77126d02bbecfd46df322bb41ea0935bba4d1d3
