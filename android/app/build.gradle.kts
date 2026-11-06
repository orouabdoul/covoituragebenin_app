import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.covoiturage_benin_app"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        applicationId = "com.example.covoiturage_benin_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        ndk {
            abiFilters += listOf("arm64-v8a")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    // Supprimer arm32 et x86_64 au moment du packaging (après fusion des AARs).
    // arm64-v8a couvre 99%+ des appareils Android depuis 2015.
    // Économie : ~112MB (armeabi-v7a ~42MB + x86_64 ~69MB).
    packaging {
        jniLibs {
            excludes += listOf(
                "lib/armeabi-v7a/**",
                "lib/x86_64/**"
            )
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = JvmTarget.JVM_21
    }
}

flutter {
    source = "../.."
}

// Supprime les modèles TFLite non utilisés du package face_detection_tflite avant le packaging.
// L'app utilise FaceDetectionModel.full qui charge également iris_landmark.tflite en interne.
// selfie_multiclass (16.4MB), face_blendshapes (0.9MB) et les segmenters (~0.5MB)
// ne sont jamais chargés → ~17.9MB économisés.
// NE PAS supprimer iris_landmark.tflite : face_detection_tflite le charge dans initialize().
afterEvaluate {
    tasks.matching { it.name == "packageRelease" }.configureEach {
        doFirst {
            val unusedModels = setOf(
                "selfie_multiclass.tflite",
                "face_blendshapes.tflite",
                "selfie_segmenter.tflite",
                "selfie_segmenter_landscape.tflite",
            )
            fileTree(layout.buildDirectory.dir("intermediates")) {
                include("**/packages/face_detection_tflite/assets/models/*.tflite")
            }.files
                .filter { it.name in unusedModels }
                .forEach { f ->
                    println("TFLite strip: ${f.name} (${String.format("%.1f", f.length() / 1_000_000.0)} MB)")
                    f.delete()
                }
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}
