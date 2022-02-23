### 固定大小字节数组
```
pragma solidity ^0.4.24;

//

contract BytesContract{
    
    bytes2 public num=256;


    // 通过下标获取指定字节的值
    function getLowByte() public view returns(byte){
        return num[1];

    }


    // 不能修改固定大小字节数组
    // function modifyHightByte() public{
    //     num[1]=1;
    // }
    
//  返回长度是字节数
   function getDataLength() public pure returns(uint8,uint8){
       bytes4 dataA=256;
       bytes5 dataB="0x01";
       return (dataA.length,dataB.length);
   }



}
 
```

- 0x0100 是256的十六进制
- 字节数组的长度是返回长度是字节数

## 固定大小字节数组与字符串

```
pragma solidity ^0.4.24;

//

contract BytesContract{
    
    bytes12 public hello = "hello,中国";

    // 获取指定字节位置的数据
    function getByte(uint8 index) public view returns(byte){
        return hello[index];
    }

    //获取最后一个字节
    function getLast() public view returns(byte){
        return hello[hello.length-1];
    }


}
 
```

- 字符串字面量存储的是UTF-8编码
- 固定大小字节数组
  - bytesX 高转低，低截断
  - bytesX 低转高，低补0 