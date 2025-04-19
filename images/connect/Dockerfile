FROM debezium/connect:2.7.1.Final

# Set up directories and install path for confluent CLI
ENV CONFLUENT_CLI_VERSION=4.9.0
ENV CONFLUENT_CLI_INSTALL_DIR=/kafka/connect/confluent-cli
ENV PATH="${CONFLUENT_CLI_INSTALL_DIR}/:$PATH"
ENV PLUGIN_DIR=/kafka/connect
ENV CONNECT_WORKER_CONFIG=/kafka/config.orig/connect-distributed.properties

# extras
ENV AUTH_LIB_DIR=/kafka/libs
ENV SECRETS_PROVIDER_VERSION=1.0.37
ENV AWS_MSK_IAM_AUTH_VERSION=2.2.0

RUN mkdir -p $PLUGIN_DIR $CONFLUENT_CLI_INSTALL_DIR

# Install Confluent CLI
RUN ARCH=$(uname -m) && \
    [ "$ARCH" = "aarch64" ] && ARCH="arm64" || [ "$ARCH" = "x86_64" ] && ARCH="amd64" && \
    curl -L --fail -O https://packages.confluent.io/confluent-cli/archives/${CONFLUENT_CLI_VERSION}/confluent_linux_${ARCH}.tar.gz && \
    tar xzf confluent_linux_${ARCH}.tar.gz -C /tmp/ && \
    mv /tmp/confluent/confluent $CONFLUENT_CLI_INSTALL_DIR/ && \
    rm -rf /tmp/confluent confluent_linux_${ARCH}.tar.gz

# Install Avro converter plugin (fix: add worker-config file)
RUN confluent connect plugin install \
    --force \
    --plugin-directory $PLUGIN_DIR \
    --worker-configurations $CONNECT_WORKER_CONFIG \
    confluentinc/kafka-connect-avro-converter:7.5.0


# Install confluent s3 sink connector
RUN confluent connect plugin install \
    --force \
    --plugin-directory $PLUGIN_DIR \
    --worker-configurations $CONNECT_WORKER_CONFIG \
    confluentinc/kafka-connect-s3:latest

# Install confluent aws secrets config provider
RUN confluent connect plugin install \
    --force \
    --plugin-directory $PLUGIN_DIR \
    --worker-configurations $CONNECT_WORKER_CONFIG \
    confluentinc/csid-secrets-provider-aws:$SECRETS_PROVIDER_VERSION

# Install AWS MSK IAM Auth library
RUN curl -L -o $AUTH_LIB_DIR/aws-msk-iam-auth-$AWS_MSK_IAM_AUTH_VERSION-all.jar \
    https://github.com/aws/aws-msk-iam-auth/releases/download/v$AWS_MSK_IAM_AUTH_VERSION/aws-msk-iam-auth-$AWS_MSK_IAM_AUTH_VERSION-all.jar


CMD ["start"]