FROM maven:3.8.4-openjdk-11 AS builder

WORKDIR /app

COPY ./.m2 /root/.m2/

COPY pom.xml .
COPY src ./src/

RUN echo '<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0" \
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" \
  xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 \
                      https://maven.apache.org/xsd/settings-1.0.0.xsd"> \
  <offline>true</offline> \
</settings>' > /usr/share/maven/conf/settings.xml

RUN mvn clean package -o -DskipTests

FROM tomcat:9.0-jdk11

RUN rm -rf /usr/local/tomcat/webapps/*

COPY --from=builder /app/target/*.war /usr/local/tomcat/webapps/ROOT.war


RUN useradd -m -s /bin/bash tomcatuser && \
    chown -R tomcatuser:tomcatuser /usr/local/tomcat

USER tomcatuser

EXPOSE 8080

CMD ["catalina.sh", "run"]
