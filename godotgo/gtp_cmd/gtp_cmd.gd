class_name GTPCmd

# 命令注册表
var _commands = {}

# 连接管理器
var _connection_manager = null

# 构造函数
func _init():
	pass

# 设置连接管理器
func set_connection_manager(connection_manager):
	_connection_manager = connection_manager

# 注册命令
func register(command_name: String, handler: Callable):
	_commands[command_name] = handler

# 发送命令
func send(command_name: String, args: Array = []) -> Variant:
	if not _connection_manager:
		print("Error: Connection manager not set")
		return null

	# 构建命令字符串
	var command = command_name
	for arg in args:
		command += " " + str(arg)
	command += "\n"

	# 发送命令并等待响应
	var response = await _connection_manager.send_message_async(command)

	# 处理响应
	if response:
		# 检查是否有注册的处理函数
		if command_name in _commands:
			var parsed_response = _parse_response(response)
			return _commands[command_name].call(parsed_response)
		else:
			# 默认处理
			return response
	else:
		print("Error: No response from server")
		return null

# 处理GTP响应格式
func _parse_response(response: String) -> Dictionary:
	# 解析GTP响应格式
	var result = {
		"success": false,
		"id": "",
		"data": ""
	}

	if response.begins_with("="):
		result["success"] = true
		# 提取id和数据
		var parts = response.split(" ", false, 1)
		if parts.size() > 1:
			var id_part = parts[0].substr(1)
			result["id"] = id_part
			result["data"] = parts[1]
		else:
			result["id"] = ""
			result["data"] = ""
	elif response.begins_with("?"):
		result["success"] = false
		# 提取id和错误信息
		var parts = response.split(" ", false, 1)
		if parts.size() > 1:
			var id_part = parts[0].substr(1)
			result["id"] = id_part
			result["data"] = parts[1]
		else:
			result["id"] = ""
			result["data"] = ""

	return result
