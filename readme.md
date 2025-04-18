# MSK CDC Setup

If you had to setup CDC in your Org's AWS Cloud env, how do you set it up in a production-like fashion?

Most example's I've found on the internet always end up taking shortcuts or skipping important explanations, this repo contains a setup to help you get started with CDC using MSK and MSK connect and best part? IAC with terraform is how we're doing it so you don't miss any steps. While the goal is automating the entire stack so you just run a few commans, I invite you to actually try to rip the code base apart so you understand what's happening under the hood.

## Change Data Capture

People will typically go the log-based CDC route for one of 2 reasons:

1. tracking all the intermediate changes happeing in your OLTP System (Inserts, Updates, Deletes)

2. Real time / near real time data requirements

A common tool for getting data out of database systems for CDC is Debezium and Debezium allows you consider two paths

- Using Debezium connector via Kafka and Kafka Connect

- Using Debezium application via [Debezium Server](https://debezium.io/documentation/reference/stable/operations/debezium-server.html)

The Idea with debezium is that it listens for changes in your source system and forwards it to a Queue/Broker/Intermediate destination.

There are situations where you may want to forward these messages to systems like Google cloud PubSub, AWS Kinesis, RabbitMQ, etc. If you don't want to use Debezium with Kafka then you should use Debezium server, if you intend to use Kafka then [debezium docs](https://debezium.io/documentation/reference/stable/operations/debezium-server.html) advises that you go the kafka connect route.

In this repo we will be exploring a Kafka Use case and will be using AWS MSK - Apache Kafka Provisioned by AWS. Instead of Spining up our own Kafka connect cluster we will also use MSK Connect which is an AWS managed Kafka Connect Cluster.


## Architecture
For our setup, Postgres will be the source and S3 will be the sink.

![Architecture](./assets/msk-cdc-archi.png)

We will also deploy redpanda console and Confluent schema registry on an EC2 Server. Enjoy!