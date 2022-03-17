pragma solidity =0.5.16;

import './interfaces/IUniswapV2Pair.sol';
import './UniswapV2ERC20.sol';
import './libraries/Math.sol';
import './libraries/UQ112x112.sol';
import './interfaces/IERC20.sol';
import './interfaces/IUniswapV2Factory.sol';
import './interfaces/IUniswapV2Callee.sol';
//Uniswap配对合约

/*
三大功能
- swap
- burn
- mint 

*/
contract UniswapV2Pair is IUniswapV2Pair, UniswapV2ERC20 {
    // 库 
    using SafeMath  for uint;

    using UQ112x112 for uint224;



    // 最小流动性 =1000 
    uint public constant MINIMUM_LIQUIDITY = 10**3;
    // selector 常量值为 'transfer(address,uint256)' 字符串哈希值的前4位16进制数字
    // trsanction  input Data --> methodID 8个字符  [0][1] 是参数
    // 
    bytes4 private constant SELECTOR = bytes4(keccak256(bytes('transfer(address,uint256)')));

    address public factory;  // 工厂地址
    address public token0;   // token0 地址
    address public token1;   // token1 地址

    uint112 private reserve0;   // 存储量0        // uses single storage slot, accessible via getReserves
    uint112 private reserve1;   // 储备量1         // uses single storage slot, accessible via getReserves
    uint32  private blockTimestampLast;  // 更新储备量的最后时间戳  // uses single storage slot, accessible via getReserves

// 价格0最后累计
    uint public price0CumulativeLast;
// 价格1最后累计
    uint public price1CumulativeLast;

    uint public kLast; // reserve0 * reserve1, as of immediately after the most recent liquidity event

/*
 @dev 修饰符: 锁定运行防止重入
*/ 
    uint private unlocked = 1;

    modifier lock() {
        require(unlocked == 1, 'UniswapV2: LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }
/*
 @return _reserve0 存储量0
 @return _reserve1 存储量1
 @_blockTimestampLast 时间戳
 @dev 获取储备

*/
    function getReserves() public view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast) {
        _reserve0 = reserve0;
        _reserve1 = reserve1;
        _blockTimestampLast = blockTimestampLast;
    }

/*
@param token token地址
@param to to地址
@value value 数额
@dev 私有安全发送
*/
    function _safeTransfer(address token, address to, uint value) private {
        //调用token合约地址的低级transfer方法
        // solium-disable-next-line    防止报错
        // call底层呼叫
        // 在你没有接口ABI的情况下 也是可以调用的
        // 4位16进制值

    

        /*
           bytes4 private constant SELECTOR = bytes4(keccak256(bytes('transfer(address,uint256)')));

          一个合约调用另外一个合约
          通过接口合约调用
          没有接口合约,通过底层的call
        */
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(SELECTOR, to, value));
        // 确认返回值为true 并且返回的data长度为0或者解码后为true
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'UniswapV2: TRANSFER_FAILED');
    }

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
  
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );

    /*
@dev 事件:同步
@param reserve0 储备量0
@param reserve1 储备量1

*/
    event Sync(uint112 reserve0, uint112 reserve1);


/*
@dev 构造函数
*/
    constructor() public {
        // factory 地址就是合约部署着
        factory = msg.sender;
    }


/*
@param _token0 token0
@param _token1 token1
@dev 初始化方法,部署时由工厂调用一次
*/
    // called once by the factory at time of deployment
    function initialize(address _token0, address _token1) external {
        // 确认调用者为工厂地址
        require(msg.sender == factory, 'UniswapV2: FORBIDDEN'); // sufficient check
        token0 = _token0;
        token1 = _token1;
    }
 
    // update reserves and, on the first call per block, price accumulators
