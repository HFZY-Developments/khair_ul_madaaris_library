plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.hfzy.khair_ul_madaaris_library"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
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

    // Signing configuration (for production release)
    // TODO: For production deployment, create a keystore and configure signing:
    // 1. Generate keystore: keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
    // 2. Create android/key.properties with: storePassword, keyPassword, keyAlias, storeFile
    // 3. Uncomment and configure the signingConfigs block below

    /*
    signingConfigs {
        create("release") {
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
        }
    }
    */

    buildTypes {
        release {
            // Currently using debug signing for development
            // IMPORTANT: For production, configure proper signing (see TODO above)
            signingConfig = signingConfigs.getByName("debug")
            // TODO: Uncomment when release signing is configured
            // signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}
