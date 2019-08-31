# Apache PLC4X demo Docker file 
#
# Copyright (c) 2018 Zededa, Inc.
# SPDX-License-Identifier: Apache-2.0

FROM azul/zulu-openjdk:latest as build

RUN apt update -y
RUN apt install -y python-setuptools git unzip

ADD https://github.com/apache/plc4x/archive/7275c4f1918381c42fc48a8efe69f5beb678804d.zip /tmp/s.zip
RUN unzip /tmp/s.zip ; mv /plc4x-* /ws

WORKDIR /ws
COPY *.patch /tmp/
RUN for p in /tmp/*.patch ; do patch -p1 < $p ; done

RUN ./mvnw -P with-java -DskipTests install

# Now create an actuall deployment container
FROM azul/zulu-openjdk:latest
COPY --from=build /ws/plc4j/examples/hello-storage-elasticsearch/target/*uber-jar.jar /plc4xdemo.jar

ENTRYPOINT ["sh", "-c", "java -jar /plc4xdemo.jar `cat /run/config/plc4x/options`"]
