FROM openjdk:11-jre-slim

# Set environment variables
ENV SPARK_VERSION=3.5.1
ENV HADOOP_VERSION=3.3.4
ENV ICEBERG_VERSION=1.4.2
ENV AWS_SDK_VERSION=1.12.581

# Install necessary tools
RUN apt-get update && apt-get install -y curl wget procps rsync ssh

# Download and install Spark
RUN wget https://downloads.apache.org/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop3.tgz && \
    tar -xvzf spark-${SPARK_VERSION}-bin-hadoop3.tgz && \
    mv spark-${SPARK_VERSION}-bin-hadoop3 /spark && \
    rm spark-${SPARK_VERSION}-bin-hadoop3.tgz

# Set Spark environment variables
ENV SPARK_HOME=/spark
ENV PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin

# Download necessary JARs
RUN mkdir -p /spark/jars && \
    wget https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-spark-runtime-3.5_2.12/${ICEBERG_VERSION}/iceberg-spark-runtime-3.5_2.12-${ICEBERG_VERSION}.jar -O /spark/jars/iceberg-spark-runtime.jar && \
    wget https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-aws-bundle/${ICEBERG_VERSION}/iceberg-aws-bundle-${ICEBERG_VERSION}.jar -O /spark/jars/iceberg-aws-bundle.jar && \
    wget https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/${HADOOP_VERSION}/hadoop-aws-${HADOOP_VERSION}.jar -O /spark/jars/hadoop-aws.jar && \
    wget https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/${AWS_SDK_VERSION}/aws-java-sdk-bundle-${AWS_SDK_VERSION}.jar -O /spark/jars/aws-java-sdk-bundle.jar

# Create directory for Spark events
RUN mkdir -p /tmp/spark-events

WORKDIR /spark

CMD ["bash"]