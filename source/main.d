import gateway;

string token;
uint intents = 14_271;

void main(string[] args)
{
    import std.getopt;
    import core.stdc.stdlib : exit;

    auto helpInfo = getopt(
        args,
        std.getopt.config.required, "token|t", "Bot token to use", &token,
        "intents|i", "Intents to start bot with", &intents,
    );

    if (helpInfo.helpWanted)
    {

        defaultGetoptPrinter("API Client for Discord", helpInfo.options);
        exit(0);
    }

    auto client = new WS_Client("wss://gateway.discord.gg/?v=10&encoding=json");
    client.run(token, intents);
}
