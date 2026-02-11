class_name GoBoard

# 普通变量
var _board_size: int = 19
var _board = []
var _captured_black: int = 0
var _captured_white: int = 0

# 常量
const EMPTY = 0
const BLACK = 1
const WHITE = 2
const STAR_POINT = 3

# 构造函数
func _init():
	set_board_size(_board_size)

# 公有函数
func set_board_size(size: int):
	_board_size = size
	# 初始化棋盘
	_board = []
	for i in range(_board_size):
		var row = []
		for j in range(_board_size):
			row.append(EMPTY)
		_board.append(row)
	# 标记星位
	_mark_star_points()

# 私有函数
func _mark_star_points():
	# 标记星位
	if _board_size >= 9:
		# 中心星位
		var center :int = _board_size / 2
		_board[center][center] = STAR_POINT
	
	if _board_size >= 13:
		# 边上的星位
		var edge = 3
		_board[edge][edge] = STAR_POINT
		_board[edge][_board_size - 1 - edge] = STAR_POINT
		_board[_board_size - 1 - edge][edge] = STAR_POINT
		_board[_board_size - 1 - edge][_board_size - 1 - edge] = STAR_POINT

# 公有函数
func parse_showboard_response(response: String):
	# 解析 showboard 命令的响应
	# 这里需要根据实际的响应格式实现解析逻辑
	# 暂时使用默认值
	pass

# 公有函数
func set_stone(x: int, y: int, color: int):
	if x >= 0 and x < _board_size and y >= 0 and y < _board_size:
		_board[y][x] = color

# 公有函数
func get_stone(x: int, y: int) -> int:
	if x >= 0 and x < _board_size and y >= 0 and y < _board_size:
		return _board[y][x]
	return EMPTY

# 公有函数
func get_board_size() -> int:
	return _board_size

# 公有函数
func get_captured_black() -> int:
	return _captured_black

# 公有函数
func get_captured_white() -> int:
	return _captured_white

# 公有函数
func set_captured_black(count: int):
	_captured_black = count

# 公有函数
func set_captured_white(count: int):
	_captured_white = count
