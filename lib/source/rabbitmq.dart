import "package:dart_amqp/dart_amqp.dart";

class RabbitMQ {
  /// 放弃，库不支持web，采用长轮询
  /// 需要对rabbitmq的账号密码加密
  /// 前端发送随机数做盐，后端用盐md5加密，把账号密码发给前端
  Future consumer(String exchangeName, String queueName, String routerKey, Function(String msg) callback) async {
    // 安卓无法请求localhost，得改为本地私有网络
    ConnectionSettings settings = ConnectionSettings(
        host: "192.168.10.4",
        authProvider: PlainAuthenticator("guest", "guest")
    );
    Client client = Client(settings: settings);

    Channel channel = await client.channel(); // auto-connect to localhost:5672 using guest credentials
    Exchange exchange = await channel.exchange(exchangeName, ExchangeType.FANOUT, durable: true);

    Queue queue = await channel.queue(queueName);
    queue.bind(exchange, routerKey);

    Consumer consumer = await queue.consume();
    consumer.listen((AmqpMessage message) {
       callback(message.payloadAsString);
    });
  }
}