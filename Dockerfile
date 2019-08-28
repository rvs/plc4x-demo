# Apache PLC4X demo Docker file 
#
# Copyright (c) 2018 Zededa, Inc.
# SPDX-License-Identifier: Apache-2.0

FROM azul/zulu-openjdk:latest as build

RUN apt update -y
RUN apt install -y python-setuptools git unzip

ADD https://github.com/apache/plc4x/archive/d89518a48da18bd5c118f2cd68d01435c55a7480.zip /tmp
RUN unzip /tmp/d89518a48da18bd5c118f2cd68d01435c55a7480.zip ; mv /plc4x-* /ws

WORKDIR /ws
COPY *.patch /tmp/
RUN for p in /tmp/*.patch ; do patch -p1 < $p ; done

RUN ./mvnw -P with-java -DskipTests install

# Now create an actuall deployment container
FROM azul/zulu-openjdk:latest
COPY --from=build /ws/plc4j/examples/hello-storage-elasticsearch/target/*uber-jar.jar /plc4xdemo.jar

ENTRYPOINT ["sh", "-c", "java -jar /plc4xdemo.jar `cat /run/config/plc4x.options`"]
