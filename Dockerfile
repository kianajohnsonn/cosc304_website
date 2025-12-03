FROM tomcat:9-jdk11

ENV CATALINA_HOME /usr/local/tomcat

# Copy the webapp into Tomcat's ROOT so the JSPs are served at /
COPY WebContent/ ${CATALINA_HOME}/webapps/ROOT/

# Copy JDBC drivers into Tomcat lib
COPY WebContent/WEB-INF/lib/mssql-jdbc-11.2.0.jre11.jar ${CATALINA_HOME}/lib/mssql-jdbc-11.2.0.jre11.jar
COPY WebContent/WEB-INF/lib/ ${CATALINA_HOME}/lib/

# Copy a small entrypoint that rewrites the Connector port to $PORT (Railway provides PORT)
COPY docker/start-tomcat.sh /usr/local/bin/start-tomcat.sh
RUN chmod +x /usr/local/bin/start-tomcat.sh

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/start-tomcat.sh"]
CMD ["run"]
