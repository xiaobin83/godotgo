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
	var lines = response.split("\n")
	
	# 解析横坐标
	var column_labels = []
	if lines.size() >= 1:
		column_labels = lines[1].strip_edges().split(" ")
	
	# 解析棋盘数据
	var row_data_start = 1
	var row_data_end = lines.size() - 1
	
	# 找到棋盘数据的结束位置（最后一行横坐标之前）
	for i in range(lines.size() - 1, row_data_start - 1, -1):
		var line = lines[i].strip_edges()
		if line.length() > 0 and line[0] >= 'A' and line[0] <= 'T':
			row_data_end = i - 1
			break
	
	# 解析每一行棋盘数据
	for i in range(row_data_start, row_data_end + 1):
		var line = lines[i].strip_edges()
		if line.length() == 0:
			continue
		
		# 提取行号
		var parts = line.split(" ")
		
		var row_num_str = parts[0]
		var row_num = int(row_num_str)
		if row_num < 1 or row_num > _board_size:
			continue
		
		# 计算数组行索引（从19到1，转换为从0到18）
		var board_row = _board_size - row_num
		
		# 解析棋盘格子
		for j in range(1, parts.size() - 1):
			var cell = parts[j]
			if j - 1 < column_labels.size():
				var col_label = column_labels[j - 1]
				var board_col = _get_column_index(col_label)
				
				if board_col >= 0 and board_col < _board_size:
					# 设置棋盘状态
					if cell == "X":
						_board[board_row][board_col] = BLACK
					elif cell == "O":
						_board[board_row][board_col] = WHITE
					elif cell == ".":
						_board[board_row][board_col] = EMPTY
					# 星位保持不变，不覆盖
	
	# 提取捕获棋子数量
	_extract_captured_stones(lines)

# 私有函数
func _get_column_index(col_label: String) -> int:
	# 将字母坐标转换为数组索引
	if col_label.length() != 1:
		return -1
	
	var char_code = ord(col_label[0])
	if char_code >= ord('A') and char_code <= ord('T'):
		var index = char_code - ord('A')
		# 跳过'I'，因为围棋棋盘坐标中没有I
		if index >= 8:  # 'I'的位置
			index -= 1
		return index
	return -1

# 私有函数
func _extract_captured_stones(lines: Array):
	# 提取捕获棋子数量
	for line in lines:
		line = line.strip_edges()
		if line.find("WHITE (O) has captured") != -1:
			# 提取白棋捕获数量
			var parts = line.split(" ")
			for part in parts:
				_captured_white = int(part)
				break
		elif line.find("BLACK (X) has captured") != -1:
			# 提取黑棋捕获数量
			var parts = line.split(" ")
			for part in parts:
				_captured_black = int(part)
				break

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
