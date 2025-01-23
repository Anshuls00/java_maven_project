FROM maven:3.8.4-openjdk-11 AS builder
WORKDIR /app
COPY pom.xml .
COPY src ./src/
RUN mvn dependency:resolve
RUN mvn clean package -DskipTests

FROM tomcat:9.0-jdk11
RUN rm -rf /usr/local/tomcat/webapps/*
COPY --from=builder /app/target/*.war /usr/local/tomcat/webapps/ROOT.war
RUN useradd -m -s /bin/bash tomcatuser && \
    chown -R tomcatuser:tomcatuser /usr/local/tomcat
USER tomcatuser
EXPOSE 8080
CMD ["catalina.sh", "run"]
