// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;



interface IERC20 {
    // not standart func
    function name() external view returns(string memory);
    function symbol() external view returns(string memory);
    function decimals() external pure returns(uint);

    // standart func
    function totalSupply() external view returns(uint);
    function balanceOf(address acccount) external view returns(uint);
    function transfer(address to, uint amount) external;
    function allowance(address _owner, address spender) external view returns(uint);
    function approw(address spender, uint amount) external;
    function transferFrom(address sender, address recipient, uint amount) external;
    
    // Events
    event Transfer(address indexed from, address indexed to, uint amount);
    event Approw(address indexed owner, address indexed to, uint amount);

}