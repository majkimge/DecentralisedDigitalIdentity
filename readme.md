### Basic info 
Currently the 3 used folders are:
- dsl - which contains the core logic of the authentication system
- server - which contains the code for serving json representation of the system to the client
- frontend/client - which is responsible for displaying the representation 

The way it works for now is that system_new.ml contains the core logical implementation of the system. Then dsl/bin/main.ml creates an example, and saves the resulting json interpretation of the system as a file. Then server/server.js sends that json to the client. Then client/src/App.js renders the SVG using a modified open source implementation of drawing force graph svgs using d3.

Run the interpreter by ```dune exec -- bin/parser/parser_main.exe```
Run the server by ```node server.js```
Run the frontend by ```npm start``` 