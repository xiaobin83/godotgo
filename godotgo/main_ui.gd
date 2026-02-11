extends Node2D

# UI元素
@onready var _hostname_input = $VBoxContainer/LineEdit
@onready var _connect_button = $VBoxContainer/BtnConnect
@onready var _refresh_button = $VBoxContainer/BtnShowboard

# 连接管理器
@onready var _connection_manager = $ConnectionManager

# 棋盘相关
var _go_board
var _board_renderer

# 构造函数
func _ready():
	print("UI elements initialized")
	
	# 初始化棋盘和渲染器
	_go_board = GoBoard.new()
	_board_renderer = GoBoardSimpleRenderer.new(_go_board)
	
	# 连接信号
	_connect_button.pressed.connect(_on_connect_button_pressed)
	_refresh_button.pressed.connect(_on_refresh_button_pressed)
	
	_connection_manager.connected.connect(_on_connected)
	_connection_manager.disconnected.connect(_on_disconnected)
	_connection_manager.connection_error.connect(_on_connection_error)
	_connection_manager.message_received.connect(_on_message_received)
	
	# 直接从命令行参数获取
	var host = "127.0.0.1:12346"
	var auto_connect = false
	
	var args = OS.get_cmdline_args()
	print("Command line args: ", args)
	var i = 0
	while i < args.size():
		var arg = args[i]
		if arg == "--host" and i + 1 < args.size():
			host = args[i + 1]
			print("Host set to: ", host)
			i += 1
		elif arg == "--auto_connect":
			auto_connect = true
			print("Auto connect enabled")
		i += 1
	
	# 设置hostname输入框
	_hostname_input.text = host
	print("Host set to input box: ", host)
	
	# 自动连接
	if auto_connect:
		print("Auto connect enabled, attempting to connect...")
		_on_connect_button_pressed()
	else:
		print("Auto connect not enabled")

# 私有函数
func _draw():
	# 绘制棋盘
	if _board_renderer:
		_board_renderer.draw_board(self)

# 私有函数
func _on_connect_button_pressed():
	var hostname = _hostname_input.text
	print("Connect button pressed, hostname: ", hostname)
	if hostname and _connection_manager:
		var success = _connection_manager.connect_to_server(hostname)
		print("Connection attempt result: ", success)
	elif not _connection_manager:
		print("Cannot connect: connection_manager is null")

# 私有函数
func _on_connected():
	print("Connected to server")
	_connect_button.text = "Disconnect"
	_connect_button.pressed.disconnect(_on_connect_button_pressed)
	_connect_button.pressed.connect(_on_disconnect_button_pressed)

# 私有函数
func _on_disconnect_button_pressed():
	_connection_manager.disconnect_from_server()

# 私有函数
func _on_disconnected():
	print("Disconnected from server")
	_connect_button.text = "Connect"
	_connect_button.pressed.disconnect(_on_disconnect_button_pressed)
	_connect_button.pressed.connect(_on_connect_button_pressed)

# 私有函数
func _on_connection_error(error_message: String):
	print("Connection error: " + error_message)

# 私有函数
func _on_message_received(message: String):
	print("Received message: " + message)
	
	# 处理showboard命令的响应
	if message.begins_with("=showboard"):
		_go_board.parse_showboard_response(message)
		# 触发重绘
		queue_redraw()

# 私有函数
func _on_refresh_button_pressed():
	print("Refresh button pressed, sending showboard command")
	if _connection_manager:
		_connection_manager.send_message("showboard\n")
	else:
		print("Cannot send message: connection_manager is null")
