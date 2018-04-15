const {
  Qtum,
  QtumRPC
} = require("qtumjs")


const rpc = new QtumRPC('http://up:test@localhost:13889')

const makeRequest = async() => {

  const getinfo = await rpc.rawCall('getinfo')
  const blockcount = await rpc.rawCall('getblockcount')
    
  console.log(getinfo)
  console.log(blockcount)
}

makeRequest()
