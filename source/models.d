module models;
import std.typecons;
import vibe.data.json;

enum Opcode
{
    Dispatch = 0,
    Heartbeat = 1,
    Identify = 2,
    PresenceUpdate = 3,
    VoiceStateUpdate = 4,
    Resume = 6,
    Reconnect = 7,
    RequestGuildMembers = 8,
    InvalidSession = 9,
    Hello = 10,
    HeartbeatACK = 11
}

/** Generic payload that is received */
struct Payload
{
    /** Opcode of this Payload */
    Opcode op;
    /** Payload's Data */
    Json d;
    /** Sequence Number. Null if Opcode is not 0 */
    Nullable!uint s;
    /** Event Type. Null if Opcode is not 0 */
    Nullable!string t;
}

/** Heartbeat payload */
struct Heartbeat
{
    Opcode op = Opcode.Heartbeat;
    uint d = 0;
    this(uint d)
    {
        d = d;
    }
}

/** Connection metadata */
struct IdentifyConnection
{
    string os = "Windows";
    string browser = "DiscordeD";
    string device = "DiscordeD";
}

/** Presence settings of client */
struct Presence
{
    uint since;
    string status;
    bool afk;
}

/** Identify Data payload */
struct IdentifyData
{
    bool compress = false;
    uint large_threshold = 50;
    uint intents;
    string token;
    IdentifyConnection properties;
    //Nullable!uint[2] shard;
    //Nullable!Presence presence;
    /*this(string token, uint intents)
    {
        this.token = token;
        this.intents = intents;
    }*/
}

/** Identify Payload to send after receiving Hello */
struct Identify
{
    Opcode op = Opcode.Identify;
    IdentifyData d;
    this(string token, uint intents, uint large_threshold = 50, bool compress = false)
    {
        this.d = IdentifyData(compress = compress, large_threshold = large_threshold, intents = intents, token = token);
    }
}
