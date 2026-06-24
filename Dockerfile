#base image
FROM eclipse-temurin:17-jre-jammy 

# working directory inside container
WORKDIR /app

# copy built jar
COPY target/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]