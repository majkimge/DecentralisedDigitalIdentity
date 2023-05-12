import React, { useState } from "react";
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
import { csvParse, line } from "d3";
import { pbkdf2Sync } from "ethereum-cryptography/pbkdf2"
import { utf8ToBytes, hexToBytes, bytesToHex } from 'ethereum-cryptography/utils'
// import { encrypt, decrypt } from "ethereum-cryptography/aes"
import { generateSalt, key2hex, hex2key, dagWithoutExcluded, dagWithIncluded, onlyAttributeDag, union, dfs, onlyGivenCollegeDag, onlyLocationDag, string2Uint8Array } from "./utils";


const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';

const bigStrengthConst = -5 //-200 for actual, -20 for big
const bigNodeRadiusConst = 10 //15 for actual, 10 for big
const withMarkersForPermissions = true //true for actual, false for big
const strengthConsts = [-5, -200]
const nodeRadiusConsts = [10, 15]
function passwordHash(password) {
  let salt = ""
  try {
    salt = secureLocalStorage.getItem("salt")
  } catch (err) {
    salt = localStorage.getItem("salt")
  }
  return CryptoJS.SHA3(password + salt);
}

function getProtectedItem(itemName) {
  let password = window.sessionStorage.getItem('password');
  let hashedPassword = passwordHash(password)
  try {
    return secureLocalStorage.getItem(itemName + hashedPassword)
  } catch (err) {

    return localStorage.getItem(itemName + hashedPassword)
  }
}

async function getEncryptedKey(privateKey) {
  let password = window.sessionStorage.getItem('password');
  let salt = ""
  try {
    salt = secureLocalStorage.getItem("salt")
  } catch (err) {
    salt = localStorage.getItem("salt")
  }
  console.log(password)
  console.log(salt)
  let password_key = pbkdf2Sync(utf8ToBytes(password), utf8ToBytes(salt), 131072, 16, "sha256")
  console.log(password_key);
  console.log(hexToBytes("f0f1f2f3f4f5f6f7f8f9fafbfcfdfeff"));
  // let encryptedPassword = encrypt(privateKey, password_key, hexToBytes("f0f1f2f3f4f5f6f7f8f9fafbfcfdfeff"))
  console.log("private key before encryption")
  console.log(key2hex(privateKey))
  console.log((CryptoJS.AES.decrypt(CryptoJS.AES.encrypt('abcxx', key2hex(password_key)), key2hex(password_key))).toString(CryptoJS.enc.Utf8))
  let encryptedPassword = CryptoJS.AES.encrypt(key2hex(privateKey), key2hex(password_key))
  console.log("private key after decryption")
  console.log((CryptoJS.AES.decrypt(encryptedPassword, key2hex(password_key))).toString(CryptoJS.enc.Utf8))
  // secureLocalStorage.setItem("testing", encryptedPassword.)
  // let retrievedEncrypted = secureLocalStorage.getItem("testing")
  // console.log((CryptoJS.AES.decrypt(encryptedPassword.toString(), key2hex(password_key))).toString(CryptoJS.enc.Utf8))
  return encryptedPassword.toString()
}

async function getDecryptedKey(privateKey) {
  let password = window.sessionStorage.getItem('password');
  let salt = ""
  try {
    salt = secureLocalStorage.getItem("salt")
  } catch (err) {
    salt = localStorage.getItem("salt")
  }
  let password_key = pbkdf2Sync(utf8ToBytes(password), utf8ToBytes(salt), 131072, 16, "sha256")
  // let decryptedPassword = await decrypt(privateKey, password_key, hexToBytes("f0f1f2f3f4f5f6f7f8f9fafbfcfdfeff"))
  let decryptedPassword = CryptoJS.AES.decrypt(privateKey, key2hex(password_key)).toString(CryptoJS.enc.Utf8)
  console.log(decryptedPassword)
  return hex2key(decryptedPassword)
}
class EssayForm extends React.Component {
  constructor(props) {
    super(props);
    this.state = { value: 'Write your commands here', parses: false };
    this.handleChange = this.handleChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
  }

