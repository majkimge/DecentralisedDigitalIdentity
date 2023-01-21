import React from "react";
import ReactDOM from "react-dom";
import logo from "./logo.svg";
import "./App.css";

import { ForceGraph, ForceTree } from "./graph.js"
import { svg } from "d3";

class EssayForm extends React.Component {
  constructor(props) {
    super(props);
    this.state = { value: 'Write your commands here' };
    this.handleChange = this.handleChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
  }

  handleChange(event) { this.setState({ value: event.target.value }); }
  handleSubmit(event) {
    (async () => {
      const rawResponse =
        await fetch("http://localhost:3000/interpret", {
          method: 'POST', // *GET, POST, PUT, DELETE, etc.

          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json'
            // 'Content-Type': 'application/x-www-form-urlencoded',
          },

          body: JSON.stringify({ commands: this.state.value }) // body data type must match "Content-Type" header
        });
      const content = await rawResponse.json();
      console.log(content);
      console.log(this.props.position_tree_svg.current);
      while (this.props.position_tree_svg.current.children.length > 0) {
        this.props.position_tree_svg.current.removeChild(this.props.position_tree_svg.current.children[0])
      }
      this.props.position_tree_svg.current.appendChild(ForceGraph(content.message.position_tree
        , {
          nodeId: d => d.id,
          nodeGroup: d => d.group,
          nodeTitle: d => `${d.id}\n${d.group}`
        }
      ))

      while (this.props.permission_dag_svg.current.children.length > 0) {
        this.props.permission_dag_svg.current.removeChild(this.props.permission_dag_svg.current.children[0])
      }
      this.props.permission_dag_svg.current.appendChild(ForceGraph(content.message.permission_dag
        , {
          nodeId: d => d.id,
          nodeGroup: d => d.group,
          nodeTitle: d => `${d.id}\n${d.group}`
        }
      ))
    })();
    // return response.json(); // parses JSON response into native JavaScript objects
    //   alert('Commands submitted ' + this.state.value);
    event.preventDefault();
  }

  render() {
    return (
      <form onSubmit={this.handleSubmit}>
        <label>

          <textarea value={this.state.value} onChange={this.handleChange} rows={10} style={{ width: 500 }} />        </label>
        <input type="submit" value="Submit" />
      </form>
    );
  }
}

function App() {
  let data1 = { nodes: [{ id: "Pembroke" }, { id: "Building A" }], links: [{ source: "Pembroke", target: "Building A" }] };
  let data2 = { "id": "root", "children": [{ "id": "locationA", "children": [{ "id": "root#1", "children": [] }] }, { "id": "admin", "children": [] }] }

  console.log(ForceTree(data2))
  const [data, setData] = React.useState(null);

  const position_tree_svg = React.useRef(null);
  const permission_dag_svg = React.useRef(null);
  // React.useEffect(() => {
  //   console.log(svg.current)
  //   if (svg.current) {
  //     if (!data) {
  //       svg.current.appendChild(ForceGraph(data1))
  //     } else {

  //       svg.current.appendChild(ForceGraph(data))
  //     }
  //   }
  // }, []);

  // React.useEffect(() => {
  //   fetch("http://localhost:3000/api")
  //     .then((res) => res.json())
  //     .then((data) => {
  //       if (svg.current) {
  //         console.log(data.message);
  //         svg.current.appendChild(ForceGraph(data.message.position_tree
  //           , {
  //             nodeId: d => d.id,
  //             nodeGroup: d => d.group,
  //             nodeTitle: d => `${d.id}\n${d.group}`
  //           }
  //         ))
  //       }
  //     });
  // }, []);
  // ReactDOM.render(<div>{ForceGraph(data1)}</div>, document.getElementById('root'));
  return (
    <div className="App">
      <header className="App-header">
        {/* <img src={ForceGraph(data)} className="App-logo" alt="logo" /> */}
        {/* {ForceGraph(data1)} */}
        {/* <p>{!data ? "Loading..." : data}</p> */}
        <EssayForm position_tree_svg={position_tree_svg} permission_dag_svg={permission_dag_svg} />
        <div ref={position_tree_svg} />
        <div ref={permission_dag_svg} />
      </header>
    </div>
  );
}

export default App;
