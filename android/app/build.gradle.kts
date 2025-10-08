plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "io.github.wumoye.courttimer"
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
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "io.github.wumoye.courttimer"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // 读取签名配置（CI 中通过 key.properties 注入）
    val keystoreProperties = Properties()
    val keystoreFile = rootProject.file("android/key.properties")
    if (keystoreFile.exists()) {
        keystoreFile.inputStream().use { keystoreProperties.load(it) }
    }

    buildTypes {
        release {
            // 若 key.properties 存在，则使用正式签名；否则回退到 debug 签名方便本地运行
            signingConfig = if (keystoreFile.exists()) signingConfigs.create("release").apply {
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String?
                keyAlias = keystoreProperties["keyAlias"] as String?
                keyPassword = keystoreProperties["keyPassword"] as String?
            } else signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
import java.util.Properties
