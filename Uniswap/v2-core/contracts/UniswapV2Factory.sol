pragma solidity =0.5.16;

import './interfaces/IUniswapV2Factory.sol';
import './UniswapV2Pair.sol';

// 核心是工厂合约
//  #5 
contract UniswapV2Factory is IUniswapV2Factory {
    
    address public feeTo;  // 收税地址
    address public feeToSetter;  // 收税权限控制地址

    // 配对映射 地址=>(addr => addr)
    mapping(address => mapping(address => address)) public getPair;
    //所有的配对数组
    address[] public allPairs;

    //事件, 配对被创建
    // uint 是allPairs的长度
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    /*
    @dev 构造函数
    @param _feeToSetter 收税开关权限控制
    */
    constructor(address _feeToSetter) public {
        feeToSetter = _feeToSetter;
    }

    /*
    @dev 查询配对数组长度方法
         长度必须
    */
    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }


    /*
     @param tokenA TokenA
     @param toeknB TokenB
     @return pair 配对地址
     @dev 创建配对
     
    */
    function createPair(address tokenA, address tokenB) external returns (address pair) {
        // 确定toeknA不等于TokenB
        require(tokenA != tokenB, 'UniswapV2: IDENTICAL_ADDRESSES');
        // 将tokenA和tokenB进行大小排序,确保tokenA小于tokenB
          // 小 大
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        // 确认token0 不等于0地址
        // 
        require(token0 != address(0), 'UniswapV2: ZERO_ADDRESS');
        // 确认配对映射地址不存在token0=>token1

        require(getPair[token0][token1] == address(0), 'UniswapV2: PAIR_EXISTS'); // single check is sufficient
        // 给bytecode 变量赋值 "uniswapV2pair" 合约的创建字节码   bytecode不定长

        bytes memory bytecode = type(UniswapV2Pair).creationCode;
        //将token0和token1 打包后创建哈希
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        /// 内联汇编 , 如果现有方法不能实现,可以通过内联汇编来实现
        // create2 optcode  
        // mload optcode 
        // solium-disable-next-line 
        assembly {
            //通过Create2方法部署合约,并且加盐,返回地址到pair变量
            // 内联汇编 ,如果现有方法不能实现 可以通过内联汇编实现
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }

        // 调用pair地址的合约中的"initialize",传入地址到pair变量\
        // 对pair合约进行调用
        IUniswapV2Pair(pair).initialize(token0, token1);

        //配置映射
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction

        // 配置数组推入pair地址
        allPairs.push(pair);
        // 触发配对成功事件
        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    /*
    
     @dev 设置收税源地址
     @param _feeTo 收税地址

    */

    function setFeeTo(address _feeTo) external {
        // 如果是调用者 
        require(msg.sender == feeToSetter, 'UniswapV2: FORBIDDEN');
        feeTo = _feeTo;
    }

    /*
     @dev 收税权限控制
     @param _feeTOseeter 收税权限控制
    */
    function setFeeToSetter(address _feeToSetter) external {
        require(msg.sender == feeToSetter, 'UniswapV2: FORBIDDEN');
        feeToSetter = _feeToSetter;
    }
}
