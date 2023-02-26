const hostname = '127.0.0.1';
const port = 3000;

// const fs = require('fs')

import * as fs from 'fs'


import * as secp from "ethereum-cryptography/secp256k1.js"
import { sha256 } from "ethereum-cryptography/sha256.js"

import { utf8ToBytes, hexToBytes, bytesToUtf8, bytesToHex } from 'ethereum-cryptography/utils.js'

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

function accountNameFromCommands(commands) {
    let lines = commands.split('\n')
    for (let i = 0; i < lines.length; i++) {
        if (lines[i].length > 0) {
            let line = lines[i];
            let tokens = line.split(' ');
            if (tokens.length < 5) {
                //ERROR
                console.error("Wrong format of the commands.")
                return ""
            } else {
                return tokens[4]
            }
        }
    }
}

function getPublicKey(name, publicKey) {
    let path = '/home/majkimge/Cambridge/DecentralisedDigitalIdentity/server/accounts.json'
    let exists = fs.existsSync(path)
    if (exists) {
        console.log("think exists")
        let accounts = fs.readFileSync(path)
        accounts = JSON.parse(accounts)
        for (let i = 0; i < accounts.length; ++i) {
            let account = accounts[i]
            if (account.name === name) {
                return account.publicKey
            }
        }
        accounts.push({ name: name, publicKey: publicKey })
        console.log("writing accounts json");
        fs.writeFileSync(path, JSON.stringify(accounts))
        return publicKey
    } else {
        let accounts = []
        accounts.push({ name: name, publicKey: publicKey })
        console.log("writing accounts json");
        fs.writeFileSync(path, JSON.stringify(accounts))
        return publicKey
    }
}

function string2Uint8Array(string) {
    let encoder = new TextEncoder();
    return encoder.encode(string);
}

function verifyCommands(commands, signedCommands, publicKey) {
    let commandsArray = string2Uint8Array(commands)
    let commandsHash = sha256(commandsArray)
    return secp.verify(signedCommands, commandsHash, publicKey)
}

app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());

app.get("/api", (req, res) => {
    res.json({ message: data });
});
app.post('/interpret', async (req, res) => {
    //var commands = req.body.commands;
    //console.log(commands);
    let name = accountNameFromCommands(req.body.commands)
    let publicKey = getPublicKey(name, req.body.publicKey)

    if (publicKey !== req.body.publicKey) {
        //ERROR
        console.error("Public key mismatch")
        res.json({ message: {} })
    } else {
        console.log(req.body.commands)
        console.log(req.body.signedCommands)
        console.log(req.body.publicKey)
        if (verifyCommands(req.body.commands, hexToBytes(req.body.signedCommands), hexToBytes(publicKey))) {
            await fs.promises.writeFile("/home/majkimge/Cambridge/DecentralisedDigitalIdentity/authentication_system/bin/parser/commands", req.body.commands)
            const { stdout, stderr } = await exec_promise("dune exec -- ../authentication_system/bin/parser/parser_main.exe")

            if (stderr) {
                console.log(`stderr: ${stderr}`);

            }
            let permission_problem = stdout.includes("No permission");
            let raw_data = fs.readFileSync('/home/majkimge/Cambridge/DecentralisedDigitalIdentity/server/system_rep')
            let data = JSON.parse(raw_data)
            console.log(`stdout: ${stdout}`);

            console.log(req.body);
            res.json({ message: data, permission_problem: permission_problem });
        } else {
            //ERROR
            console.error("Signature not verified");
            res.json({ message: {} })
        }
    }

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