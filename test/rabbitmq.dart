import "package:dart_amqp/dart_amqp.dart";

void publisher() async {
    // You can provide a settings object to override the
    // default connection settings
    ConnectionSettings settings = ConnectionSettings(
        host: "127.0.0.1",
        authProvider: PlainAuthenticator("guest", "guest")
    );
    Client client = Client(settings: settings);

    Channel channel = await client.channel();
    Exchange exchange = await channel.exchange("flutter-game", ExchangeType.FANOUT, durable: true);
    // exchange.bindQueueConsumer("flutter-hello", ["rabbitmq-test"], noAck: false);
    // We dont care about the routing key as our exchange type is FANOUT

    for(var i =0; i < 10; i++) {
      print("${DateTime.now().second}");
      exchange.publish("Testing ${DateTime.now().second}", null);
      await Future.delayed(const Duration(seconds: 1));
    }

    client.close();
}

Future consumer(int i) async {
  Client client = Client();

  Channel channel = await client.channel(); // auto-connect to localhost:5672 using guest credentials
  Exchange exchange = await channel.exchange("flutter-game", ExchangeType.FANOUT, durable: true);

  Queue queue = await channel.queue("flutter-hello-$i");
  queue.bind(exchange, "my_routing_key");

  Consumer consumer = await queue.consume();
  consumer.listen((AmqpMessage message) {
    // Get the payload as a string
    print(" [$i] Received string: ${message.payloadAsString}");

    // Or unserialize to json
    // print(" [x] Received json: ${message.payloadAsJson}");

    // Or just get the raw data as a Uint8List
    // print(" [x] Received raw: ${message.payload}");

    // The message object contains helper methods for
    // replying, ack-ing and rejecting
    // message.reply("world", immediate: true);
    // message.ack();
  });
}

void main() async {
  publisher();
  for(var i =0; i < 3; i++) {
    consumer(i);
  }
  await Future.delayed(const Duration(hours: 1));
}