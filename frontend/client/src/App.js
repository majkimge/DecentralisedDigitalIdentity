import React from "react";
import "./App.css";

import { ForceGraph } from "./graph.js"
import { generateMnemonic, mnemonicToEntropy } from "ethereum-cryptography/bip39"
import { wordlist } from "ethereum-cryptography/bip39/wordlists/english"
import { HDKey } from "ethereum-cryptography/hdkey"
import { getPublicKey } from "ethereum-cryptography/secp256k1"
import * as secp from "ethereum-cryptography/secp256k1"
import { sha256 } from "ethereum-cryptography/sha256"
import secureLocalStorage from "react-secure-storage"
import CryptoJS from "crypto-js"
import { line } from "d3";
import { pbkdf2Sync } from "ethereum-cryptography/pbkdf2"
import { utf8ToBytes, hexToBytes, bytesToHex } from 'ethereum-cryptography/utils'
import { encrypt, decrypt } from "ethereum-cryptography/aes"

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

function onlyAttributeDag(dagJson) {
  // excludedNodes = nodeObjects.filter(node => node.group === "operator" ||node.group === "attribute" ||node.group === "attribute_handler")
  let excludedNodes = dagJson.nodes.filter(node => node.group === "location" || node.group === "organisation")
  return dagWithoutExcluded(dagJson, excludedNodes)
}

function onlyLocationDag(dagJson) {
  let excludedNodes = dagJson.nodes.filter(node => node.group === "attribute" || node.group === "attribute_maintainer")
  return dagWithoutExcluded(dagJson, excludedNodes)
}

function string2Uint8Array(string) {
  let encoder = new TextEncoder();
  return encoder.encode(string);
}

async function getEncryptedKey(privateKey) {
  let password = window.sessionStorage.getItem('password');
  let salt = secureLocalStorage.getItem('salt')
  console.log(password)
  console.log(salt)
  let password_key = pbkdf2Sync(utf8ToBytes(password), utf8ToBytes(salt), 131072, 16, "sha256")
  console.log(password_key);
  console.log(hexToBytes("f0f1f2f3f4f5f6f7f8f9fafbfcfdfeff"));
  let encryptedPassword = await encrypt(privateKey, password_key, hexToBytes("f0f1f2f3f4f5f6f7f8f9fafbfcfdfeff"))
  return encryptedPassword
}

async function getDecryptedKey(privateKey) {
  let password = window.sessionStorage.getItem('password');
  let salt = secureLocalStorage.getItem('salt')
  let password_key = pbkdf2Sync(utf8ToBytes(password), utf8ToBytes(salt), 131072, 16, "sha256")
  let decryptedPassword = await decrypt(privateKey, password_key, hexToBytes("f0f1f2f3f4f5f6f7f8f9fafbfcfdfeff"))
  console.log(decryptedPassword)
  return decryptedPassword
}

class EssayForm extends React.Component {
  constructor(props) {
    super(props);
    this.state = { value: 'Write your commands here' };
    this.handleChange = this.handleChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
  }

  handleChange(event) { this.setState({ value: event.target.value }); }
  accountNameFromCommands(commands) {
    let lines = commands.split('\n')
    for (let i = 0; i < lines.length; i++) {
      if (lines[i].length > 0) {
        let line = lines[i];
        let tokens = line.split(' ');
        if (tokens.length < 5) {
          alert("Wrong format of the commands.")
          return ""
        } else {
          return tokens[4]
        }
      }
    }
  }

  accountOfName(name) {
    let accounts = secureLocalStorage.getItem('accounts');
    for (let i = 0; i < accounts.length; i++) {
      if (accounts[i].name === name) {

        return accounts[i];
      }

    }
    alert("No account with that name found");
    return null;
  }


