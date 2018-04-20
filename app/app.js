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


const sendQtum = async() =>{
  //result = await rpc.rawCall("sendtoaddress",["qUVsNzAi6WkLJCVT72rjxCNLa2iKS5Q81N", 1000, "test", "test outpost", false, "qZSPRLq9AWkw4uzPJ94TsMPPPnPcfv9WH8", true])
  result = await rpc.rawCall("sendtoaddress",["qadoLqUojq55YwhNAf6mAyDaSeneNKfq8s", 100])
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
}
 
getLogs()
 
contract.onLog((entry) => {
  console.log("##### OnLog ##### => TX Hash:" + entry.transactionHash)
}, { minconf: 1 })	

//var EventEmitter = require('eventemitter3');

this.emitter = contract.logEmitter({ minconf: 1 })

this.emitter.on("SwapRequest", (event) => {
  console.log("#########SwapRequest#######")
  console.log(event)
})

this.emitter.on("CoinDeposit", (event) => {
  console.log("##########CoinDeposit##########")
  console.log(event)
})


//getBlockCount()
//walletLock()
//walletUnLock()
//sendQtum()
//walletUnLockForOnlyStaking()