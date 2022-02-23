## 值类型 

- 有理数字面量

- address 字面量
- 固定大小字节数组 
  - bytes1
  - bytes2 
  - bytes3

- Contract 
- Address 
- Integer 
  - uint8
  - int8

- 字符串字面量
- 十六进制字面量
- 枚举（enum）
- 函数类型
- Boolean
  - true
  - false
- 定点数字 
  - fixed8x8

## 引用类型

- 数组
  - uint[5]
  - uint[]
  - unit8[][5]

- 字符串string
- 动态字节数组 bytes
- 结构体 struct
- 映射 mapping

## 小结

- 值类型：当用函数参数或者赋值的时候始终执行的是复制操作。
- 引用类型：不一定是赋引用，根据数据的不同有可能执行复制，也可能赋引用。


### Integers类型

- integer分类无符号和有符号两种类型
- 8位1字节 int8占8位 
- uint8 1-255
- int的范围 -128 ~127
- X<<Y X*2**Y
- X>>Y X/2**Y

