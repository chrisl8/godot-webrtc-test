# Godot WebRTC Test

This repo is to demonstrate WebRTC MultiPlayer in Godot 4.1.1 with a Node.js based signalling server.

To run the code you must also use Node.js to run the signal-server.
```shell
cd signaling_server
node server.js
```

Originally this was used as a demonstration in an Issue filed for Godot which you can see here:  
https://github.com/godotengine/godot/issues/80743  
There is some good discussion there about how to make this work and possible other ideas for it.  
A big thank you to those who contributed to that discussion and provided example code to ultimately get this working.  

I apologize for the rough edges of this code. It was patched together
from various bits and rush to create a proof-of-concept.

The code is based on code from around the Internet.

The blame is all mine, the credit is all others.

A big thanks to this repo, which was the inspiration for much of this code, and deserves credit for anything brilliant in here:
https://github.com/TuysuzTavsan/GodotMultiplayerDemo
