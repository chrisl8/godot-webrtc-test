# Godot WebRTC Test

This repo is to demonstrate that I was unable to make MultiplayerSpawner work with WebRTC in Godot 4.1.1,
while they do work with ENet.

To run the code you must also use Node.js to run the signal-server.
```shell
cd signaling_server
node server.js
```

To switch between WebRTC and ENet, edit the following lines in `User.gd`:
 - 29 & 30
 - 77 & 78
 - 80 & 81
 - 83 & 84
 - 94

I apologize for the rough edges of this code. It was patched together
from various bits and rush to create a proof-of-concept.

The code is based on code from around the Internet.

The blame is all mine, the credit is all others.
