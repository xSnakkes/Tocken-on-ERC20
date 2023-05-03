// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./IERC20.sol";

contract ERC20 is IERC20{
    uint totalTokens;
    address owner;
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowances;
    string _name;
    string _symbol;

    function name() external view returns(string memory){
        return _name;
    }

    function symbol() external view returns(string memory){
        return _symbol;
    }

    function decimals() external pure returns(uint){
        return 18; // 1 token = 1 wei = 0.000000000000000001 ether
    }

    function totalSupply() external view returns(uint){
        return totalTokens;
    }


    modifier enoughTockens(address _from, uint _amount){
        require(balanceOf(_from) >= _amount, "Not enough tokens!");
        _;
    }
    modifier onlyOwner(){
        require(msg.sender == owner, "Not an owner!");
        _;
    }

    constructor(string memory name_, string memory symbol_, uint initialSupply, address shop){
        _name = name_;
        _symbol = symbol_;
        owner = msg.sender;
        mint(initialSupply, shop);
    }

    function balanceOf(address account) public view returns(uint){
        return balances[account];
    }

    function transfer(address to, uint amount) external enoughTockens(msg.sender, amount){
        _beforeTokenTransfer(msg.sender, to, amount);
        balances[msg.sender] -= amount;
        balances[to] += amount;
        emit Transfer(msg.sender, to, amount);    
    }

    function mint(uint amount, address shop) public onlyOwner{
        _beforeTokenTransfer(address(0), shop, amount);
        balances[shop] += amount;
        totalTokens += amount;
        emit Transfer(address(0), shop, amount);
    }

    function burn(address _from, uint amount) public onlyOwner {
        _beforeTokenTransfer(_from, address(0), amount);
        balances[_from] -= amount;
        totalTokens -= amount;
    }

    function allowance(address _owner, address spender) public view returns(uint){
        return allowances[_owner][spender];
    }

    function approw(address spender, uint amount) public{
        _approw(msg.sender, spender, amount);
    }

    function _approw(address sender, address spender, uint amount) internal virtual{
        allowances[sender][spender] = amount;
        emit Approw(sender, spender, amount);
    }

    function transferFrom(address sender, address recipient, uint amount) external enoughTockens(sender, amount){
        _beforeTokenTransfer(sender, recipient, amount);
        require(allowances[sender][recipient] >= amount, "Check allowance!");
        allowances[sender][msg.sender] -= amount;
        balances[sender] -= amount;
        balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint amount
    ) internal virtual {}
}

contract XSNAKESToken is ERC20{
    constructor(address shop) ERC20("XSNAKESToken", "XSN", 20, shop){

    }
} 

contract XSNShop {
    IERC20 public token;
    address payable public owner;
    event Bought(uint _amount, address indexed _buyer);
    event Sold(uint _amount, address indexed _seller);

    constructor() {
        token = new XSNAKESToken(address(this));
        owner = payable(msg.sender);
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "Not an owner!");
        _;
    }

    function sell(uint _amountToSell) external {
        require(
            _amountToSell > 0 &&
            token.balanceOf(msg.sender) >= _amountToSell,
            "Incorrect amount!"
        );

        uint allowance = token.allowance(msg.sender, address(this));
        require(allowance >= _amountToSell, "check allowance!");

        token.transferFrom(msg.sender, address(this), _amountToSell);

        payable(msg.sender).transfer(_amountToSell);
        
        emit Sold(_amountToSell, msg.sender);
    }

    receive() external payable {
        uint tokensToBuy = msg.value; // 1 wei = 1 token
        require(tokensToBuy > 0, "Not enough funds!");

        require(tokenBalance() > tokensToBuy, "Not enough tokens!");

        token.transfer(msg.sender, tokensToBuy);
        emit Bought(tokensToBuy, msg.sender);
    }

    function tokenBalance() public view returns(uint){
        return token.balanceOf(address(this));
    }
}