  handleSubmit(event) {
    (async () => {
      let commands = this.state.value
      let accountName = this.accountNameFromCommands(commands)
      let account = this.accountOfName(accountName)
      console.log(account)
      let password = window.sessionStorage.getItem('password')
      let privateKeyEncrypted = await account.privateKeyEncrypted;
      console.log(privateKeyEncrypted)
      let privateKey = await getDecryptedKey(hexToBytes(privateKeyEncrypted))
      let commandsArray = string2Uint8Array(commands)
      let commandsHash = sha256(commandsArray)
      let signedMessage = secp.signSync(commandsHash, privateKey)
      let publicKey = account.publicKey
      publicKey = hexToBytes(publicKey)
      console.log(secp.verify(signedMessage, commandsHash, publicKey))
      const rawResponse =
        await fetch("http://localhost:3000/interpret", {
          method: 'POST', // *GET, POST, PUT, DELETE, etc.

          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json'
            // 'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: JSON.stringify({ commands: this.state.value, signedCommands: bytesToHex(signedMessage), publicKey: bytesToHex(publicKey) }) // body data type must match "Content-Type" header
        });
      const content = await rawResponse.json();
      console.log(content);
      if (content.permission_problem) {
        alert("No permission!")
      }
      console.log(this.props.position_tree_svg.current);
      while (this.props.position_tree_svg.current.children.length > 0) {
        this.props.position_tree_svg.current.removeChild(this.props.position_tree_svg.current.children[0])
      }
      this.props.position_tree_svg.current.appendChild(ForceGraph(content.message.position_tree
        , {
          nodeId: d => d.id,
          nodeGroup: d => d.group,
          nodeTitle: d => `${d.id}\n${d.group}`,
          nodeRadius: 12,
          nodeStrength: -200,
          nodeGroups: ["operator", "organisation", "attribute", "attribute_maintainer", "location"],
          with_markers: false
        }
      ))

      while (this.props.permission_dag_svg.current.children.length > 0) {
        this.props.permission_dag_svg.current.removeChild(this.props.permission_dag_svg.current.children[0])
      }
      this.props.permission_dag_svg.current.appendChild(ForceGraph(content.message.permission_dag
        , {
          nodeId: d => d.id,
          nodeGroup: d => d.group,
          nodeTitle: d => `${d.id}\n${d.group}`,
          nodeRadius: 12,
          nodeStrength: -200,
          nodeGroups: ["operator", "organisation", "attribute", "attribute_maintainer", "location"],
          with_markers: true
        }
      ))

      while (this.props.location_permission_dag_svg.current.children.length > 0) {
        this.props.location_permission_dag_svg.current.removeChild(this.props.location_permission_dag_svg.current.children[0])
      }
      this.props.location_permission_dag_svg.current.appendChild(ForceGraph(onlyLocationDag((content.message.permission_dag))
        , {
          nodeId: d => d.id,
          nodeGroup: d => d.group,
          nodeTitle: d => `${d.id}\n${d.group}`,
          nodeRadius: 12,
          nodeStrength: -200,
          nodeGroups: ["operator", "organisation", "attribute", "attribute_maintainer", "location"]
        }
      ))

      while (this.props.attribute_permission_dag_svg.current.children.length > 0) {
        this.props.attribute_permission_dag_svg.current.removeChild(this.props.attribute_permission_dag_svg.current.children[0])
      }
      this.props.attribute_permission_dag_svg.current.appendChild(ForceGraph(onlyAttributeDag((content.message.permission_dag))
        , {
          nodeId: d => d.id,
          nodeGroup: d => d.group,
          nodeTitle: d => `${d.id}\n${d.group}`,
          nodeRadius: 12,
          nodeStrength: -200,
          nodeGroups: ["operator", "organisation", "attribute", "attribute_maintainer", "location"]
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

class Wallet extends React.Component {
  constructor(props) {
    super(props);
    this.state = { accounts: [], authenticated: false };
    this.authenticate = this.authenticate.bind(this);
    this.updateAccounts = this.updateAccounts.bind(this);
  }
  componentDidMount() {
    if (window.sessionStorage.getItem("authenticated") === 'true') {
      let accounts = [];
      if (secureLocalStorage.getItem('accounts')) {
        accounts = secureLocalStorage.getItem('accounts')
      }
      this.setState({ accounts: accounts, authenticated: true })
    }
  }
  authenticate() {
    this.setState({ ...this.state, authenticated: true })
  }

  updateAccounts(accounts) {
    this.setState({ ...this.state, accounts: accounts })
  }

  accountExists() {
    let password_hash = secureLocalStorage.getItem("password_hash")
    if (password_hash == null || password_hash === '') {
      return false
    } else {
      return true
    }
  }

  render() {
    if (!this.state.authenticated && this.accountExists()) {
      return (
        <div>
          <LoginWindow authenticate={this.authenticate} />
          or create a new account
          <RegisterWindow authenticate={this.authenticate} />
        </div>
      );
    } else if (!this.state.authenticated && !this.accountExists()) {
      return (
        <div>
          <RegisterWindow authenticate={this.authenticate} />
        </div>
      );
    } else {
      return (
        <div>
          <RestoreKeyRow updateAccounts={this.updateAccounts} />
          <AddressList accounts={this.state.accounts} />
          <AddNewKeyRow updateAccounts={this.updateAccounts} />
        </div>
      )
    }

  }
}

class AddressList extends React.Component {
  constructor(props) {
    super(props);
    this.state = { accounts: [] };
  }

  render() {
    const accounts = this.props.accounts;
    const listItems = accounts.map((d) => <li key={d.name} style={{ fontSize: 20 }}>{d.name + ": 0x" + (d.publicKey).slice(0, 5) + "..."}</li>);

    return (
      <div>
        {listItems}
      </div>
    );
  }
}

class LoginWindow extends React.Component {
  constructor(props) {
    super(props);
    this.state = { value: '' };
    this.handleChange = this.handleChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
  }
  handleChange(event) { this.setState({ value: event.target.value }); }
  handleSubmit(event) {
    const salt = secureLocalStorage.getItem("salt");
    const hashedPassword = CryptoJS.SHA3(this.state.value + salt);
    const actualHashedPassword = secureLocalStorage.getItem("password_hash");
    if (actualHashedPassword === hashedPassword) {
      window.sessionStorage.setItem("authenticated", 'true')
      window.sessionStorage.setItem("password", this.state.value)
      this.props.authenticate()
    } else {
      alert("Wrong password")
    }
    event.preventDefault();
  }

  render() {
    return (
      <div>
        Login
        <form onSubmit={this.handleSubmit}>        <label>
          Password:
          <input type="password" value={this.state.value} onChange={this.handleChange} />        </label>
          <input type="submit" value="Submit" />
        </form>
      </div>
    );
  }
}

class RegisterWindow extends React.Component {
  constructor(props) {
    super(props);
    this.state = { value: '' };
    this.handleChange = this.handleChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
  }
  handleChange(event) { this.setState({ value: event.target.value }); }
  handleSubmit(event) {
    const salt = generateSalt(10)
    secureLocalStorage.setItem("salt", salt)
    const hashedPassword = CryptoJS.SHA3(this.state.value + salt)
    secureLocalStorage.setItem("password_hash", hashedPassword)
    window.sessionStorage.setItem("authenticated", 'true')
    window.sessionStorage.setItem("password", this.state.value)
    this.props.authenticate();
    event.preventDefault();
  }

  render() {
    return (
      <div>
        Register
        <form onSubmit={this.handleSubmit}>        <label>
          Password:
          <input type="password" value={this.state.value} onChange={this.handleChange} />        </label>
          <input type="submit" value="Submit" />
        </form>
      </div>

    );
  }
}
class RestoreKeyRow extends React.Component {
  constructor(props) {
    super(props);
    this.state = { name: '', mnemonic: '' };
    this.handleChange = this.handleChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
  }
  getHdRootKey(mnemonic) {
    return HDKey.fromMasterSeed(mnemonic);
  }

  generatePrivateKey(_hdRootKey, _accountIndex) {
    return _hdRootKey.deriveChild(_accountIndex).privateKey;
  }

  handleChange(event) {
    const value = event.target.value;
    this.setState({
      ...this.state,
      [event.target.name]: value
    });
  }

  handleSubmit(event) {
    (async () => {
      let password = window.sessionStorage.getItem('password')
      const mnemonic = this.state.mnemonic

      let key = this.getHdRootKey(mnemonicToEntropy(mnemonic, wordlist));
      secureLocalStorage.setItem("master_key", JSON.stringify(key))
      let privateKey = this.generatePrivateKey(key, 0);
      let publicKey = getPublicKey(privateKey);
      let privateKeyEncrypted = await getEncryptedKey(privateKey)
      let account = { name: this.state.name, publicKey: bytesToHex(publicKey), privateKeyEncrypted: bytesToHex(privateKeyEncrypted) }
      secureLocalStorage.setItem("accounts", [account])
      this.props.updateAccounts([account]);
      event.preventDefault();
    })()
  }

  render() {
    return (
      <div style={{ fontSize: 20, borderColor: "green", borderWidth: 3, borderStyle: "solid", padding: 10, margin: 10 }}>
        Restore key from mnemonic
        <form onSubmit={this.handleSubmit}>       <label>
          Name:
          <input type="text" name='name' value={this.state.name} onChange={this.handleChange} style={{ width: 100 }} />        </label>
          <label>
            Mnemonic:
            <input type="text" name='mnemonic' value={this.state.mnemonic} onChange={this.handleChange} style={{ width: 100 }} />        </label>
          <input type="submit" value="Submit" />
        </form>
      </div>

    );
  }

}



class AddNewKeyRow extends React.Component {
  constructor(props) {
    super(props);
    this.state = { value: '' };
    this.handleChange = this.handleChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
  }


  _generateMnemonic() {
    const strength = 256; // 256 bits, 24 words; default is 128 bits, 12 words
    const mnemonic = generateMnemonic(wordlist, strength);
    const entropy = mnemonicToEntropy(mnemonic, wordlist);
    return { mnemonic, entropy };
  }
  getHdRootKey(mnemonic) {
    return HDKey.fromMasterSeed(mnemonic);
  }

  generatePrivateKey(_hdRootKey, _accountIndex) {
    return _hdRootKey.deriveChild(_accountIndex).privateKey;
  }

  handleChange(event) { this.setState({ value: event.target.value }); }

  handleSubmit(event) {
    (async () => {
      let accountList = secureLocalStorage.getItem('accounts')
      console.log(accountList)
      let password = window.sessionStorage.getItem('password')
      if (accountList === null || accountList.length === 0) {
        let mnemonic, entropy;
        ({ mnemonic, entropy } = this._generateMnemonic());
        let key = this.getHdRootKey(entropy);
        console.log(key)
        secureLocalStorage.setItem("master_key", JSON.stringify(key))
        let privateKey = this.generatePrivateKey(key, 0);
        let publicKey = getPublicKey(privateKey);
        console.log(privateKey)

        alert("This is your mnemonic:\n" + mnemonic + "\nNote it down and you will be able to recover your keys if you forget your password or change a device.")
        let privateKeyEncrypted = await getEncryptedKey(privateKey)
        let account = { name: this.state.value, publicKey: bytesToHex(publicKey), privateKeyEncrypted: bytesToHex(privateKeyEncrypted) }
        secureLocalStorage.setItem("accounts", [account])
        this.props.updateAccounts([account]);
      } else {
        let key = JSON.parse(secureLocalStorage.getItem('master_key'));
        key = HDKey.fromJSON(key)
        console.log(key)
        let privateKey = this.generatePrivateKey(key, accountList.length);
        let publicKey = getPublicKey(privateKey);
        console.log(privateKey)
        let testArray = new Uint8Array(1);
        console.log(privateKey)
        let privateKeyEncrypted = await getEncryptedKey(privateKey)
        let account = { name: this.state.value, publicKey: bytesToHex(publicKey), privateKeyEncrypted: bytesToHex(privateKeyEncrypted) }
        accountList.push(account);
        secureLocalStorage.setItem("accounts", accountList)
        this.props.updateAccounts(accountList);
      }
    })()



    event.preventDefault();
  }

  render() {
    return (
      <div style={{ fontSize: 20, borderColor: "green", borderWidth: 3, borderStyle: "solid", padding: 10, margin: 10 }}>
        Add new account
        <form onSubmit={this.handleSubmit}>        <label>
          Name:
          <input type="text" value={this.state.value} onChange={this.handleChange} />        </label>
          <input type="submit" value="Submit" />
        </form>
      </div>

    );
  }

}

function App() {
  // let data1 = { nodes: [{ id: "Pembroke" }, { id: "Building A" }], links: [{ source: "Pembroke", target: "Building A" }] };
  // let data2 = { "id": "root", "children": [{ "id": "locationA", "children": [{ "id": "root#1", "children": [] }] }, { "id": "admin", "children": [] }] }


  const position_tree_svg = React.useRef(null);
  const permission_dag_svg = React.useRef(null);
  const attribute_permission_dag_svg = React.useRef(null);
  const location_permission_dag_svg = React.useRef(null);

  return (
    <div className="App">
      <header className="App-header">

        <div style={{ display: "flex" }}>
          <div style={{ flex: 5 }}>

            <EssayForm position_tree_svg={position_tree_svg} permission_dag_svg={permission_dag_svg} attribute_permission_dag_svg={attribute_permission_dag_svg} location_permission_dag_svg={location_permission_dag_svg} />
          </div>
          <div style={{ flex: 5 }}>

            <Wallet />
          </div>
        </div>
        Position tree
        <div ref={position_tree_svg} />
        <div style={{ display: "flex" }}>

          <div style={{ flex: 3 }}>
            Location Permissions
            <div ref={location_permission_dag_svg} /></div>

          <div style={{ flex: 3 }}>
            All Permissions
            <div ref={permission_dag_svg} />
          </div>

          <div style={{ flex: 3 }}>
            Identity Attributes
            <div ref={attribute_permission_dag_svg} /></div>
        </div>
      </header>
    </div>
  );
}

export default App;
