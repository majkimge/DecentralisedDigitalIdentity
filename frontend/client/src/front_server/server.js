const hostname = '127.0.0.1';
const port = 3003;

const fs = require('fs')





// const graph_lib = require('./graph.js')


// data = { nodes: [{ id: "Pembroke" }, { id: "Building A" }], links: [{ source: "Pembroke", target: "Building A" }] }

const express = require("express");

// import express from 'express'

const PORT = process.env.PORT || 3001;
const router = express.Router();
const bodyParser = require("body-parser");
// import bodyParser from 'body-parser';

const app = express();

const { exec } = require('child_process')
// import * as util from 'util'
const util = require('util')

const exec_promise = util.promisify(exec);

app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());


app.post('/check', async (req, res) => {
    console.log(req.body.commands)
    console.log(req.body.signedCommands)
    console.log(req.body.publicKey)

    await fs.promises.writeFile("/home/majkimge/Cambridge/DecentralisedDigitalIdentity/frontend/client/src/bin/commands", req.body.commands)
    const { stdout, stderr } = await exec_promise("dune exec -- ../bin/string_parser.exe")
    if (stdout) {
        console.log(`stderr: ${stdout}`);
    }
    res.json({ error: stdout });
});

app.listen(3003, () => {
    console.log(`Server listening on ${3003}`);
});

