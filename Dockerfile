# Build stage
FROM maven:3.8.8-eclipse-temurin-17 AS build
WORKDIR /app

COPY pom.xml .
COPY src ./src
RUN mvn -B package -DskipTests

# Add a Main wrapper that prints the message and package it
RUN echo 'public class Main {' \
    'public static void main(String[] args) {' \
    'System.out.println(hello.HelloWorld.getMessage());' \
    '}}' > Main.java \
 && javac -cp target/classes -d target/classes Main.java \
 && cd target/classes \
 && jar cfe /app/app.jar Main -C . .

# Runtime stage
FROM eclipse-temurin:17-jre-jammy
WORKDIR /app
COPY --from=build /app/app.jar .
ENTRYPOINT ["java","-jar","app.jar"]
