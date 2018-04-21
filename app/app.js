//import { Qtum, Contract, QtumRPC } from "qtumjs";
const { Qtum, Contract, QtumRPC } = require("qtumjs")

const rpc = new QtumRPC("rpc://up:test@127.0.0.1:13889")
const notepc = "qZSPRLq9AWkw4uzPJ94TsMPPPnPcfv9WH8"
const password = "test0"

const getBlockCount = async() => {
  console.log(await rpc.rawCall("getblockcount"))
  return "done"
}

const walletUnLockForOnlyStaking = async()=>{
  result = await rpc.rawCall("walletpassphrase",[password, 99999, true])
  console.log(result)
  return "done"
}

const walletUnLock = async()=>{
  result = await rpc.rawCall("walletpassphrase",[password, 100, false])
  console.log(result) 
  return "done"
}


const walletLock = async()=>{
  result = await rpc.rawCall("walletlock")
  console.log(result)
  return "done"
}


const sendQtum = async(toAddr, amount) =>{
  //result = await rpc.rawCall("sendtoaddress",["qUVsNzAi6WkLJCVT72rjxCNLa2iKS5Q81N", 1000, "test", "test outpost", false, "qZSPRLq9AWkw4uzPJ94TsMPPPnPcfv9WH8", true])
  result = await rpc.rawCall("sendtoaddress",[toAddr, amount])
  console.log(result)
  return "done"
}
const contractInfo = require("../contract/SmartContract.json")

const contract = new Contract(rpc, contractInfo.contracts["biLive_Token"])

async function callFunction(){
  const result = await contract.call("totalSupply")
  console.log(result)
}
 
async function getLogs(fromBlock=0, toBlock="latest") {
    const logs = await contract.logs({
    fromBlock,
    toBlock,
    minconf: 1,
  })
  console.log(JSON.stringify(logs, null, 2))

  for(var i = 0, len = logs.entries.length; i < len;i++){
    var entry = logs.entries[i]

    if(entry.event.type == "SwapRequest"){
      console.log("#########SwapRequest#######")
      console.log(entry)
      var amount =  entry["event"]["_value"]
      var toAddrHex = entry["event"]["_from"]
      var toAddr = await rpc.rawCall("fromhexaddress",[toAddrHex]) 
 
      console.log("amount :" + amount)
      console.log(amount/100000000)
      console.log("toAddr :" + toAddr)

      // walletUnLock()
      // sendQtum(toAddr,amount/100000000) 
      // walletLock()
    }
  }
}
 
getLogs()
 
contract.onLog((entry) => {
  console.log("##### OnLog ##### => TX Hash:" + entry.transactionHash)
}, { minconf: 1 })	

//var EventEmitter = require('eventemitter3');

this.emitter = contract.logEmitter({ minconf: 1 })

async function Withdraw(toAddrHex, amountBI){

  var qtumAmount = amountBI / 100000000
  var toAddr = await rpc.rawCall("fromhexaddress",[toAddrHex])

  console.log("#########SwapRequest#######")

  console.log("amount :" + qtumAmount)
  console.log("tp :" + toAddr)

  walletUnLock()
  sendQtum(toAddr,qtumAmount)  
  walletLock()  
  console.log("##############################")
}

this.emitter.on("SwapRequest", (event) => {
  
  console.log(event)
  var amount =  event["event"]["_value"]
  var toAddrHex = event["event"]["_from"]

  Withdraw(toAddrHex, amount)  
})

async function getUTXO(hexAddr){
  var UTXO = await rpc.rawCall("fromhexaddress",[hexAddr])
  return UTXO
}

this.emitter.on("CoinDeposit", (event) => {

  var amount =  event["event"]["_value"]
  var qtumAmount = amount / 100000000
  var fromAddrHex = event["event"]["_from"]
  var fromAddr = getUTXO(fromAddrHex)

  // var fromAddr = rpc.rawCall("fromhexaddress",[fromAddrHex])  //await fromHexAddress(fromAddrHex)

  console.log("##########CoinDeposit##########")
  console.log("from : " + fromAddr)
  console.log("amount : " + qtumAmount)  
  console.log("##############################")
  //console.log(JSON.stringify(event, null, 2))
})

//console.log(fromHexAddress("b790776b5e4cd2efadd538ddfe61324354961540"))


// "_value": "5f5e100",
// "_from": "b790776b5e4cd2efadd538ddfe61324354961540",
// "type": "CoinDeposit"

//getBlockCount()
//walletLock()
//walletUnLock()
//sendQtum()
//walletUnLockForOnlyStaking()