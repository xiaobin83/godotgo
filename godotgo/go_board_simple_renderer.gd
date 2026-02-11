class_name GoBoardSimpleRenderer

# 普通变量
var _go_board
var _position: Vector2 = Vector2(100, 100)
var _scale: float = 0.8
var _cell_size: float = 30.0


# 构造函数
func _init(board = null):
	_go_board = board

# 公有函数
func set_go_board(board):
	_go_board = board

# 公有函数
func set_position(pos: Vector2):
	_position = pos

# 公有函数
func set_scale(s: float):
	_scale = s

# 公有函数
func set_cell_size(size: float):
	_cell_size = size

# 公有函数
func get_board_rect() -> Rect2:
	var board_pixel_size = _cell_size * (_go_board.get_board_size() - 1)
	return Rect2(_position, Vector2(board_pixel_size, board_pixel_size))

# 公有函数
func draw_board(canvas_item: CanvasItem):
	if not _go_board:
		return

	var board_size = _go_board.get_board_size()
	
	# 获取CanvasItem的大小
	var canvas_size = canvas_item.get_viewport().size
	
	# 计算最大可能的棋盘大小，保持1:1比例
	var max_board_size = min(canvas_size.x, canvas_size.y) - 80  # 留出边距
	var scaled_cell_size = max_board_size / (board_size - 1)
	var scaled_board_pixel_size = scaled_cell_size * (board_size - 1)
	
	# 计算棋盘位置，使其居中
	var board_position = Vector2(
		(canvas_size.x - scaled_board_pixel_size) / 2,
		(canvas_size.y - scaled_board_pixel_size) / 2
	)
	
	# 绘制棋盘边框
	var border_rect = Rect2(
		board_position - Vector2(5, 5),
		Vector2(scaled_board_pixel_size + 10, scaled_board_pixel_size + 10)
	)
	canvas_item.draw_rect(border_rect, Color(0.8, 0.6, 0.4))
	
	# 绘制棋盘网格
	for i in range(board_size):
		var y = i * scaled_cell_size
		canvas_item.draw_line(
			board_position + Vector2(0, y),
			board_position + Vector2(scaled_board_pixel_size, y),
			Color(0, 0, 0)
		)
		var x = i * scaled_cell_size
		canvas_item.draw_line(
			board_position + Vector2(x, 0),
			board_position + Vector2(x, scaled_board_pixel_size),
			Color(0, 0, 0)
		)
	
	# 绘制星位
	_mark_star_points(canvas_item, board_position, scaled_cell_size)
	
	# 绘制棋子
	_draw_stones(canvas_item, board_position, scaled_cell_size)
	
	# 绘制坐标标记
	_draw_coordinates(canvas_item, board_position, scaled_cell_size, canvas_size)
	
	# 绘制俘虏数
	_draw_captured_info(canvas_item, board_position, scaled_cell_size, canvas_size)

# 私有函数
func _mark_star_points(canvas_item: CanvasItem, position: Vector2, scaled_cell_size: float):
	var board_size = _go_board.get_board_size()
	
	if board_size >= 9:
		# 中心星位
		var center = board_size / 2
		canvas_item.draw_circle(
			position + Vector2(int(center) * scaled_cell_size, int(center) * scaled_cell_size),
			3,
			Color(0, 0, 0)
		)
	
	if board_size >= 13:
		# 边上的星位
		var edge = 3
		canvas_item.draw_circle(
			position + Vector2(edge * scaled_cell_size, edge * scaled_cell_size),
			3,
			Color(0, 0, 0)
		)
		canvas_item.draw_circle(
			position + Vector2(edge * scaled_cell_size, (board_size - 1 - edge) * scaled_cell_size),
			3,
			Color(0, 0, 0)
		)
		canvas_item.draw_circle(
			position + Vector2((board_size - 1 - edge) * scaled_cell_size, edge * scaled_cell_size),
			3,
			Color(0, 0, 0)
		)
		canvas_item.draw_circle(
			position + Vector2((board_size - 1 - edge) * scaled_cell_size, (board_size - 1 - edge) * scaled_cell_size),
			3,
			Color(0, 0, 0)
		)