/*
 @param balance0 余额0 
 @param balance1 余额1 
 @param _reserve0 储备0 
 @param _reserve1 储备1
 @dev 更新储量,并在每个区块的第一次调用时更新价格累加器
*/
    function _update(uint balance0, uint balance1, uint112 _reserve0, uint112 _reserve1) private {
        // 确认余额0和余额1小于等于最大的uint112 
        require(balance0 <= uint112(-1) && balance1 <= uint112(-1), 'UniswapV2: OVERFLOW');
        // 区块链时间戳,将时间戳转化为uint32
        //solium-disable-next-line
        // 32位
        uint32 blockTimestamp = uint32(block.timestamp % 2**32);
        // 计算时间流失
        uint32 timeElapsed = blockTimestamp - blockTimestampLast; // overflow is desired
        // 如果时间流逝大于0 ,并且储备量0,1不等于0
        if (timeElapsed > 0 && _reserve0 != 0 && _reserve1 != 0) {
            // * never overflows, and + overflow is desired
            // 价格0最后累计
            price0CumulativeLast += uint(UQ112x112.encode(_reserve1).uqdiv(_reserve0)) * timeElapsed;

            price1CumulativeLast += uint(UQ112x112.encode(_reserve0).uqdiv(_reserve1)) * timeElapsed;
        }
        // 将余额0,1 放入储备量0,1 
        reserve0 = uint112(balance0);
        reserve1 = uint112(balance1);
        // 更新最后的时间戳
        blockTimestampLast = blockTimestamp;
        // 触发同步事件
        emit Sync(reserve0, reserve1);
    }

    // if fee is on, mint liquidity equivalent to 1/6th of the growth in sqrt(k)
    /*
     @param _reverse0 储备量0 
     @param _reverse1 储备量1 
     @return feeOn
     @dev 如果收费,铸造流动性相当于1/6的增长sqrt(k)
    */
    function _mintFee(uint112 _reserve0, uint112 _reserve1) private returns (bool feeOn) {
       // 查询工厂合约的feeTo变量值
        address feeTo = IUniswapV2Factory(factory).feeTo();
        // 如果feeTo不等于0地址,feeOn等于true否则等于false
        feeOn = feeTo != address(0);
        // 定义key值
        uint _kLast = kLast; // gas savings
        // 如果feeOn=true
        if (feeOn) {
            // k不等于0 
            if (_kLast != 0) {
                // 计算储备量的k
                // 取平方根
                uint rootK = Math.sqrt(uint(_reserve0).mul(_reserve1));
                // 计算k的平方根
                uint rootKLast = Math.sqrt(_kLast);

                if (rootK > rootKLast) {
                    // 分子
                    uint numerator = totalSupply.mul(rootK.sub(rootKLast));
                    // 分母
                    uint denominator = rootK.mul(5).add(rootKLast);
                    //流动性
                    uint liquidity = numerator / denominator;
                    // 如果流动性>0 将流动性铸造给feeTo地址
                    if (liquidity > 0) _mint(feeTo, liquidity);
                }
            }
        } else if (_kLast != 0) {
            kLast = 0;
        }
    }

    // this low-level function should be called from a contract which performs important safety checks
    /*
    @param to to地址
    @return liquidity 流动性数量
    @dev 铸造方法
    @notice 应该从执行重要安全检查的合同中调用此低级功能

    铸造给谁


     */
     
    function mint(address to) external lock returns (uint liquidity) {
        // 获取储备量
        // 第三个值留空了
        (uint112 _reserve0, uint112 _reserve1,) = getReserves(); // gas savings
        // 获取token的余额
        uint balance0 = IERC20(token0).balanceOf(address(this));
        // 获取token1的余额
        uint balance1 = IERC20(token1).balanceOf(address(this));
        // amount0 = 余额0-存储0
        uint amount0 = balance0.sub(_reserve0);
         // amount1 = 余额1-存储1
        uint amount1 = balance1.sub(_reserve1);

// 返回铸造费开关
        bool feeOn = _mintFee(_reserve0, _reserve1);
        // 获取totalsupply 必须在此处定义,因为totalsupply 可以在mintFee中更新
        uint _totalSupply = totalSupply; // gas savings, must be defined here since totalSupply can update in _mintFee
        //如果_totalsupply =0 
        if (_totalSupply == 0) {
            // 流动性 = (数量0*数量1)的平方根 - 最小的流动性
            liquidity = Math.sqrt(amount0.mul(amount1)).sub(MINIMUM_LIQUIDITY);
            // 在总量为0 的初始状态,永久性锁定最低流动性
           _mint(address(0), MINIMUM_LIQUIDITY); // permanently lock the first MINIMUM_LIQUIDITY tokens
        } else {
            // 流动性 最小值
            liquidity = Math.min(amount0.mul(_totalSupply) / _reserve0, amount1.mul(_totalSupply) / _reserve1);
        }

        require(liquidity > 0, 'UniswapV2: INSUFFICIENT_LIQUIDITY_MINTED');
        // 铸造流动性给to地址
        _mint(to, liquidity);

        // 更新储备量
        _update(balance0, balance1, _reserve0, _reserve1);
        //  如果铸造开关为true k值= 储备量0 * 储备量1\
        // AMM 固定乘积算法
         // KLast 就是 k值    reserve0 x   Y 

        if (feeOn) kLast = uint(reserve0).mul(reserve1); // reserve0 and reserve1 are up-to-date
        emit Mint(msg.sender, amount0, amount1);
    }

    // this low-level function should be called from a contract which performs important safety checks
    /*
     @dev 销毁方法
     @notice 应该从执行重要检查的合同中调用此低级功能

     取出储备量

     lock防止重入开关

     发给配对合约,根据自身

    */
    function burn(address to) 
    external 
    lock returns (uint amount0, uint amount1) {
        // 获取储备量0 储备1  
        (uint112 _reserve0, uint112 _reserve1,) = getReserves(); // gas savings
         // 带入变量  全局变量赋值给临时变量可以节省gas
        address _token0 = token0;                                // gas savings
        address _token1 = token1;                                   // gas savings
        // 获取当前合约在token0合约内的余额
        uint balance0 = IERC20(_token0).balanceOf(address(this));
        // 获取当前合约在token1合约内的余额
        uint balance1 = IERC20(_token1).balanceOf(address(this));
        // 获取当前合约自身的流动性数量
        uint liquidity = balanceOf[address(this)];
         // 返回铸造费的开关
        bool feeOn = _mintFee(_reserve0, _reserve1);
        //获取totalSuppy  必须在此定义  因为totalsupply 可以在mintFee中更新

        uint _totalSupply = totalSupply; // gas savings, must be defined here since totalSupply can update in _mintFee
        // amount0 =流动性数量 *余额0 / totalsupply   使用余额确保按比例分配  
        amount0 = liquidity.mul(balance0) / _totalSupply; // using balances ensures pro-rata distribution
        // amount1 =流动性数量 *余额1 / totalsupply   使用余额确保按比例分配 
        amount1 = liquidity.mul(balance1) / _totalSupply; // using balances ensures pro-rata distribution
        // 确保 amount0 和amount1 都大于0 
        require(amount0 > 0 && amount1 > 0, 'UniswapV2: INSUFFICIENT_LIQUIDITY_BURNED');
        // 销毁当前合约的流动性
        _burn(address(this), liquidity);
        // 将amount0数量的_token0发送到to地址
        _safeTransfer(_token0, to, amount0);
          // 将amount1数量的_token1发送到to地址
        _safeTransfer(_token1, to, amount1);
        // 更新balance0
        balance0 = IERC20(_token0).balanceOf(address(this));
        balance1 = IERC20(_token1).balanceOf(address(this));

        // 更新储存量
        
        _update(balance0, balance1, _reserve0, _reserve1);
        // 如果铸造费开发为true  k值 = 储备量0 * 储备量1 
        if (feeOn) kLast = uint(reserve0).mul(reserve1); // reserve0 and reserve1 are up-to-date
        // 发送销毁事件
        // ERC20不一样
        emit Burn(msg.sender, amount0, amount1, to);
    }

    // this low-level function should be called from a contract which performs important safety checks
    /*
    用户交换
    @param  amount0Out 输出数额0
    @param  amount1Out 输出数额1
    @param  to to地址
    @param  data 用于回调的数据
    @dev 交换方法
    @notice 应该从执行重要检查的合同中调用此低级功能

    收税在路由合约
    */
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external lock {
        //大于0 

        require(amount0Out > 0 || amount1Out > 0, 'UniswapV2: INSUFFICIENT_OUTPUT_AMOUNT');
        // 存储量
        (uint112 _reserve0, uint112 _reserve1,) = getReserves(); // gas savings
         // 输出量 < 存储量
        require(amount0Out < _reserve0 && amount1Out < _reserve1, 'UniswapV2: INSUFFICIENT_LIQUIDITY');

   
        uint balance0;
        uint balance1;
       
        // {} 作用域 变量出不去
        // 避免堆栈太深
        { // scope for _token{0,1}, avoids stack too deep errors

        address _token0 = token0;
        
        address _token1 = token1;
        //确保to地址
        require(to != _token0 && to != _token1, 'UniswapV2: INVALID_TO');
        // token0
        if (amount0Out > 0) _safeTransfer(_token0, to, amount0Out); // optimistically transfer tokens

        if (amount1Out > 0) _safeTransfer(_token1, to, amount1Out); // optimistically transfer tokens
       
        if (data.length > 0) 
        // 闪电贷功能
        IUniswapV2Callee(to).uniswapV2Call(
            msg.sender, 
            amount0Out,
            amount1Out, 
            data);

         
        balance0 = IERC20(_token0).balanceOf(address(this));
        balance1 = IERC20(_token1).balanceOf(address(this));
        }
        // 如果 余额0 > 储备0 - amount0out 则 amount0In = 余额0 -( 储备0 - amount0out) 否则 amount0In=0
        uint amount0In = balance0 > _reserve0 - amount0Out ? balance0 - (_reserve0 - amount0Out) : 0;
        //同理
        uint amount1In = balance1 > _reserve1 - amount1Out ? balance1 - (_reserve1 - amount1Out) : 0;

        require(amount0In > 0 || amount1In > 0, 'UniswapV2: INSUFFICIENT_INPUT_AMOUNT');

        { // scope for reserve{0,1}Adjusted, avoids stack too deep errors
        
        uint balance0Adjusted = balance0.mul(1000).sub(amount0In.mul(3));
        
        uint balance1Adjusted = balance1.mul(1000).sub(amount1In.mul(3));
        // 用这种方式证明之前的交易收税了
        require(balance0Adjusted.mul(balance1Adjusted) >= uint(_reserve0)
        .mul(_reserve1)
        .mul(1000**2), 'UniswapV2: K');
        
        }
        // 更新储备量
        _update(balance0, balance1, _reserve0, _reserve1);
        // 触发交换事件
        emit Swap(msg.sender, amount0In, amount1In, amount0Out, amount1Out, to);
    }

    // force balances to match reserves
    /*
  
     @dev 强制平衡以匹配储备
    */
    function skim(address to) external lock {
        //节约gas
        address _token0 = token0; // gas savings
        address _token1 = token1; // gas savings
        // 将当前合约的token0,1 的余额-储备量0,1 安全发送到to地址
        _safeTransfer(_token0, 
        to, 
        IERC20(_token0).balanceOf(address(this)).sub(reserve0));

        _safeTransfer(_token1, to, IERC20(_token1).balanceOf(address(this)).sub(reserve1));
    }

    // force reserves to match balances

    /*
     @dev 强制准备金与余额匹配 没听懂
    */ 
    function sync() external lock {

        _update(
        IERC20(token0).balanceOf(address(this)), 
        IERC20(token1).balanceOf(address(this)), 
        reserve0, 
        reserve1);
    }
}
