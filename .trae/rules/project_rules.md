# 项目规则文档

## GDScript

### 1. 命名规则

#### 1.1 类私有变量
- 使用下划线开头的蛇形命名法：`_snake_case`
- 示例：`_private_variable`

#### 1.2 私有函数
- 使用下划线开头的蛇形命名法：`_snake_case`
- 示例：`_private_function()`

#### 1.3 公有函数
- 使用蛇形命名法：`snake_case`
- 示例：`public_function()`

#### 1.4 常量
- 使用全大写的蛇形命名法：`SNAKE_CASE`
- 示例：`MAX_SIZE`

#### 1.5 类名
- 使用帕斯卡命名法：`PascalCase`
- 示例：`GoBoard`

#### 1.6 普通变量
- 使用蛇形命名法：`snake_case`
- 示例：`board_size`

### 2. 代码风格

#### 2.1 缩进
- 使用 tab 键进行缩进
- 避免使用制表符

#### 2.2 空行
- 在类定义、函数定义之间使用空行
- 在逻辑块之间使用空行提高可读性

#### 2.3 注释
- 使用 `#` 进行单行注释
- 对复杂逻辑和关键算法添加详细注释

### 2.4 字符串
- 使用单引号：`'string'`
- 示例：`'Hello, World!'`

### 3. 示例代码

```gdscript
class_name ExampleClass

# 公有变量
var public_variable: int = 0

# 私有变量
var _private_variable: int = 0

# 常量
const CONSTANT_VALUE = 100

# 构造函数
func _init():
    pass

# 公有函数
func public_function():
    pass

# 私有函数
func _private_function():
    pass
```

### 4. 注意事项

- 遵循 Godot 引擎的 GDScript 语法规范
- 保持代码风格一致
- 优先考虑代码可读性
- 避免使用过长的函数和类
