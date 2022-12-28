const hostname = '127.0.0.1';
const port = 3000;

// const fs = require('fs')

import * as fs from 'fs'

import ForceGraph from './graph.js'

// const graph_lib = require('./graph.mjs')

let raw_data = fs.readFileSync('../dsl/bin/system_rep')
let data = JSON.parse(raw_data)

// data = { nodes: [{ id: "Pembroke" }, { id: "Building A" }], links: [{ source: "Pembroke", target: "Building A" }] }

// const express = require("express");

import express from 'express'

const PORT = process.env.PORT || 3001;

const app = express();
app.get("/api", (req, res) => {
    res.json({ message: data });
});


app.listen(PORT, () => {
    console.log(`Server listening on ${PORT}`);
});

// fs.writeFile('testSVG.svg', graph_lib.ForceGraph(data), (err) => {
//     // throws an error, you could also catch it here
//     if (err) throw err;

//     // success case, the file was saved
//     console.log('SVG written!');
// });

// const server = http.createServer((req, res) => {
//     res.statusCode = 200;
//     res.setHeader('Content-Type', 'text/plain');
//     res.end('Hello World\n');
// });

// server.listen(port, hostname, () => {
//     console.log(`Server running at http://${hostname}:${port}/`);
// });