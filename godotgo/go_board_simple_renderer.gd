extends Control
class_name GoBoardSimpleRenderer

# 普通变量
var _go_board: GoBoard

# 构造函数
func set_board(board: GoBoard):
	_go_board = board

# 公有函数
func set_go_board(board):
	_go_board = board

# 公有函数
func _draw():
	if not _go_board:
		return

	var board_size = _go_board.get_board_size()
	
	# 获取CanvasItem的大小
	var canvas_size = self.size
	
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
	draw_rect(border_rect, Color(0.8, 0.6, 0.4))
	
	# 绘制棋盘网格
	for i in range(board_size):
		var y = i * scaled_cell_size
		draw_line(
			board_position + Vector2(0, y),
			board_position + Vector2(scaled_board_pixel_size, y),
			Color(0, 0, 0)
		)
		var x = i * scaled_cell_size
		draw_line(
			board_position + Vector2(x, 0),
			board_position + Vector2(x, scaled_board_pixel_size),
			Color(0, 0, 0)
		)
	
	# 绘制星位
	_mark_star_points(board_position, scaled_cell_size)
	
	# 绘制棋子
	_draw_stones(board_position, scaled_cell_size)
	
	# 绘制坐标标记
	_draw_coordinates(board_position, scaled_cell_size)

# 私有函数
func _mark_star_points(pos: Vector2, scaled_cell_size: float):
	var board_size = _go_board.get_board_size()
	
	if board_size >= 9:
		# 中心星位
		var center = board_size / 2
		draw_circle(
			pos + Vector2(int(center) * scaled_cell_size, int(center) * scaled_cell_size),
			3,
			Color(0, 0, 0)
		)
	
	if board_size >= 13:
		# 边上的星位
		var edge = 3
		draw_circle(
			pos + Vector2(edge * scaled_cell_size, edge * scaled_cell_size),
			3,
			Color(0, 0, 0)
		)
		draw_circle(
			pos + Vector2(edge * scaled_cell_size, (board_size - 1 - edge) * scaled_cell_size),
			3,
			Color(0, 0, 0)
		)
		draw_circle(
			pos + Vector2((board_size - 1 - edge) * scaled_cell_size, edge * scaled_cell_size),
			3,
			Color(0, 0, 0)
		)
		draw_circle(
			pos + Vector2((board_size - 1 - edge) * scaled_cell_size, (board_size - 1 - edge) * scaled_cell_size),
			3,
			Color(0, 0, 0)
		)

# 私有函数
func _draw_stones(pos: Vector2, scaled_cell_size: float):
	var board_size = _go_board.get_board_size()
	var EMPTY = GoBoard.EMPTY
	var BLACK = GoBoard.BLACK
	var WHITE = GoBoard.WHITE
	
	for y in range(board_size):
		for x in range(board_size):
			var stone = _go_board.get_stone(x, y)
			if stone == BLACK:
				draw_circle(
					pos + Vector2(x * scaled_cell_size, y * scaled_cell_size),
					scaled_cell_size / 2 - 2,
					Color(0, 0, 0)
				)
			elif stone == WHITE:
				draw_circle(
					pos + Vector2(x * scaled_cell_size, y * scaled_cell_size),
					scaled_cell_size / 2 - 2,
					Color(1, 1, 1)
				)
				draw_circle(
					pos + Vector2(x * scaled_cell_size, y * scaled_cell_size),
					scaled_cell_size / 2 - 2,
					Color(0, 0, 0),
					false,
					2
				)

# 私有函数
func _draw_coordinates(pos: Vector2, scaled_cell_size: float):
	var board_size = _go_board.get_board_size()
	var scaled_board_pixel_size = scaled_cell_size * (board_size - 1)
	var font = ThemeDB.fallback_font
	
	# 绘制横向坐标（字母）
	for i in range(board_size):
		var letter = "ABCDEFGHJKLMNOPQRST"[i]
		# 顶部坐标（挨着棋盘上边）
		draw_string(
			font,
			pos + Vector2(i * scaled_cell_size - 5, -15),
			letter
		)
		# 底部坐标（挨着棋盘下边，向下移动5像素）
		draw_string(
			font,
			pos + Vector2(i * scaled_cell_size - 5, scaled_board_pixel_size + 25),
			letter
		)
	
	# 绘制纵向坐标（数字）
	for i in range(board_size):
		var number = str(board_size - i)
		# 左侧坐标（挨着棋盘左边）
		draw_string(
			font,
			pos + Vector2(-30, i * scaled_cell_size + 5),
			number
		)
		# 右侧坐标（挨着棋盘右边）
		draw_string(
			font,
			pos + Vector2(scaled_board_pixel_size + 15, i * scaled_cell_size + 5),
			number
		)
