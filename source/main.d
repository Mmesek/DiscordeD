import gateway;

void main(string[] args)
{
    auto client = new WS_Client("wss://gateway.discord.gg/?v=10&encoding=json");
    client.run(args[1], 14_271);
}
