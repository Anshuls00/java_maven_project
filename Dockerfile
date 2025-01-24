# Use Maven for building the application
FROM maven:3.8.4-openjdk-11 AS builder

WORKDIR /app

# Copy only the files needed for dependency resolution first
COPY pom.xml ./
RUN mvn dependency:go-offline -B

# Copy the rest of the application source code
COPY src ./src

# Build the application
RUN mvn clean package -DskipTests

# Use Tomcat for the runtime environment
FROM tomcat:9.0-jdk11

RUN rm -rf /usr/local/tomcat/webapps/*

# Copy the WAR file to the Tomcat webapps directory
COPY --from=builder /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

# Create a new user and adjust permissions for better security
RUN useradd -m -s /bin/bash tomcatuser && \
    chown -R tomcatuser:tomcatuser /usr/local/tomcat

USER tomcatuser

# Expose the default Tomcat port
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]