  handleChange(event) {

    this.setState({ ...this.state, value: event.target.value });
  }
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
    let accounts = getProtectedItem('accounts');
    for (let i = 0; i < accounts.length; i++) {
      console.log("acc name")
      console.log(accounts[i].name)
      if (accounts[i].name === name) {
        console.log("found")
        return accounts[i];
      }

    }
    return null;
  }

  nameOfAdress(address) {
    let accounts = getProtectedItem('accounts');
    for (let i = 0; i < accounts.length; i++) {
      if (accounts[i].publicKey === address) {

        return accounts[i].name;
      }
    }
    return address;
  }

  codeWithAddresses(commands, accounts) {
    let lines = commands.split('\n')
    for (let i = 0; i < lines.length; ++i) {
      let words = lines[i].split(" ")
      for (let j = 0; j < words.length; ++j) {
        let word = words[j]
        for (let k = 0; k < accounts.length; ++k) {
          let account = accounts[k]
          if (word === account.name) {
            words[j] = account.publicKey
          }
        }
      }
      lines[i] = words.join(" ")
    }
    return lines.join("\n")
  }

  handleSubmit(event) {
    (async () => {
      let commands1 = this.state.value
      let accounts1 = getProtectedItem('accounts');
      let commandsSubbed1 = this.codeWithAddresses(commands1, accounts1)
      const rawResponse1 =
        await fetch("/check", {
          method: 'POST', // *GET, POST, PUT, DELETE, etc.

          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json'
            // 'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: JSON.stringify({ commands: commandsSubbed1 }) // body data type must match "Content-Type" header
        });
      const content1 = await rawResponse1.json();
      let parses = true
      if (content1.error.includes("false")) {
        console.log(content1.error)
        parses = false
      }
      console.log(content1)
      if (parses) {


        let commands = this.state.value
        let accountName = this.accountNameFromCommands(commands)
        let account = this.accountOfName(accountName)
        if (!account) {

          alert("No account with that name found");
        } else {
          console.log(account)
          let password = window.sessionStorage.getItem('password')
          let privateKeyEncrypted = await account.privateKeyEncrypted;
          console.log(privateKeyEncrypted)
          let privateKey = await getDecryptedKey(privateKeyEncrypted)
          let accounts = getProtectedItem('accounts');
          let commandsSubbed = this.codeWithAddresses(commands, accounts)
          let commandsArray = string2Uint8Array(commandsSubbed)
          let commandsHash = sha256(commandsArray)
          let signedMessage = secp.signSync(commandsHash, privateKey)
          let publicKey = account.publicKey
          publicKey = hexToBytes(publicKey)
          console.log(secp.verify(signedMessage, commandsHash, publicKey))
          const rawResponse =
            await fetch("/interpret", {
              method: 'POST', // *GET, POST, PUT, DELETE, etc.

              headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json'
                // 'Content-Type': 'application/x-www-form-urlencoded',
              },
              body: JSON.stringify({ commands: commandsSubbed, signedCommands: bytesToHex(signedMessage), publicKey: bytesToHex(publicKey) }) // body data type must match "Content-Type" header
            });
          const content = await rawResponse.json();
          console.log(content);
          if (content.permission_problem) {
            alert("No permission!")
          }
          let documents;
          try {
            documents = secureLocalStorage.getItem("documents")
          } catch (err) {
            documents = localStorage.getItem("documents")
          }
          if (documents) {
            documents = [{ commands: commandsSubbed, signedBy: bytesToHex(publicKey), signature: bytesToHex(signedMessage) }] + documents;
          } else {
            documents = [{ commands: commandsSubbed, signedBy: bytesToHex(publicKey), signature: bytesToHex(signedMessage) }];
          }
          try {
            secureLocalStorage.setItem("documents", documents);
          } catch (err) {
            localStorage.setItem("documents", documents);
          }
          this.props.updateDocuments();
          console.log(this.props.position_tree_svg.current);
          while (this.props.position_tree_svg.current.children.length > 0) {
            this.props.position_tree_svg.current.removeChild(this.props.position_tree_svg.current.children[0])
          }
          console.log(onlyGivenCollegeDag(content.message.permission_dag, "College0"))
          this.props.position_tree_svg.current.appendChild(ForceGraph(content.message.position_tree
            , {
              nodeId: d => d.id,
              withText: content.message.position_tree.nodes.length < 20,
              nodeGroup: d => { if (d.group == 'agent') { return 'operator' } else if (d.group == 'resource_handler') { return 'organisation' } else if (d.group == 'resource') { return 'location' } else if (d.group == 'attribute_handler') { return 'attribute_maintainer' } else return d.group },
              nodeTitle: d => `${this.nameOfAdress(d.id)}\n${d.group}`,
              nodeRadius: nodeRadiusConsts[content.message.position_tree.nodes.length < 20 ? 1 : 0],
              nodeStrength: strengthConsts[content.message.position_tree.nodes.length < 20 ? 1 : 0],
              nodeGroups: ["operator", "organisation", "attribute", "attribute_maintainer", "location"],
              with_markers: false
            }
          ))

          while (this.props.permission_dag_svg.current.children.length > 0) {
            this.props.permission_dag_svg.current.removeChild(this.props.permission_dag_svg.current.children[0])
          }
          this.props.permission_dag_svg.current.appendChild(ForceGraph((content.message.permission_dag)
            , {
              nodeId: d => d.id,
              withText: content.message.permission_dag.nodes.length < 20,
              nodeGroup: d => { if (d.group == 'agent') { return 'operator' } else if (d.group == 'resource_handler') { return 'organisation' } else if (d.group == 'resource') { return 'location' } else if (d.group == 'attribute_handler') { return 'attribute_maintainer' } else return d.group },
              nodeTitle: d => `${this.nameOfAdress(d.id)}\n${d.group}`,
              nodeRadius: nodeRadiusConsts[content.message.permission_dag.nodes.length < 20 ? 1 : 0],
              nodeStrength: strengthConsts[content.message.permission_dag.nodes.length < 20 ? 1 : 0],
              nodeGroups: ["operator", "organisation", "attribute", "attribute_maintainer", "location"],
              with_markers: withMarkersForPermissions
            }
          ))

          while (this.props.location_permission_dag_svg.current.children.length > 0) {
            this.props.location_permission_dag_svg.current.removeChild(this.props.location_permission_dag_svg.current.children[0])
          }
          this.props.location_permission_dag_svg.current.appendChild(ForceGraph(onlyLocationDag((content.message.permission_dag))
            , {
              nodeId: d => d.id,
              withText: content.message.permission_dag.nodes.length < 20,
              nodeGroup: d => { if (d.group == 'agent') { return 'operator' } else if (d.group == 'resource_handler') { return 'organisation' } else if (d.group == 'resource') { return 'location' } else if (d.group == 'attribute_handler') { return 'attribute_maintainer' } else return d.group },
              nodeTitle: d => `${this.nameOfAdress(d.id)}\n${d.group}`,
              nodeRadius: nodeRadiusConsts[content.message.permission_dag.nodes.length < 20 ? 1 : 0],
              nodeStrength: strengthConsts[content.message.permission_dag.nodes.length < 20 ? 1 : 0],
              with_markers: withMarkersForPermissions,
              nodeGroups: ["operator", "organisation", "attribute", "attribute_maintainer", "location"]
            }
          ))

          while (this.props.attribute_permission_dag_svg.current.children.length > 0) {
            this.props.attribute_permission_dag_svg.current.removeChild(this.props.attribute_permission_dag_svg.current.children[0])
          }
          this.props.attribute_permission_dag_svg.current.appendChild(ForceGraph(onlyAttributeDag((content.message.permission_dag))
            , {
              nodeId: d => d.id,
              withText: content.message.permission_dag.nodes.length < 20,
              nodeGroup: d => { if (d.group == 'agent') { return 'operator' } else if (d.group == 'resource_handler') { return 'organisation' } else if (d.group == 'resource') { return 'location' } else if (d.group == 'attribute_handler') { return 'attribute_maintainer' } else return d.group },
              nodeTitle: d => `${this.nameOfAdress(d.id)}\n${d.group}`,
              nodeRadius: nodeRadiusConsts[content.message.permission_dag.nodes.length < 20 ? 1 : 0],
              nodeStrength: strengthConsts[content.message.permission_dag.nodes.length < 20 ? 1 : 0],
              with_markers: withMarkersForPermissions,
              nodeGroups: ["operator", "organisation", "attribute", "attribute_maintainer", "location"]
            }
          ))
        }
      } else {
        alert("Error while parsing token: " + content1.error.split(' ')[6])
      }
    })();
    // return response.json(); // parses JSON response into native JavaScript objects
    //   alert('Commands submitted ' + this.state.value);
    event.preventDefault();
  }

  render() {
    return (

      <form onSubmit={this.handleSubmit}>
        <label>

          <textarea id="commandInput" value={this.state.value} onChange={this.handleChange} rows={10} style={{ width: 500 }} />        </label>
        <input id="commandSubmit" type="submit" value="Submit" />
      </form>

    );
  }
}

