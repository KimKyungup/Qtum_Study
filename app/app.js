//import { Qtum, Contract, QtumRPC } from "qtumjs";
const { Qtum, Contract, QtumRPC } = require("qtumjs")

const rpc = new QtumRPC("rpc://up:test@127.0.0.1:13889")
const password = "test0"

const contractInfo = require("../contract/SmartContract.json")
const contract = new Contract(rpc, contractInfo.contracts["18.04.28c"])

const getBlockCount = async() => {
  return await rpc.rawCall("getblockcount")
}

const walletUnLockForOnlyStaking = async()=>{
  result = await rpc.rawCall("walletpassphrase",[password, 99999, true])
  console.log("Wallet UnLock For Only Staking")
}

const walletUnLock = async()=>{
  result = await rpc.rawCall("walletpassphrase",[password, 1000, false])
  console.log("Wallet UnLock")   
}

const walletLock = async()=>{
  result = await rpc.rawCall("walletlock")
  console.log("Wallet Lock")
}

const sendQtum = async(toAddr, amount) =>{  
  result = await rpc.rawCall("sendtoaddress",[toAddr, amount, "", "" , true])
  console.log("Send " + amount + "Qtum" + " to ",toAddr)
  return result.toString()
}

const withdraw = async(toAddr, amountBI) =>{

  var qtumAmount = amountBI / 100000000

  await walletUnLock()
  const result = await sendQtum(toAddr,qtumAmount)  
  await walletUnLockForOnlyStaking() 
  
  return result
}

async function callFunction(){
  const result = await contract.call("totalSupply")
  console.log(result)
}
 //////////////////////////////////////////////////////////////////
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
 
//getLogs()
 //////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////
// contract.onLog((entry) => {
//   console.log("##### OnLog ##### => TX Hash:" + entry.transactionHash)
// }, { minconf: 1 })	
///////////////////////////////////////////////////////////////////

this.emitter = contract.logEmitter({ minconf: 0 })

async function SwapTokenToCoin(event){
  var amount =  event["event"]["_value"]
  var qtumAmount = amount / 100000000
  var toAddrHex = event["event"]["_from"]
  var toAddr = await getBase58Address(toAddrHex)

  console.log("#########SwapRequest#########################################")

  console.log("amount :" + qtumAmount)
  console.log("to :" + toAddr)

  const result = await withdraw(toAddr, amount)  

  console.log("txid : " + result)

  console.log(event)
  console.log("#############################################################")
}

this.emitter.on("SwapRequest", (event) => {  
  SwapTokenToCoin(event)
})

async function getBase58Address(hexAddr){
  var UTXO = await rpc.rawCall("fromhexaddress",[hexAddr])
  return UTXO
}

this.emitter.on("CoinDeposit", (event) => {

  var amount =  event["event"]["_value"]
  var qtumAmount = amount / 100000000
  var fromAddrHex = event["event"]["_from"]
  var fromAddr = getBase58Address(fromAddrHex)  

  console.log("##########CoinDeposit##################################")
  console.log("from : " + fromAddr)
  console.log("amount : " + qtumAmount)    
  console.log(JSON.stringify(event, null, 2))
  console.log("#######################################################")
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



//////////////////////////////////////////////////////////////////////
/////---------------------------Call-----------------------///////////
//////////////////////////////////////////////////////////////////////

async function sc_name(){
  const result = await contract.call("name");    
  const name = Buffer(result.executionResult.output, 'hex').toString();
  console.log("name : ", name);
}

async function sc_totalSupply(){
  const result = await contract.call("totalSupply");
  const totalSupply = result.executionResult.output;
  console.log("totalSupply : ", parseInt(totalSupply, 16));
}

async function sc_decimals(){
  const result = await contract.call("decimals");
  const decimals = result.executionResult.output;
  console.log("decimals : ", parseInt(decimals, 16));
}

async function sc_balanceOf(owner){
  const result = await contract.call("balanceOf", [owner]);
  const balance = result.executionResult.output;
  console.log("balance : ", parseInt(balance, 16));
}

async function sc_owner(){
  const result = await contract.call("owner");
  const owner = result.executionResult.output;
  console.log("owner : ", owner);
}

async function sc_feeDivider(){
  const result = await contract.call("feeDivider");
  const feeDivider = result.executionResult.output;
  console.log("feeDivider : ",  parseInt(feeDivider, 16));
}

async function sc_symbol(){
  const result = await contract.call("symbol");    
  const symbol = Buffer(result.executionResult.output, 'hex').toString();
  console.log("symbol : ",  symbol);
}

async function sc_newOwner(){
  const result = await contract.call("newOwner");    
  const newOwner = Buffer(result.executionResult.output, 'hex').toString();
  console.log("newOwner : ",  newOwner);
}

async function sc_allowance(owner, spender){
  const result = await contract.call("allowance", [owner, spender]);
  const allowance = result.executionResult.output;
  console.log("allowance : ",  parseInt(allowance, 16));    
}

// sc_name()
// sc_totalSupply()
// sc_decimals()
// sc_balanceOf(owner)
// sc_owner()
// sc_feeDivider()
// sc_symbol()
// sc_newOwner()
//sc_allowance(owner, owner)

//////////////////////////////////////////////////////////////////////
/////---------------------------Send-----------------------///////////
//////////////////////////////////////////////////////////////////////

async function sc_MintSelf(value){    
  var result = await contract.send("MintSelf", [value]);
  console.log(result);
}
