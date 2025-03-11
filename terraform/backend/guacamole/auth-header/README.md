# CognitoJwtAuthHeader
Guacamole has an [open source plugin](https://github.com/aiden0z/guacamole-auth-jwt) for validating JWTs. That plugin does NOT include validating AWS Cognito JWTs specifically. There is custom logic that must be done in order to pull out a username from the Cognito JWT and use it for logging into EC2 workstations. That logic is contained within this folder in this repository. It extends the open source plugin for AWS.

# Building
The jar file is built using [Gradle](https://gradle.org/). Gradle by default does not include the dependencies when building the jar file. There is a custom task that must be used to bundle the dependencies with the jar itself. This task may be run as: `gradlew fatJar`. The compiled fat jar is located at: `build/libs/`.

# System Setup
The system used to build the .jar file will need:
- OpenJDK 13
- Gradle 6.0.1
