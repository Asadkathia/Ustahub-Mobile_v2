plugins {
    // Only add plugins here that apply to the root project, if any
    // e.g. plugin management
}

allprojects {
    repositories {
        google()
        mavenCentral()
        maven {
            url = uri("https://storage.zego.im/maven")
        }
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    // Make sure evaluation order is correct if you depend on :app
    project.evaluationDependsOn(":app")
}
