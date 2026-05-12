import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Google Services plugin runs only when a real google-services.json is
// dropped in `android/app/`. Without the file the plugin task fails the
// build at configuration time, even for plain debug runs that never touch
// Google Sign-In. Local dev should be unaffected by its absence; sign-in
// just won't work until the file lands.
val googleServicesFile = file("google-services.json")
if (googleServicesFile.exists()) {
    apply(plugin = "com.google.gms.google-services")
}

val keyPropertiesFile = rootProject.file("key.properties")
val keyProperties = Properties()
if (keyPropertiesFile.exists()) {
    keyProperties.load(FileInputStream(keyPropertiesFile))
}

android {
    namespace = "com.strengthlabs.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.strengthlabs.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Release signing is only wired up when key.properties is actually present
    // (i.e. on a release-build machine). Casting nulls to String would blow up
    // even on a plain `flutter run --debug`, so we gate the block instead.
    if (keyPropertiesFile.exists()) {
        signingConfigs {
            create("release") {
                keyAlias = keyProperties["keyAlias"] as String
                keyPassword = keyProperties["keyPassword"] as String
                storeFile = (keyProperties["storeFile"] as? String)?.let { file(it) }
                storePassword = keyProperties["storePassword"] as String
            }
        }
        buildTypes {
            release {
                signingConfig = signingConfigs.getByName("release")
            }
        }
    } else {
        // Without a release key, fall back to debug signing so `flutter build
        // apk --release` still produces an installable artifact for local QA.
        buildTypes {
            release {
                signingConfig = signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}
