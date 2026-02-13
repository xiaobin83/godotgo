extends Node

enum RequestStatus
{
	STATUS_PENDING,
	STATUS_SENT,
	STATUS_RECEIVED,
	STATUS_ERROR
}

class Request:

	var _request: String
	var _status: RequestStatus

	signal response_received(response)

	func _init(request: String):
		_request = request + '\n'
		_status = RequestStatus.STATUS_PENDING

	func _put_data(tcp: StreamPeerTCP) -> int:
		var data = _request.to_utf8_buffer()
		return tcp.put_data(data)

	func process(tcp: StreamPeerTCP) -> RequestStatus:
		if _status == RequestStatus.STATUS_PENDING:
			var err = _put_data(tcp)
			if err == OK:
				_status = RequestStatus.STATUS_SENT
			else:
				_status = RequestStatus.STATUS_ERROR
				response_received.emit(null)
		
		if _status == RequestStatus.STATUS_SENT:
			if tcp.get_status() == StreamPeerTCP.STATUS_CONNECTED:
				# 检查是否有可用数据
				var available = tcp.get_available_bytes()
				if available > 0:
					var message = tcp.get_utf8_string(available)
					_status = RequestStatus.STATUS_RECEIVED
					response_received.emit(message)

		return _status 


# 信号定义
signal connected
signal disconnected
signal connection_error(error_message)

# TCP连接对象
var _tcp = StreamPeerTCP.new()

var _requests = [] 

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

	_requests.clear()

func send_message_async(message: String):
	var r = Request.new(message) 
	_requests.push_back(r)
	return await r.response_received

func _process(_delta):
	# 处理网络事件
	_tcp.poll()

	if _tcp.get_status() == StreamPeerTCP.STATUS_CONNECTED:
		while _requests.size() > 0:
			var request = _requests.front()
			var status = request.process(_tcp)
			if status == RequestStatus.STATUS_RECEIVED or status == RequestStatus.STATUS_ERROR:
				_requests.pop_front()

