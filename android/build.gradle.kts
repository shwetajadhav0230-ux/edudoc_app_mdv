// android/build.gradle.kts

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    // Ensure evaluation depends on :app for plugin compatibility
    afterEvaluate {
        if (project.plugins.hasPlugin("com.android.library") || project.plugins.hasPlugin("com.android.application")) {
            val android = project.extensions.findByName("android")
            try {
                val getNamespace = android?.javaClass?.getMethod("getNamespace")
                val setNamespace = android?.javaClass?.getMethod("setNamespace", String::class.java)

                val currentNamespace = getNamespace?.invoke(android)

                if (currentNamespace == null || currentNamespace.toString().isEmpty()) {
                    // This sets the namespace for the plugin to its package name or a safe default
                    val fallback = "com.example.edudoc.${project.name.replace("-", ".")}"
                    setNamespace?.invoke(android, fallback)
                    println("Applied missing namespace to ${project.name}: $fallback")
                }
            } catch (e: Exception) {
                // Ignore if method doesn't exist (older AGP versions)
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}