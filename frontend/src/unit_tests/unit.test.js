import { key2hex, hex2key, dagWithoutExcluded, dagWithIncluded, union, onlyAttributeDag, dfs, onlyGivenCollegeDag, onlyLocationDag } from "../utils";

test("correct key from hex", () => {
    expect(hex2key("ff0a")).toStrictEqual(new Uint8Array([255, 10]))
})

test("correct hex from key", () => {
    expect(key2hex(new Uint8Array([255, 10]))).toStrictEqual("ff0a")
})

test("correctly excluded", () => {
    let dag = {
        links: [{ source: "a", target: "world", type: 'simple' }, { source: "world", target: "b", type: 'simple' }, { source: "b", target: "c", type: 'simple' }],
        nodes: [{ id: 'a', group: 'agent' }, { id: 'b', group: 'resource' }, { id: 'c', group: 'attribute' }]
    }
    let excluded_nodes = [{ id: 'b', group: 'resource' }]
    expect(dagWithoutExcluded(dag, excluded_nodes)).toStrictEqual({ "links": [{ "source": "a", "target": "world", "type": "simple" }], "nodes": [{ "group": "agent", "id": "a" }, { "group": "attribute", "id": "c" }] })
})

test("correctly included", () => {
    let dag = {
        links: [{ source: "a", target: "world", type: 'simple' }, { source: "world", target: "b", type: 'simple' }, { source: "b", target: "c", type: 'simple' }],
        nodes: [{ id: 'a', group: 'agent' }, { id: 'b', group: 'resource' }, { id: 'c', group: 'attribute' }]
    }
    let included_nodes = [{ id: 'b', group: 'resource' }];
    expect(dagWithIncluded(dag, included_nodes)).toStrictEqual({ "links": [], "nodes": [{ "group": "resource", "id": "b" }] })
})

test("correct union", () => {
    let setA = new Set([1, 2])
    let setB = new Set([2, 3])
    expect(union(setA, setB)).toStrictEqual(new Set([1, 2, 3]))
})

test("correct dfs", () => {
    let dag = {
        links: [{ source: "a", target: "world", type: 'simple' }, { source: "world", target: "b", type: 'simple' }, { source: "b", target: "c", type: 'simple' }],
        nodes: [{ id: 'a', group: 'agent' }, { id: 'b', group: 'resource' }, { id: 'c', group: 'attribute' }]
    }
    let edges = {}
    dag.links.forEach(link => {

        if (link.target in edges) { edges[link.target].push(link.source) } else { edges[link.target] = [link.source] }
    })
    let node = "b"
    expect(dfs(edges, node, new Set([]))).toStrictEqual(new Set(['world', 'b']))
})

test("scalable", () => {
    let dag = {
        links: [{ source: "a", target: "world", type: 'simple' }, { source: "world", target: "b", type: 'simple' }, { source: "b", target: "c", type: 'simple' }],
        nodes: [{ id: 'a', group: 'agent' }, { id: 'b', group: 'resource' }, { id: 'c', group: 'attribute' }]
    }

    expect(onlyGivenCollegeDag(dag, 'b')).toStrictEqual({ "links": [{ "source": "a", "target": "world", "type": "simple" }, { "source": "world", "target": "b", "type": "simple" }, { "source": "b", "target": "c", "type": "simple" }], "nodes": [] })
})

test("only location dag", () => {
    let dag = {
        links: [{ source: "a", target: "world", type: 'simple' }, { source: "world", target: "b", type: 'simple' }, { source: "b", target: "c", type: 'simple' }],
        nodes: [{ id: 'a', group: 'agent' }, { id: 'b', group: 'resource' }, { id: 'c', group: 'attribute' }]
    }

    expect(onlyLocationDag(dag)).toStrictEqual({ "links": [{ "source": "a", "target": "world", "type": "simple" }, { "source": "world", "target": "b", "type": "simple" }], "nodes": [{ "group": "agent", "id": "a" }, { "group": "resource", "id": "b" }] })
})