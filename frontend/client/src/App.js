import React from "react";
import ReactDOM from "react-dom";
import logo from "./logo.svg";
import "./App.css";

import { ForceGraph, ForceTree } from "./graph.js"

function App() {
  let data1 = { nodes: [{ id: "Pembroke" }, { id: "Building A" }], links: [{ source: "Pembroke", target: "Building A" }] };
  let data2 = { "id": "root", "children": [{ "id": "locationA", "children": [{ "id": "root#1", "children": [] }] }, { "id": "admin", "children": [] }] }

  console.log(ForceTree(data2))
  const [data, setData] = React.useState(null);

  const svg = React.useRef(null);
  // React.useEffect(() => {
  //   if (svg.current) {
  //     if (!data) {
  //       svg.current.appendChild(ForceGraph(data1))
  //     } else {

  //       svg.current.appendChild(ForceGraph(data))
  //     }
  //   }
  // }, []);

  React.useEffect(() => {
    fetch("/api")
      .then((res) => res.json())
      .then((data) => {
        if (svg.current) {
          console.log(data.message);
          svg.current.appendChild(ForceGraph(data.message.position_tree
            , {
              nodeId: d => d.id,
              nodeGroup: d => d.group,
              nodeTitle: d => `${d.id}\n${d.group}`
            }
          ))
        }
      });
  }, []);
  // ReactDOM.render(<div>{ForceGraph(data1)}</div>, document.getElementById('root'));
  return (
    <div className="App">
      <header className="App-header">
        {/* <img src={ForceGraph(data)} className="App-logo" alt="logo" /> */}
        {/* {ForceGraph(data1)} */}
        {/* <p>{!data ? "Loading..." : data}</p> */}
        <div ref={svg} />
      </header>
    </div>
  );
}

export default App;
