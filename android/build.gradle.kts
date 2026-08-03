allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
        val android = project.extensions.findByName("android") as? com.android.build.gradle.BaseExtension
        android?.let {
            val targetCompatibility = it.compileOptions.targetCompatibility
            val jvmTargetStr = targetCompatibility.toString()
            compilerOptions {
                when (jvmTargetStr) {
                    "17", "VERSION_17" -> jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
                    "11", "VERSION_11" -> jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_11)
                    else -> jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_1_8)
                }
            }
        }
    }
}







tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
