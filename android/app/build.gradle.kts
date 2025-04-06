plugins {
    id("com.android.application")
    id("com.google.gms.google-services")  // Google Services plugin
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.todo"
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
        applicationId = "com.example.todo"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // Firebase BoM (Bill of Materials) - simplifies dependency management for Firebase SDKs
    implementation(platform("com.google.firebase:firebase-bom:33.12.0"))

    // Add the Firebase SDKs you want to use, for example:
    implementation("com.google.firebase:firebase-auth")    // Firebase Authentication
    implementation("com.google.firebase:firebase-firestore")  // Firestore SDK

    // Other dependencies, if any
}

flutter {
    source = "../.."
}

apply(plugin = "com.google.gms.google-services")
