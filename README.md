# OpenChatAlyticsStack

[![Apache 2.0 Licensed](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](https://github.com/OpenChatAlytics/OpenChatAlyticsStack/blob/master/LICENSE.txt)

This project contains Docker build information for building and launching the full OpenChatAlytics Stack.

The main Dockerfile will run the whole stack, including the ChatAlytics platform and UI using the default persistence layer. You can find more Dockerfiles including one for setting up ChatAlytics with PostgreSQL in dockerfiles

All Dockerfiles contained in this project expect you to have the following directory structure:
```
OpenChatAlytics --|
                  |-- OpenChatAlytics
                  |
                  |-- OpenChatAlyticsUI
```
You can then build the image by running:
```
docker build -t chatalytics -f ./Dockerfile ../
```
The command above tells docker to name the image chatalytics and run the file Dockerfile and use the parent directory as the root. Since we're going to be borrowing resources from OpenChatAlytics/OpenChatAlytics and OpenChatAlytics/OpenChatAlyticsUI setting the parent directory is necessary.

To run the image and expose the UI, web and compute ports you can run the following command:
```
docker run -d -p 3001:3001 -p 8080:8080 -p 9000:9000 --name chatalytics chatalytics
```

Note that this requires ports `3001`, `8080` and `9000` to be open and available on your local machine.
OpenChatAlytics-Web should be available on `localhost:8080`, OpenChatAlytics-Compute Event Stream on `9000` and OpenChatAlyticsUI should be available on `localhost:3001`.

If you want to SSH into the container you can run the following command:
```
docker exec -i -t chatalytics bash
```
