import * as d3 from "d3"

// Copyright 2021 Observable, Inc.
// Released under the ISC license.
// https://observablehq.com/@d3/force-directed-graph
export function ForceGraph({
  nodes, // an iterable of node objects (typically [{id}, …])
  links // an iterable of link objects (typically [{source, target}, …])
}, {
  nodeId = d => d.id, // given d in nodes, returns a unique identifier (string)
  nodeGroup, // given d in nodes, returns an (ordinal) value for color
  nodeGroups, // an array of ordinal values representing the node groups
  nodeTitle, // given d in nodes, a title string
  nodeFill = "currentColor", // node stroke fill (if not using a group color encoding)
  nodeStroke = "#fff", // node stroke color
  nodeStrokeWidth = 1.5, // node stroke width, in pixels
  nodeStrokeOpacity = 1, // node stroke opacity
  nodeRadius = 5, // node radius, in pixels
  nodeStrength,
  linkSource = ({ source }) => source, // given d in links, returns a node identifier string
  linkTarget = ({ target }) => target, // given d in links, returns a node identifier string
  linkStroke = "#999", // link stroke color
  linkStrokeOpacity = 0.6, // link stroke opacity
  linkStrokeWidth = 0.5, // given d in links, returns a stroke width in pixels
  linkStrokeLinecap = "round", // link stroke linecap
  linkStrength,
  colors = d3.schemeTableau10, // an array of color strings, for the node groups
  width = 640, // outer width, in pixels
  height = 400, // outer height, in pixels
  with_markers = true,
  withText = true,
  invalidation // when this promise resolves, stop the simulation
} = {}) {
  // Compute values.
  const N = d3.map(nodes, nodeId).map(intern);
  const LS = d3.map(links, linkSource).map(intern);
  const LT = d3.map(links, linkTarget).map(intern);
  if (nodeTitle === undefined) nodeTitle = (_, i) => N[i];
  const T = nodeTitle == null ? null : d3.map(nodes, nodeTitle);
  const G = nodeGroup == null ? null : d3.map(nodes, nodeGroup).map(intern);
  const W = typeof linkStrokeWidth !== "function" ? null : d3.map(links, linkStrokeWidth);
  const L = typeof linkStroke !== "function" ? null : d3.map(links, linkStroke);

  // Replace the input nodes and links with mutable objects for the simulation.
  nodes = d3.map(nodes, (_, i) => ({ id: N[i] }));
  links = d3.map(links, (_, i) => ({ source: LS[i], target: LT[i] }));

  // Compute default domains.
  if (G && nodeGroups === undefined) nodeGroups = d3.sort(G);

  // Construct the scales.
  const color = nodeGroup == null ? null : d3.scaleOrdinal(nodeGroups, colors);

  // Construct the forces.
  const forceNode = d3.forceManyBody();
  const forceLink = d3.forceLink(links).id(({ index: i }) => N[i]);
  if (nodeStrength !== undefined) forceNode.strength(nodeStrength);
  if (linkStrength !== undefined) forceLink.strength(linkStrength);

  const simulation = d3.forceSimulation(nodes)
    .force("link", forceLink)
    .force("charge", forceNode)
    .force("center", d3.forceCenter())
    .on("tick", ticked);

  const svg = d3.create("svg")
    .attr("width", width)
    .attr("height", height)
    .attr("viewBox", [-width / 2, -height / 2, width, height])
    .attr("style", "max-width: 100%; height: auto; height: intrinsic;");

  const link = svg.append("g")
    .attr("stroke", typeof linkStroke !== "function" ? linkStroke : null)
    .attr("stroke-opacity", linkStrokeOpacity)
    .attr("stroke-width", typeof linkStrokeWidth !== "function" ? linkStrokeWidth : null)
    .attr("stroke-linecap", linkStrokeLinecap)
    .attr("marker-end", function (d) { return with_markers ? "url(#arrowhead)" : "" })
    .selectAll("line")
    .data(links)
    .join("line");

  const defs = svg.append("defs")

  let markerWidth = 15;
  let markerHeight = 10;
  // if (!with_markers) {
  //   markerHeight = 0;
  //   markerWidth = 0;
  // } else {
  //   markerHeight = 10;
  //   markerWidth = 15;
  // }

  const marker = defs.append("marker")
    .attr("id", "arrowhead")
    .attr("markerWidth", markerWidth)
    .attr("markerHeight", markerHeight)
    .attr("refX", 14).attr("refY", 2)
    .attr("orient", "auto")
    .append("polygon")
    .attr("points", "0 0, 4 2, 0 4")
    .style("fill", "grey")

  const node = svg.append("g")
    .attr("fill", nodeFill)
    .attr("stroke", nodeStroke)
    .attr("stroke-opacity", nodeStrokeOpacity)
    .attr("stroke-width", nodeStrokeWidth)
    .selectAll("circle")
    .data(nodes)
    .join("circle")
    .attr("r", nodeRadius)
    .call(drag(simulation));
  //Comment for big
  const text = svg.append("g")
    .selectAll("text")
    .data(nodes)
    .join("text")
    .attr("fill", "white")
    .attr("font-family", "Arial")
    .style("font-size", "12px")
    .style("paint-order", "stroke")
    .style("stroke", "black")
    .style("stroke-width", "2px")
    .text(function (d) { if (withText) { return nodeTitle(d).split("\n")[0] } else return "" });

  node.append("text")
    .attr("dx", 12)
    .attr("dy", ".35em")
    .text(function (d) { if (withText) { return nodeTitle(d).split("\n")[0] } else return "" });

  if (W) link.attr("stroke-width", ({ index: i }) => W[i]);
  if (L) link.attr("stroke", ({ index: i }) => L[i]);
  if (G) node.attr("fill", ({ index: i }) => color(G[i]));
  if (T) node.append("title").text(({ index: i }) => T[i]);
  if (invalidation != null) invalidation.then(() => simulation.stop());

  function intern(value) {
    return value !== null && typeof value === "object" ? value.valueOf() : value;
  }

  function ticked() {
    link
      .attr("x1", d => d.source.x)
      .attr("y1", d => d.source.y)
      .attr("x2", d => d.target.x)
      .attr("y2", d => d.target.y);

    node
      .attr("cx", d => d.x)
      .attr("cy", d => d.y)
      .attr("fy", d => { if (d.id == 'root') { return 0 } else { return null } });
    //comment for big
    text
      .attr("x", d => d.x + 15)
      .attr("y", d => d.y);

  }

  function drag(simulation) {
    function dragstarted(event) {
      if (!event.active) simulation.alphaTarget(0.3).restart();
      event.subject.fx = event.subject.x;
      event.subject.fy = event.subject.y;
    }

    function dragged(event) {
      event.subject.fx = event.x;
      event.subject.fy = event.y;
    }

    function dragended(event) {
      if (!event.active) simulation.alphaTarget(0);
      event.subject.fx = null;
      event.subject.fy = null;
    }

    return d3.drag()
      .on("start", dragstarted)
      .on("drag", dragged)
      .on("end", dragended);
  }

  return Object.assign(svg.node(), { scales: { color } });
}


