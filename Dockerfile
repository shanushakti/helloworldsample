# Use a base image with JDK 17
FROM openjdk:17-jdk-slim as build
# Install Maven
RUN apt-get update && \
    apt-get install -y maven unzip && \
    apt-get clean
# Copy your Maven project files into the container
COPY . /app
# Set the working directory for the project
WORKDIR /app
# Build the project using Maven (skip tests if necessary)
RUN mvn -version
#RUN java -version
RUN mvn clean install

# Use a base image with liberty
FROM openliberty/open-liberty:latest

# Copy the WAR file into the Liberty server
COPY --chown=1001:0 --from=build /app/target/HelloServlet.war /config/apps/
# Copy the Liberty server configuration file into the Liberty server
COPY --chown=1001:0 --from=build /app/src/main/liberty/config/server.xml /config/

# Expose the port WebSphere Liberty will run on
EXPOSE 9080

# This script will add the requested server configurations, apply any interim fixes and populate caches to optimize runtime
RUN configure.sh
