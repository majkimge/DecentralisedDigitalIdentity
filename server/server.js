const hostname = '127.0.0.1';
const port = 3000;

// const fs = require('fs')

import * as fs from 'fs'

import ForceGraph from './graph.js'

// const graph_lib = require('./graph.js')

let raw_data = fs.readFileSync('../authentication_system/system_rep')
let data = JSON.parse(raw_data)

// data = { nodes: [{ id: "Pembroke" }, { id: "Building A" }], links: [{ source: "Pembroke", target: "Building A" }] }

// const express = require("express");

import express from 'express'

const PORT = process.env.PORT || 3001;
const router = express.Router();
// const bodyParser = require("body-parser");
import bodyParser from 'body-parser';

const app = express();

import { exec } from 'child_process'
import * as util from 'util'
// const util = require('util')

const exec_promise = util.promisify(exec);

app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());

app.get("/api", (req, res) => {
    res.json({ message: data });
});
app.post('/interpret', async (req, res) => {
    //var commands = req.body.commands;
    //console.log(commands);
    await fs.promises.writeFile("../authentication_system/bin/parser/commands", req.body.commands)
    const { stdout, stderr } = await exec_promise("dune exec -- ../authentication_system/bin/parser/parser_main.exe")

    if (stderr) {
        console.log(`stderr: ${stderr}`);

    }
    let raw_data = fs.readFileSync('./system_rep')
    let data = JSON.parse(raw_data)
    console.log(`stdout: ${stdout}`);

    console.log(req.body);
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