// export function ForceTree(data) {
//   const drag = simulation => {

//     function dragstarted(event, d) {
//       if (!event.active) simulation.alphaTarget(0.3).restart();
//       d.fx = d.x;
//       d.fy = d.y;
//     }

//     function dragged(event, d) {
//       d.fx = event.x;
//       d.fy = event.y;
//     }

//     function dragended(event, d) {
//       if (!event.active) simulation.alphaTarget(0);
//       d.fx = null;
//       d.fy = null;
//     }

//     return d3.drag()
//       .on("start", dragstarted)
//       .on("drag", dragged)
//       .on("end", dragended);
//   }

//   const height = 400
//   const width = 640

//   const root = d3.hierarchy(data);
//   const links = root.links();
//   const nodes = root.descendants();

//   const simulation = d3.forceSimulation(nodes)
//     .force("link", d3.forceLink(links).id(d => d.id).distance(0).strength(1))
//     .force("charge", d3.forceManyBody().strength(-50))
//     .force("x", d3.forceX())
//     .force("y", d3.forceY());

//   const svg = d3.create("svg")
//     .attr("width", width)
//     .attr("height", height)
//     .attr("viewBox", [-width / 2, -height / 2, width, height])
//     .attr("style", "max-width: 100%; height: auto; height: intrinsic;");

//   const link = svg.append("g")
//     .attr("stroke", "#999")
//     .attr("stroke-opacity", 0.6)
//     .selectAll("line")
//     .data(links)
//     .join("line");

//   const node = svg.append("g")
//     .attr("fill", "#fff")
//     .attr("stroke", "#000")
//     .attr("stroke-width", 1.5)
//     .selectAll("circle")
//     .data(nodes)
//     .join("circle")
//     .attr("fill", d => d.children ? null : "#000")
//     .attr("stroke", d => d.children ? null : "#fff")
//     .attr("r", 6)
//     .attr("class", d => {
//       return d.group;
//     })
//     .call(drag(simulation));


//   d3.selectAll(".operator").append("rect")
//     .attr("width", window.nodeWidth)
//     .attr("height", window.nodeHeight)
//     .attr("class", function (d) {
//       return "color_" + d.group
//     });


//   node.append("title")
//     .text(d => d.data.id);

//   simulation.on("tick", () => {
//     link
//       .attr("x1", d => d.source.x)
//       .attr("y1", d => d.source.y)
//       .attr("x2", d => d.target.x)
//       .attr("y2", d => d.target.y);

//     node
//       .attr("cx", d => d.x)
//       .attr("cy", d => d.y);
//   });


//   return svg.node();
// }

// // data = { nodes: [{ id: "Pembroke" }, { id: "Building A" }], links: [{ source: "Pembroke", target: "Building A" }] }

// // ForceGraph(data)