class Wallet extends React.Component {
  constructor(props) {
    super(props);
    this.state = { accounts: [], authenticated: false, showingDocuments: false };
    this.authenticate = this.authenticate.bind(this);
    this.updateAccounts = this.updateAccounts.bind(this);
    this.toggleDocuments = this.toggleDocuments.bind(this);
  }
  componentDidMount() {
    if (window.sessionStorage.getItem("authenticated") === 'true') {
      let accounts = [];
      if (getProtectedItem('accounts')) {
        accounts = getProtectedItem('accounts')
      }
      this.setState({ ...this.state, accounts: accounts, authenticated: true })
    }
  }
  authenticate() {
    this.setState({ ...this.state, accounts: getProtectedItem('accounts') ? getProtectedItem('accounts') : [], authenticated: true })
  }

  updateAccounts(accounts) {
    this.setState({ ...this.state, accounts: accounts })
  }

  accountExists() {
    let accountExists;
    try {
      accountExists = secureLocalStorage.getItem("accountExists")
    } catch (err) {
      accountExists = localStorage.getItem("accountExists")
    }
    if (!accountExists) {
      return false
    } else {
      return true
    }
  }

  toggleDocuments() {
    this.setState({ ...this.state, showingDocuments: !this.state.showingDocuments })
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
          <button type="button" onClick={this.toggleDocuments}>
            {this.state.showingDocuments ? "show keys" : "show documents"}
          </button>
          {this.state.showingDocuments ? <DocumentTable documents={this.props.documents} /> :
            <AddressList accounts={this.state.accounts} />}
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
      <div id="accountList">
        {listItems}
      </div>
    );
  }
}

