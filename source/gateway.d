module gateway;

import std.stdio;

import vibe.http.websockets : WebSocket, connectWebSocket;
import vibe.inet.url : URL;
import vibe.data.json;
import vibe.core.core;

import core.thread : Thread;
import core.time : dur, Duration;
import std.functional;

import models;

/* Base Client */
class WS_Client
{
    private
    {
        /** Websocket connection */
        WebSocket ws;
        /** Last Sequence used for resuming */
        int last_sequence = 0;
        /** Interval at which heartbeat is sent */
        Duration heartbeat_interval;
        /** Task that sents Heartbeat every `heartbeat_interval` */
        Task heartbeater;
        /** Whether Heartbeat should continue/is heartbeating */
        bool heartbeating;
        /** Websocket URL to connect to */
        string url;
    }
    /** Indicates whether client is connected */
    bool alive;

    /** WebSocket Client */
    this(string url)
    {
        this.url = url;
    }

    /** Main client's loop */
    void run(string token, uint intents)
    {
        this.ws = connectWebSocket(URL(url));
        alive = true;

        while (this.ws.waitForData())
        {
            Payload p = deserializeJson!Payload(parseJsonString(this.ws.receiveText()));
            writeln("Received: ", p.op);
            switch (p.op)
            {
            case Opcode.Dispatch:
                writeln("New event: ", p.t);
                //writeln(p.d);
                break;
            case Opcode.Hello:
                heartbeat_interval = dur!"msecs"(p.d["heartbeat_interval"].get!uint);
                heartbeating = true;
                this.heartbeater = runTask(toDelegate(&this.heartbeat));
                send(Identify(token = token, intents = intents));
                break;
            default:
                writeln("Unknown Opcode: ", p.op);
            }
        }
        writeln("Error code: ", ws.closeCode());
        writeln("Reason: ", ws.closeReason());
        writeln("Connection Closed");
        alive = false;
    }

    /** Template for casting to json and sending */
    void send(T)(auto ref T data)
    {
        string j = serializeToJsonString(data);
        writeln(j);
        this.ws.send(j);
    }

    /** Internal Heartbeat task */
    void heartbeat()
    {
        Timer waiter = createTimer(null);
        while (this.heartbeating)
        {
            waiter.rearm(this.heartbeat_interval);
            waiter.wait();
            this.send(Heartbeat(this.last_sequence));
        }
    }
}