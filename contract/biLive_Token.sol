pragma solidity ^0.4.23;

import "./ERC20.sol";   
import "./SafeMath.sol";
import "./Owned.sol";
import "./StandardToken.sol";

contract biLiveToken is Owned(), ERC20, StandardToken {    
    //////////////////////////////////////////////////////////////////////
    /////---------------------------biLive---------------------///////////
    //////////////////////////////////////////////////////////////////////
    uint8 public constant decimals = 8; // it's recommended to set decimals to 8 in QTUM
    string public name = "BiLive Token Beta 18.04.29c"; 
    string public symbol = "BILI"; 
    uint256 public minCoinValueDeposit = 1 * 10**uint256(decimals);   //1 Qtum
    uint256 public minTokenValueWithdraw = 1 * 10**uint256(decimals);   //1 BILI
    uint256 public feeToken = 1 * 10**uint256(decimals - 1);       //0.1 BILI        
    uint256 public feeMiningDivider = 5;    //20%
    uint256 totalCoinStaking_ = 0;    

    function test_AddressBalance(address user) public view returns (uint256){
        return user.balance;
    }

    function totalCoinStaking() public view returns (uint256) {
        return totalCoinStaking_;
    }

    function updateCoinMined(uint256 _valueMined, uint256 _tokenForOwner, uint256 _presentSupply) onlyOwner public{
        require(totalSupply_ == _presentSupply);
        
        totalCoinStaking_ = totalCoinStaking_.add(_valueMined);
        balances[owner] = balances[owner].add(_tokenForOwner);  
        totalSupply_ = totalSupply_.add(_tokenForOwner);

        require(getCoinValueFromToken(_tokenForOwner) <= _valueMined.div(feeMiningDivider));

        emit Mined(_valueMined, _tokenForOwner);
    }

    constructor(uint256 _valueOwnerInitCoin) public{   
        uint256 ownerInitBalance = _valueOwnerInitCoin; //msg.sender.balance;     
        totalSupply_ = ownerInitBalance;
        totalCoinStaking_ = ownerInitBalance;
        balances[msg.sender] = ownerInitBalance;
    }

    function myBalance() public view returns (uint256 balance) {
        return balances[msg.sender];
    }

    function setName(string _new_name) onlyOwner public{
        name = _new_name;
    }

    function setSymbol(string _new_symbol) onlyOwner public{
        symbol = _new_symbol;
    }

    function setFee(uint256 _fee) onlyOwner public{
        feeToken = _fee;
    }

    function setMinTokenValueWithdraw(uint256 _minTokenValueWithdraw) onlyOwner public{
        minTokenValueWithdraw = _minTokenValueWithdraw;
    }

    function swapByOwner(uint256 _value) onlyOwner public{
        balances[owner] = balances[owner].sub(_value);  
        totalSupply_ = totalSupply_.sub(_value);

        uint256 coinValue = getCoinValueFromToken(_value);

        emit SwapRequest(msg.sender, coinValue);
    }

    function getCoinValueFromToken(uint256 _tokenValue) public view returns (uint256){
        uint256 mulResult = _tokenValue.mul(totalCoinStaking_);
        return mulResult.div(totalSupply_);
    }

    function getTokenValueFromCoin(uint256 _coinValue) public view returns (uint256){
        uint256 mulResult = _coinValue.mul(totalSupply_);
        return mulResult.div(totalCoinStaking_);
    }

    event Mined(uint256 _valueMined, uint256 feeToken); 
    event CoinDeposit(address indexed _from, uint256 _value); 
    event SwapRequest(address indexed _from, uint256 _value);    

    function swapCoinToToken() public payable {
        require(msg.value >= minCoinValueDeposit);

        uint256 tokenValue = getTokenValueFromCoin(msg.value);

        balances[msg.sender] = balances[msg.sender].add(tokenValue);

        totalSupply_ = totalSupply_.add(tokenValue); 
        totalCoinStaking_ = totalCoinStaking_.add(msg.value);

        owner.transfer(msg.value);       

        emit CoinDeposit(msg.sender, msg.value);    
    }

    function () public payable {
        swapCoinToToken();
    }

    function swapTokenToCoin(uint256 _valueToken) public{        
        require(_valueToken >= minTokenValueWithdraw,"Minimum Token Value is requried.");
        require(_valueToken <= balances[msg.sender]);
        
        balances[msg.sender] = balances[msg.sender].sub(_valueToken);
        
        uint256 valueTokenWithoutFee = _valueToken.sub(feeToken);   
        uint256 valueCoinWithdraw = getCoinValueFromToken(valueTokenWithoutFee);

        balances[owner] = balances[owner].add(feeToken);  
        totalSupply_ = totalSupply_.sub(valueTokenWithoutFee);      
        totalCoinStaking_ = totalCoinStaking_.sub(valueCoinWithdraw);         

        emit SwapRequest(msg.sender, valueCoinWithdraw);           
    }

    //This function for unexpected situation in Qtum.
    //If user can transfer Qtum with normal send mode, not contract send mode, the payable function can't not run.
    //In that case, the operator should withdraw /return.
    function withdrawByOwner(uint256 _value) onlyOwner public{
        owner.transfer(_value);
    }

 
    /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) public returns (bool) {
        //<biLive_18.04.18a
        if(_to == address(this)){
            swapTokenToCoin(_value);                
            emit Transfer(msg.sender, _to, _value);
            return true;
        }
        //biLive_18.04.18a>

        return super.transfer(_to, _value);
    }
}