class DocumentTable extends React.Component {
  constructor(props) {
    super(props);
    this.state = {};
  }

  downloadSignature(data) {
    const toDownload = `data:text/json;chatset=utf-8,${encodeURIComponent(
      JSON.stringify(data)
    )}`;
    const holder = document.createElement("a");
    holder.href = toDownload;
    holder.download = "signature.json";

    holder.click();
  };

  trimLongWords(text) {
    let words = text.split(" ")
    for (let i = 0; i < words.length; ++i) {
      if (words[i].length > 20) {
        words[i] = words[i].slice(0, 19) + "..."
      }
    }
    return words.join(" ")
  }

  render() {
    const documents = this.props.documents;

    return (
      <table>
        <tr>
          <th>Commands</th>
          <th>Signed by</th>
          <th>Signature</th>
        </tr>
        {documents.map((val, key) => {
          return (
            <tr key={key}>
              <td style={{ fontSize: 10 }}>{this.trimLongWords(val.commands)}</td>
              <td style={{ fontSize: 10 }}>{this.trimLongWords(val.signedBy)}</td>
              <td><button type="button" onClick={() => this.downloadSignature(val)}> Download </button></td>
            </tr>
          )
        })}
      </table>
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
    let salt;
    try {
      salt = secureLocalStorage.getItem("salt");
    } catch (err) {
      salt = localStorage.getItem("salt");
    }
    const hashedPassword = CryptoJS.SHA3(this.state.value + salt);
    // const actualHashedPassword = secureLocalStorage.getItem("password_hash");
    try {
      if (!(secureLocalStorage.getItem(hashedPassword) === null)) {
        window.sessionStorage.setItem("authenticated", 'true')
        window.sessionStorage.setItem("password", this.state.value)
        this.props.authenticate()
      } else {
        alert("Wrong password")
      }
      event.preventDefault();
    } catch (err) {
      if (!(localStorage.getItem(hashedPassword) === null)) {
        window.sessionStorage.setItem("authenticated", 'true')
        window.sessionStorage.setItem("password", this.state.value)
        this.props.authenticate()
      } else {
        alert("Wrong password")
      }
      event.preventDefault();
    }
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
    try {
      if (secureLocalStorage.getItem("salt") === null) {
        const newSalt = generateSalt(10)
        secureLocalStorage.setItem("salt", newSalt)
      }
      let salt = secureLocalStorage.getItem("salt")
      secureLocalStorage.setItem('accountExists', true)
      const hashedPassword = CryptoJS.SHA3(this.state.value + salt)
      secureLocalStorage.setItem(hashedPassword, true)
      window.sessionStorage.setItem("authenticated", 'true')
      window.sessionStorage.setItem("password", this.state.value)
      this.props.authenticate();
      event.preventDefault();
    } catch (err) {
      if (localStorage.getItem("salt") === null) {
        const newSalt = generateSalt(10)
        localStorage.setItem("salt", newSalt)
      }
      let salt = localStorage.getItem("salt")
      localStorage.setItem('accountExists', true)
      const hashedPassword = CryptoJS.SHA3(this.state.value + salt)
      localStorage.setItem(hashedPassword, true)
      window.sessionStorage.setItem("authenticated", 'true')
      window.sessionStorage.setItem("password", this.state.value)
      this.props.authenticate();
      event.preventDefault();
    }
  }

  render() {
    return (
      <div id="registerDiv">
        Register
        <form onSubmit={this.handleSubmit}>        <label>
          Password:
          <input id="passwordInput" type="password" value={this.state.value} onChange={this.handleChange} />        </label>
          <input id="passwordSubmit" type="submit" value="Submit" />
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
      let password_hash = passwordHash(password)
      let key = this.getHdRootKey(mnemonicToEntropy(mnemonic, wordlist));
      let encryptedKey1 = await getEncryptedKey(mnemonicToEntropy(mnemonic, wordlist))
      try {
        secureLocalStorage.setItem("master_key" + password_hash, encryptedKey1)
      } catch (err) {

        localStorage.setItem("master_key" + password_hash, encryptedKey1)
      }
      let privateKey = this.generatePrivateKey(key, 0);
      let publicKey = getPublicKey(privateKey);
      let privateKeyEncrypted = await getEncryptedKey(privateKey)
      let account = { name: this.state.name, publicKey: bytesToHex(publicKey), privateKeyEncrypted: privateKeyEncrypted }
      try { secureLocalStorage.setItem("accounts" + password_hash, [account]) } catch (err) {
        localStorage.setItem("accounts" + password_hash, [account])
      }
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
      let accountList = getProtectedItem('accounts')
      console.log(accountList)
      let password = window.sessionStorage.getItem('password')
      let password_hash = passwordHash(password)
      if (accountList === null || accountList.length === 0) {
        let mnemonic, entropy;
        ({ mnemonic, entropy } = this._generateMnemonic());
        let key = this.getHdRootKey(entropy);
        console.log("firstKey")
        console.log(key)
        let hdKeyExtended = entropy
        let encryptedKey = await getEncryptedKey(hdKeyExtended)
        try { secureLocalStorage.setItem("master_key" + password_hash, encryptedKey) } catch (err) {
          localStorage.setItem("master_key" + password_hash, encryptedKey)
        }
        let privateKey = this.generatePrivateKey(key, 0);
        let publicKey = getPublicKey(privateKey);
        console.log(privateKey)

        alert("This is your mnemonic:\n" + mnemonic + "\nNote it down and you will be able to recover your keys if you forget your password or change a device.")
        let privateKeyEncrypted = await getEncryptedKey(privateKey)
        let account = { name: this.state.value, publicKey: bytesToHex(publicKey), privateKeyEncrypted: privateKeyEncrypted }
        try { secureLocalStorage.setItem("accounts" + password_hash, [account]) } catch (err) {
          localStorage.setItem("accounts" + password_hash, [account])
        }
        this.props.updateAccounts([account]);
      } else {
        console.log("key")
        console.log(getProtectedItem('master_key'))
        let decryptedKey = await getDecryptedKey(getProtectedItem('master_key'))
        console.log(decryptedKey)
        let key = HDKey.fromMasterSeed(decryptedKey);

        console.log(key)
        let privateKey = this.generatePrivateKey(key, accountList.length);
        let publicKey = getPublicKey(privateKey);
        console.log(privateKey)
        let testArray = new Uint8Array(1);
        console.log(privateKey)
        let privateKeyEncrypted = await getEncryptedKey(privateKey)
        let account = { name: this.state.value, publicKey: bytesToHex(publicKey), privateKeyEncrypted: privateKeyEncrypted }
        accountList.push(account);
        try {
          secureLocalStorage.setItem("accounts" + password_hash, accountList)
        } catch (err) {

          localStorage.setItem("accounts" + password_hash, accountList)
        }
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
          <input id="accountInput" type="text" value={this.state.value} onChange={this.handleChange} />        </label>
          <input id="accountSubmit" type="submit" value="Submit" />
        </form>
      </div>

    );
  }

}

function App() {

  let documentsGet;
  try {
    documentsGet = secureLocalStorage.getItem("documents")
  } catch (err) {
    documentsGet = localStorage.getItem("documents")
  }
  const [documents, setDocuments] = useState(documentsGet ? documentsGet : [])

  const position_tree_svg = React.useRef(null);
  const permission_dag_svg = React.useRef(null);
  const attribute_permission_dag_svg = React.useRef(null);
  const location_permission_dag_svg = React.useRef(null);

  const updateDocs = () => {
    let documentsGet1;
    try {
      documentsGet1 = secureLocalStorage.getItem("documents")
    } catch (err) {
      documentsGet1 = localStorage.getItem("documents")
    }
    setDocuments(documentsGet1 ? documentsGet1 : [])
  }

  return (
    <div className="App">
      <header className="App-header">

        <div style={{ display: "flex" }}>
          <div style={{ flex: 5 }}>

            <EssayForm position_tree_svg={position_tree_svg} updateDocuments={updateDocs} permission_dag_svg={permission_dag_svg} attribute_permission_dag_svg={attribute_permission_dag_svg} location_permission_dag_svg={location_permission_dag_svg} />
          </div>
          <div style={{ flex: 5 }}>

            <Wallet documents={documents} />
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
            <div id="permissions" ref={permission_dag_svg} />
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
