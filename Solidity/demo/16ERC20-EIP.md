
### ERC 与 EIP

- ERC Ethereum request for comment 
- EIP  ethereum improvement proposals   改进提案 

- ERC20 - token标准

- ERC721 NTF

- ERC-165 Standard interface detection 

- ERC-777 

- https://eips.ethereum.org/erc


```
pragma solidity^0.6.1;

interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
    external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value)
    external returns (bool);

  function transferFrom(address from, address to, uint256 value)
    external returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}


```

```
pragma solidity^0.6.1;

import "./IERC20.sol";
import "./SafeMath.sol";

contract ykc_demo is IERC20 {
    using SafeMath for uint256;//对uint256类型使用使用安全计算 
    string private _name;
    uint256 private _totalSupply;
    address private admin;
    mapping(address=>uint256) private _balances;
    mapping(address=>mapping(address=>uint256)) private _allowance;
    constructor(string memory name) public {
        _name = name;
        _totalSupply = 0;
        admin = msg.sender;
    }
    
    function name() external view returns (string memory) {
        return _name;
    }
    //挖矿函数
    function mint(address to, uint256 value) external {
        require(admin == msg.sender, "only admin can do!");
        require(address(0) != to, "to must an address");
        _balances[to] = _balances[to].add(value);
        _totalSupply = _totalSupply.add(value);
        emit Transfer(address(0), to, value);
    }
    // 总发行量
    function totalSupply() external override view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address who) external override view returns (uint256) {
          return _balances[who];
    }

    function allowance(address owner, address spender)
    external override view returns (uint256) {
        return _allowance[owner][spender];
    }
    // tzhuan zh转账 s
    function transfer(address to, uint256 value) external override returns (bool) {
        // A->B 200,  A = A-200, B = B+200 .._balances
        require(value >0, "value must > 0");
        require(_balances[msg.sender] >= value, "balance must enough!");
        require(address(0) != to, "to must an address");
        _balances[msg.sender] = _balances[msg.sender].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(msg.sender, to, value);
    }
    //shou quan授权1
    function approve(address spender, uint256 value)
    external override returns (bool) {
        //require(value >0, "value must > 0");
        require(_balances[msg.sender] >= value, "balance must enough!");
        require(address(0) != spender, "spender must an address");
        _allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
    }

    function transferFrom(address from, address to, uint256 value)
    external override returns (bool) {
        require(address(0) != to, "to must an address");
        require(value >0, "value must > 0");
        require(_allowance[from][to] >= value, "allowance's value must enough!");
        _allowance[from][to] = _allowance[from][to].sub(value);
        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }
}


```
