plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.hifi_player"
    compileSdk = flutter.compileSdkVersion

    defaultConfig {
        applicationId = "com.example.hifi_player"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    buildTypes {
        release {
            // Na razie debug signing, żeby build działał bez keystore.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
    // NIE ustawiamy tutaj "target" — ma być domyślne lib/main.dart
}

dependencies {
    // puste — Flutter/plug-iny dodadzą co trzeba
}