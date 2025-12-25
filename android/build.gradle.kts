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
    // Only redirect build directory for local subprojects, not for external plugins from Pub cache
    // This fixes "this and base files have different roots" error on Windows when project and cache are on different drives
    afterEvaluate {
        val projectPath = project.projectDir.absolutePath
        val isLocalSubproject = projectPath.startsWith(rootProject.projectDir.absolutePath)
        
        if (isLocalSubproject) {
            val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
            project.layout.buildDirectory.value(newSubprojectBuildDir)
        }
        // External plugins (from Pub cache) keep their default build directory
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
