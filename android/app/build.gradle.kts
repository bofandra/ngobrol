plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val releaseKeystorePath = providers.environmentVariable("NGOBROL_ANDROID_KEYSTORE")
val releaseKeystorePassword = providers.environmentVariable("NGOBROL_ANDROID_STORE_PASSWORD")
val releaseKeystore = releaseKeystorePath.orNull?.takeIf { it.isNotBlank() }?.let { file(it) }

val checkReleaseSigning by tasks.registering {
    doLast {
        check(releaseKeystore?.isFile == true) {
            "Set NGOBROL_ANDROID_KEYSTORE to the Ngobrol upload keystore."
        }
        check(!releaseKeystorePassword.orNull.isNullOrBlank()) {
            "Set NGOBROL_ANDROID_STORE_PASSWORD for the Ngobrol upload keystore."
        }
    }
}

tasks.matching { it.name == "preReleaseBuild" }.configureEach {
    dependsOn(checkReleaseSigning)
}

kotlin {
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
    }
}

android {
    namespace = "com.bofandra.ngobrol"
    compileSdk = 36
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.bofandra.ngobrol"
        minSdk = 24
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            storeFile = releaseKeystore
            storeType = "PKCS12"
            storePassword = releaseKeystorePassword.orNull
            keyAlias = "ngobrol-upload"
            keyPassword = releaseKeystorePassword.orNull
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}
