## array

数组可以在声明中指定长度，也可以动态变长 。

```

pragma solidity ^0.4.0;

contract C{

    uint[] public u =[1,2,3];

    string s ="abcdefg";

    uint[] c; // storage

    function g(){
        c =new uint[](7);
        c.length=10 ; // 可以修改storage数组
        c[9]=100;
    }

    function h() public returns (uint)
    {
        return bytes(s).length;
    }
    function f() public returns(byte){
        return bytes(s)[1]; // 转为数组访问
    }


}

```

### 创建内存数组

可以使用 new 关键宇创建一个存储在 memory 上的数组。与存储在 storage 上的数组不同的是， 该数组不能通过成员.length 的值来修改数组的大小属性。 我们来看看下面的例子:



数组有一个 length 的成员属性，表示当前的数组长度 。 对于存储在 storage 的变长数组 ，可以通过给.length 赋值调整数组长度 。 而存储在 memory 的变长 数组不支 持修改 .length 调整数组长度 。
注意，不能通过访 问超出当前数组长度的方式，来自动实现改变数组长度 。 存储在 memo叩的 数组虽然可以通过参数灵活指定长度，但一旦创建， 长度便不可调整。



