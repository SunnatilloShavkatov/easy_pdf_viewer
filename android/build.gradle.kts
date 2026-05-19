plugins {
    id("com.android.library")
}

group = "dev.kaichi.easy_pdf_viewer"
version = "1.3.2"

android {
    namespace = "dev.kaichi.easy_pdf_viewer"
    compileSdk = 36

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlin {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        }
    }

    defaultConfig {
        minSdk = 26
    }

    android {
        testOptions {
            unitTests.all {
                it.useJUnitPlatform()
                it.testLogging.events("passed", "skipped", "failed", "standardOut", "standardError")
                it.testLogging.showStandardStreams = true
                it.outputs.upToDateWhen { false }
            }
        }
    }
}
