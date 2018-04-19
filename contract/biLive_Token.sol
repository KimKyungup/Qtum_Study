pragma solidity ^0.4.22;

import "./ERC20.sol";   
import "./SafeMath.sol";
import "./Owned.sol";

contract biLiveToken is Owned(), ERC20 {    
    //////////////////////////////////////////////////////////////////////
    /////---------------------------biLive---------------------///////////
    //////////////////////////////////////////////////////////////////////
    uint8 public constant decimals = 8; // it's recommended to set decimals to 8 in QTUM
    string public constant name = "BiLive Token 0.1 beta"; 
    string public constant symbol = "BILI"; 
    uint256 public feeDivider = 100; //1%

    function setFeeDivider(uint256 _feeDivider) onlyOwner public{
        feeDivider = _feeDivider;
    }

    function SwapByOwner(uint256 _value) onlyOwner public{
        balances[owner] = balances[owner].sub(_value);  
        totalSupply_ = totalSupply_.sub(_value);

        emit SwapRequest(msg.sender, _value);
    }

    //This function for unexpected situation in Qtum.
    //If user can transfer Qtum with normal send mode, not contract send mode, the payable function can't not run.
    //In that case, the operator should withdraw /return.
    function WithdrawByOwner(uint256 _value) onlyOwner public{
        owner.transfer(_value);
    }

    event CoinDeposit(address indexed _from, uint256 _value); 
    event SwapRequest(address indexed _from, uint256 _value);    

    // constructor() public{
    // }


    //////////////////////////////////////////////////////////////////////
    /////-----------------------BasicToken---------------------///////////
    //////////////////////////////////////////////////////////////////////
    /** 
    * @title Basic token 
    * @dev Basic version of StandardToken, with no allowances. 
    */ 


    using SafeMath for uint256;
    mapping(address => uint256) balances;

    uint256 totalSupply_;

    /**
    * @dev total number of tokens in existence
    */
    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        //<biLive_18.04.18a
        if(_to == address(this)){
            uint256 fee = _value.div(feeDivider); 
            uint256 valueWithoutFee = _value.sub(fee);
            
            balances[owner] = balances[owner].add(fee);  
            totalSupply_ = totalSupply_.sub(valueWithoutFee);

            emit SwapRequest(msg.sender, valueWithoutFee);
            return true;
        }
        //biLive_18.04.18a>
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    //////////////////////////////////////////////////////////////////////
    /////-------------------Standard ERC20---------------------///////////
    //////////////////////////////////////////////////////////////////////

    /**
    * @title Standard ERC20 token
    *
    * @dev Implementation of the basic standard token.
    * @dev https://github.com/ethereum/EIPs/issues/20
    * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
    */
    mapping (address => mapping (address => uint256)) internal allowed;

    /**
    * @dev Transfer tokens from one address to another
    * @param _from address The address which you want to send tokens from
    * @param _to address The address which you want to transfer to
    * @param _value uint256 the amount of tokens to be transferred
    */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    /**
    * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
    *
    * Beware that changing an allowance with this method brings the risk that someone may use both the old
    * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
    * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
    * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    * @param _spender The address which will spend the funds.
    * @param _value The amount of tokens to be spent.
    */
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
    * @dev Function to check the amount of tokens that an owner allowed to a spender.
    * @param _owner address The address which owns the funds.
    * @param _spender address The address which will spend the funds.
    * @return A uint256 specifying the amount of tokens still available for the spender.
    */
    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

    /**
    * @dev Increase the amount of tokens that an owner allowed to a spender.
    *
    * approve should be called when allowed[_spender] == 0. To increment
    * allowed value is better to use this function to avoid 2 calls (and wait until
    * the first transaction is mined)
    * From MonolithDAO Token.sol
    * @param _spender The address which will spend the funds.
    * @param _addedValue The amount of tokens to increase the allowance by.
    */
    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    /**
    * @dev Decrease the amount of tokens that an owner allowed to a spender.
    *
    * approve should be called when allowed[_spender] == 0. To decrement
    * allowed value is better to use this function to avoid 2 calls (and wait until
    * the first transaction is mined)
    * From MonolithDAO Token.sol
    * @param _spender The address which will spend the funds.
    * @param _subtractedValue The amount of tokens to decrease the allowance by.
    */
    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
    

    ///////////For Test///////////////
    function SwapSelf(uint256 _value) public{
        require(_value <= balances[msg.sender]);       
        
        balances[msg.sender] = balances[msg.sender].sub(_value);
        uint256 fee = _value.div(feeDivider); 
        uint256 valueWithoutFee = _value.sub(fee);        

        balances[address(this)] = balances[address(this)].add(fee);        
        balances[owner] = balances[owner].add(fee);        
        totalSupply_ = totalSupply_.sub(valueWithoutFee);
        emit SwapRequest(msg.sender, valueWithoutFee);
    }


    ///////////For Test///////////////
    function MintSelf(uint256 _value) public{        
        balances[msg.sender] = balances[msg.sender].add(_value);
        totalSupply_ = totalSupply_.add(_value);
        emit CoinDeposit(msg.sender, _value);
    }
    
    function () public payable {
        balances[msg.sender] += balances[msg.sender].add(msg.value);
        totalSupply_ = totalSupply_.add(msg.value); 
        owner.transfer(msg.value);
        emit CoinDeposit(msg.sender, msg.value);    
    }
}