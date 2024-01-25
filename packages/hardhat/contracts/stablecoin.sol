// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

contract Stablecoin {
	string public name;
	string public symbol;
	uint8 public decimals;
	uint public totalSupply;
	mapping(address => uint) public balances;
	mapping(address => mapping(address => uint)) public allowance;

	event Transfer(address indexed from, address indexed to, uint value);
	event Approval(address indexed owner, address indexed spender, uint value);
	event Issued(uint value);

	address public owner;
	bool public paused;
	mapping(address => bool) public minters;
	mapping(address => bool) public blacklist;

	modifier notBlacklisted() {
		require(!blacklist[msg.sender], "Blacklisted address");
		_;
	}

	modifier onlyOwner() {
		require(msg.sender == owner, "Not owner");
		_;
	}

	modifier onlyMinter() {
		require(minters[msg.sender], "Not a minter");
		_;
	}

	modifier notPaused() {
		require(!paused, "Function Paused");
		_;
	}

	constructor(
		string memory _name,
		string memory _symbol,
		uint8 _decimals,
		uint _initialSupply,
		address _owner
	) {
		name = _name;
		symbol = _symbol;
		decimals = _decimals;
		totalSupply = _initialSupply;
		balances[_owner] = _initialSupply;
		owner = _owner;
	}

	function changeOwner(address _newOwner) public onlyOwner {
		owner = _newOwner;
	}

	function transfer(
		address _to,
		uint _value
	) public notPaused notBlacklisted returns (bool success) {
		require(balances[msg.sender] >= _value, "Insufficient balance");
		balances[msg.sender] -= _value;
		balances[_to] += _value;
		emit Transfer(msg.sender, _to, _value);
		return true;
	}

	function approve(
		address _spender,
		uint _value
	) public notPaused notBlacklisted returns (bool success) {
		allowance[msg.sender][_spender] = _value;
		emit Approval(msg.sender, _spender, _value);
		return true;
	}

	function transferFrom(
		address _from,
		address _to,
		uint _value
	) public notPaused notBlacklisted returns (bool success) {
		require(
			balances[_from] >= _value && allowance[_from][msg.sender] >= _value,
			"Insufficient balance or allowance"
		);
		balances[_from] -= _value;
		allowance[_from][msg.sender] -= _value;
		balances[_to] += _value;
		emit Transfer(_from, _to, _value);
		return true;
	}

	function mint(
		address _recipient,
		uint256 _value
	) public onlyMinter notBlacklisted {
		totalSupply += _value;
		balances[_recipient] += _value;
		emit Issued(_value);
	}

	function setPaused(bool _paused) public onlyOwner {
		paused = _paused;
	}

	function setMinter(address _minter, bool _paused) public onlyOwner {
		minters[_minter] = _paused;
	}

	function setBlacklist(
		address _address,
		bool _isBlacklisted
	) public onlyOwner {
		blacklist[_address] = _isBlacklisted;
	}
}
