FROM maven:3.3.3-jdk-8

ENV CHATALYTICSPARENTDIR /opt/chatalytics
ENV CHATALYTICSDIR ${CHATALYTICSPARENTDIR}/chatalytics
ENV CHATALYTICSUIDIR ${CHATALYTICSPARENTDIR}/chatalyticsui
ENV DATABASEDIR /mnt/

# Install all the necessary packages

RUN apt-get update
RUN apt-get install -y software-properties-common\
                       python-software-properties\
                       apt-transport-https

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv 68576280
RUN apt-add-repository "deb https://deb.nodesource.com/node_5.x $(lsb_release -sc) main"
RUN apt-get update
RUN apt-get install -y nodejs

RUN mkdir -p ${CHATALYTICSDIR}
RUN mkdir -p ${DATABASEDIR}

# Copy the source code
COPY OpenChatAlytics ${CHATALYTICSDIR}/code
COPY OpenChatAlyticsUI ${CHATALYTICSUIDIR}

# Setup the platform first
WORKDIR ${CHATALYTICSDIR}/code
RUN mvn clean package -Dmaven.test.skip=true
# Copy all the necessary things
RUN cp web/target/chatalytics-web-0.3-with-dependencies.jar ${CHATALYTICSDIR}
RUN cp compute/target/chatalytics-compute-0.3-with-dependencies.jar ${CHATALYTICSDIR}
RUN cp -r config ${CHATALYTICSDIR}
WORKDIR ${CHATALYTICSDIR}
RUN rm -rf code

# Now setup the UI
WORKDIR ${CHATALYTICSUIDIR}
RUN rm -rf node_modules
RUN rm -rf client/dist
RUN npm install
RUN npm run dist
ARG NODE=production
ENV NODE_ENV ${NODE}
EXPOSE 3001

# Copy over the script and start it
WORKDIR ${CHATALYTICSPARENTDIR}
COPY OpenChatAlyticsStack/bin/start-web-compute-ui.sh .
CMD ./start-web-compute-ui.sh chatalytics-local.yaml
