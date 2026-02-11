import java.io.File
import java.util.Properties
import org.gradle.api.GradleException

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}

val releaseTasksRequested = gradle.startParameter.taskNames.any {
    it.contains("release", ignoreCase = true)
}
val requiredSigningKeys = listOf("storeFile", "storePassword", "keyAlias", "keyPassword")
val missingSigningKeys = requiredSigningKeys.filter {
    keystoreProperties.getProperty(it).isNullOrBlank()
}
val releaseSigningConfigured = keystorePropertiesFile.exists() && missingSigningKeys.isEmpty()

if (releaseTasksRequested && !releaseSigningConfigured) {
    throw GradleException(
        buildString {
            appendLine("Release signing is required for production builds.")
            appendLine("Missing configuration in android/key.properties.")
            appendLine("Required keys: ${requiredSigningKeys.joinToString(", ")}")
            appendLine("Found file: ${keystorePropertiesFile.absolutePath}")
            appendLine(
                "Use the same signing key as your installed production app for in-place updates."
            )
        }
    )
}

android {
    namespace = "com.hfzy.khair_ul_madaaris_library"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // Application ID - Unique identifier for this app
        applicationId = "com.hfzy.khair_ul_madaaris_library"

        // API levels - managed by Flutter (see pubspec.yaml)
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion

        // Version information - synced with pubspec.yaml
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (releaseSigningConfigured) {
            create("release") {
                val rawStoreFile = keystoreProperties.getProperty("storeFile")
                val resolvedStoreFile = if (File(rawStoreFile).isAbsolute) {
                    File(rawStoreFile)
                } else {
                    rootProject.file(rawStoreFile)
                }

                if (!resolvedStoreFile.exists()) {
                    throw GradleException(
                        "Release keystore not found: ${resolvedStoreFile.absolutePath}"
                    )
                }

                storeFile = resolvedStoreFile
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            isShrinkResources = false
            if (releaseSigningConfigured) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
    }
}

flutter {
    source = "../.."
}
