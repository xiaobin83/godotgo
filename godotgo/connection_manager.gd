extends Node

# 信号定义
signal connected
signal disconnected
signal message_received(message)
signal connection_error(error_message)

# TCP连接对象
var _tcp = StreamPeerTCP.new()

# 主机和端口
var _host = ""
var _port = 0

func connect_to_server(hostname: String) -> bool:
	# 解析主机名和端口
	var parts = hostname.split(":")
	if parts.size() != 2:
		connection_error.emit("Invalid hostname format. Expected format: host:port")
		return false
	
	_host = parts[0]
	_port = int(parts[1])
	
	# 重置连接
	if _tcp.get_status() != StreamPeerTCP.STATUS_NONE:
		_tcp.disconnect_from_host()
	
	# 尝试连接
	var err = _tcp.connect_to_host(_host, _port)
	if err != OK:
		connection_error.emit("Failed to connect to server: " + str(err))
		return false
	
	# 设置连接状态
	connected.emit()
	
	return true

func disconnect_from_server():
	if _tcp.get_status() == StreamPeerTCP.STATUS_CONNECTED:
		_tcp.disconnect_from_host()
		disconnected.emit()

func send_message(message: String):
	if _tcp.get_status() == StreamPeerTCP.STATUS_CONNECTED:
		var data = message.to_utf8_buffer()
		var err = _tcp.put_data(data)
		if err != OK:
			connection_error.emit("Failed to send message: " + str(err))


func get_connection_status() -> bool:
	return _tcp.get_status() == StreamPeerTCP.STATUS_CONNECTED

func _process(_delta):
	# 处理网络事件
	_tcp.poll()

	if _tcp.get_status() == StreamPeerTCP.STATUS_CONNECTED:
		# 检查是否有可用数据
		var available = _tcp.get_available_bytes()
		if available > 0:
			var message = _tcp.get_utf8_string(available)
			message_received.emit(message)
