plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.nlp.digitox"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.nlp.digitox"
        minSdk = 26  // Required by tflite_flutter (Android 8.0+)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildFeatures {
        viewBinding = true
    }

    // Release signing config - using local keystore
    val releaseStoreFile = file("C:/Users/afjal/Documents/Final destination/NLP-digitox/android/upload-keystore.jks")

    signingConfigs {
        create("release") {
            keyAlias = "upload"
            keyPassword = "android"
            storeFile = releaseStoreFile
            storePassword = "android"
        }
    }

    buildTypes {
        release {
            ndk {
                debugSymbolLevel = "full"
            }
            resValue("string", "app_name", "NLP digitox")
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }

        getByName("debug") {
            resValue("string", "app_name", "NLP digitox")
            signingConfig = signingConfigs.getByName("debug")
        }

        getByName("profile") {
            resValue("string", "app_name", "NLP digitox")
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
    implementation("androidx.work:work-runtime:2.9.0")
    implementation("androidx.appcompat:appcompat:1.7.0")
}