# 私有函数
func _draw_stones(canvas_item: CanvasItem, position: Vector2, scaled_cell_size: float):
	var board_size = _go_board.get_board_size()
	var EMPTY = GoBoard.EMPTY
	var BLACK = GoBoard.BLACK
	var WHITE = GoBoard.WHITE
	
	for y in range(board_size):
		for x in range(board_size):
			var stone = _go_board.get_stone(x, y)
			if stone == BLACK:
				canvas_item.draw_circle(
					position + Vector2(x * scaled_cell_size, y * scaled_cell_size),
					scaled_cell_size / 2 - 2,
					Color(0, 0, 0)
				)
			elif stone == WHITE:
				canvas_item.draw_circle(
					position + Vector2(x * scaled_cell_size, y * scaled_cell_size),
					scaled_cell_size / 2 - 2,
					Color(1, 1, 1)
				)
				canvas_item.draw_circle(
					position + Vector2(x * scaled_cell_size, y * scaled_cell_size),
					scaled_cell_size / 2 - 2,
					Color(0, 0, 0),
					false,
					2
				)

# 私有函数
func _draw_coordinates(canvas_item: CanvasItem, position: Vector2, scaled_cell_size: float, canvas_size: Vector2):
	var board_size = _go_board.get_board_size()
	var scaled_board_pixel_size = scaled_cell_size * (board_size - 1)
	var font = ThemeDB.fallback_font
	
	# 绘制横向坐标（字母）
	for i in range(board_size):
		var letter = "ABCDEFGHJKLMNOPQRST"[i]
		# 顶部坐标（挨着棋盘上边）
		canvas_item.draw_string(
			font,
			position + Vector2(i * scaled_cell_size - 5, -15),
			letter
		)
		# 底部坐标（挨着棋盘下边，向下移动5像素）
		canvas_item.draw_string(
			font,
			position + Vector2(i * scaled_cell_size - 5, scaled_board_pixel_size + 25),
			letter
		)
	
	# 绘制纵向坐标（数字）
	for i in range(board_size):
		var number = str(board_size - i)
		# 左侧坐标（挨着棋盘左边）
		canvas_item.draw_string(
			font,
			position + Vector2(-30, i * scaled_cell_size + 5),
			number
		)
		# 右侧坐标（挨着棋盘右边）
		canvas_item.draw_string(
			font,
			position + Vector2(scaled_board_pixel_size + 15, i * scaled_cell_size + 5),
			number
		)

# 私有函数
func _draw_captured_info(canvas_item: CanvasItem, position: Vector2, scaled_cell_size: float, canvas_size: Vector2):
	var board_size = _go_board.get_board_size()
	var scaled_board_pixel_size = scaled_cell_size * (board_size - 1)
	var font = ThemeDB.fallback_font
	
	# 绘制俘虏数
	var captured_text = "Black captured: %d\nWhite captured: %d" % [_go_board.get_captured_black(), _go_board.get_captured_white()]
	canvas_item.draw_string(
		font,
		Vector2(canvas_size.x - 150, 20),
		captured_text
	)

# 公有函数
func get_cell_at_position(pos: Vector2) -> Vector2:
	# 注意：此函数可能需要根据实际使用情况进行调整
	# 因为现在棋盘位置和大小是动态计算的
	# 暂时保留原有逻辑，后续可能需要修改
	var local_pos = (pos - _position) / _scale
	var x = int(round(local_pos.x / _cell_size))
	var y = int(round(local_pos.y / _cell_size))
	
	if x >= 0 and x < _go_board.get_board_size() and y >= 0 and y < _go_board.get_board_size():
		return Vector2(x, y)
	return Vector2(-1, -1)
