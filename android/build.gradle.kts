plugins {
    id("com.android.library")
}

group = "uz.plugin.easy_pdf_viewer"
version = "1.5.0"

android {
    namespace = "uz.plugin.easy_pdf_viewer"
    compileSdk = 37

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        minSdk = 26
        consumerProguardFiles("consumer-rules.pro")
    }

    testOptions {
        unitTests.all {
            it.useJUnitPlatform()
            it.testLogging.events("passed", "skipped", "failed", "standardOut", "standardError")
            it.testLogging.showStandardStreams = true
            it.outputs.upToDateWhen { false }
        }
    }
}

// No Kotlin plugin id here on purpose: AGP 9 compiles Kotlin itself (android.builtInKotlin=true), and when the app
// turns that off the Flutter Gradle plugin applies kotlin-android to this project. Both end up with this extension.
kotlin {
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
    }
}

dependencies {
    // The JUnit 5 variant by name: AGP's built-in Kotlin does not infer it, and plain kotlin-test has no @Test there.
    testImplementation("org.jetbrains.kotlin:kotlin-test-junit5")
}
