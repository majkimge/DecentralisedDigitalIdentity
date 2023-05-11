

import CryptoJS from "crypto-js"
import { pbkdf2Sync } from "ethereum-cryptography/pbkdf2"
import { utf8ToBytes, hexToBytes } from 'ethereum-cryptography/utils'

const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
function generateSalt(length) {
    let res = '';
    for (let i = 0; i < length; i++) {
        res += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return res;
}

function key2hex(array) {
    let res = ''
    let length = Object.keys(array).length;
    for (let i = 0; i < length; ++i) {
        res += array[i].toString(16).padStart(2, '0')
    }
    return res
}

function hex2key(hex) {
    return Uint8Array.from(hex.toString().match(/.{1,2}/g).map((byte) => parseInt(byte, 16)));
}

function dagWithoutExcluded(dagJson, excludedNodes) {
    let newNodes = dagJson.nodes.filter(node => !(excludedNodes.some(excludedNode => excludedNode.id === node.id)))
    let newLinks = dagJson.links.filter(link => !(excludedNodes.some(excludedNode => excludedNode.id === link.source || excludedNode.id === link.target)))
    return { nodes: newNodes, links: newLinks }
}

function dagWithIncluded(dagJson, includedNodes) {
    let newNodes = dagJson.nodes.filter(node => (includedNodes.some(includedNode => includedNode.id === node.id)))
    let newLinks = dagJson.links.filter(link => (includedNodes.some(includedNode => includedNode.id === link.target.id)) && (includedNodes.some(includedNode => includedNode.id === link.source.id)))
    return { nodes: newNodes, links: newLinks }
}

function onlyAttributeDag(dagJson) {
    // excludedNodes = nodeObjects.filter(node => node.group === "operator" ||node.group === "attribute" ||node.group === "attribute_handler")
    let excludedNodes = dagJson.nodes.filter(node => node.group === "resource" || node.group === "resource_handler")
    return dagWithoutExcluded(dagJson, excludedNodes)
}

function union(setA, setB) {
    const _union = new Set(setA);
    for (const elem of setB) {
        _union.add(elem);
    }
    return _union;
}

function dfs(edges, node, reachable) {
    let set = new Set()
    if (reachable.has(node) || node === "world") {
        set.add(node);
    } else {
        let neighbours = []
        if (node in edges) {
            neighbours = edges[node];
        }
        for (var i = 0; i < neighbours.length; ++i) {
            set = union(set, dfs(edges, neighbours[i], reachable));
        }
        set.add(node);
    }
    return set;
}

function onlyGivenCollegeDag(dagJson, collegeName) {
    let reachable = new Set();
    let edges = {}
    dagJson.links.forEach(link => {

        if (link.target in edges) { edges[link.target].push(link.source) } else { edges[link.target] = [link.source] }
    })
    for (var i = 0; i < dagJson.nodes.length; ++i) {
        let node = dagJson.nodes[i];
        if (dagJson.nodes[i].id.includes(collegeName)) {
            reachable = union(reachable, dfs(edges, node.id, reachable))
        }
    }
    reachable = Array.from(reachable);
    console.log(reachable);
    return dagWithIncluded(dagJson, reachable);
}

function onlyLocationDag(dagJson) {
    let excludedNodes = dagJson.nodes.filter(node => node.group === "attribute" || node.group === "attribute_handler")
    return dagWithoutExcluded(dagJson, excludedNodes)
}

function string2Uint8Array(string) {
    let encoder = new TextEncoder();
    return encoder.encode(string);
}




export { generateSalt, key2hex, hex2key, dagWithoutExcluded, dagWithIncluded, onlyAttributeDag, union, dfs, onlyGivenCollegeDag, onlyLocationDag, string2Uint8Array }