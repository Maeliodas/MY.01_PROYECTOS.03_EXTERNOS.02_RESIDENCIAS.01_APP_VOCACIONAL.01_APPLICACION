pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        val localPropertiesFile = java.io.File(rootDir, "local.properties")
        if (localPropertiesFile.exists()) {
            localPropertiesFile.reader().use { properties.load(it) }
        }
        properties.getProperty("flutter.sdk")
            ?: error("flutter.sdk not set in android/local.properties")
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    // Usamos la versión mínima requerida por tu Flutter SDK (8.11.1)
    id("com.android.application") version "9.0.1" apply false
    // Declaramos explícitamente Kotlin Gradle Plugin (KGP)
    id("org.jetbrains.kotlin.android") version "2.3.20" apply false
}

include(":app")