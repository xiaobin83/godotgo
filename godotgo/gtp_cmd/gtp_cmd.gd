class_name GTPCmd

class CmdResponse:
	var id := ''
	var result := FAILED 
	var response 

var _failed_resp := CmdResponse.new()

# 连接管理器
var _connection_manager = null

# 构造函数
func _init():
	pass

# 设置连接管理器
func set_connection_manager(connection_manager):
	_connection_manager = connection_manager

# 正则表达式：匹配 '=id response\n\n'
var RE_ID_RESPONSE := RegEx.create_from_string(r'^=(?<id>\S+)\s+(?<response>.*)\n\n$')

# 正则表达式：匹配 '=id\n\n'
var RE_ID_ONLY := RegEx.create_from_string(r'^=(?<id>\S+)\n\n$')

# 正则表达式：匹配 '= response\n\n'
var RE_RESPONSE_ONLY := RegEx.create_from_string(r'^=\s+(?<response>.*)\n\n$')

# 正则表达式：匹配 '=\n\n'
var RE_EMPTY := RegEx.create_from_string(r'^=\n\n$')

func query_boardsize_async() -> CmdResponse:
	var response = await _connection_manager.send_message_async('query_boardsize')
	var m = RE_RESPONSE_ONLY.search(response)
	if m:
		var resp = CmdResponse.new()
		resp.response = int(m.get_string('response'))
		resp.result = OK 
		return resp
	m = RE_ID_RESPONSE.search(response)
	if m:
		var resp = CmdResponse.new()
		resp.response = int(m.get_string('response'))
		resp.result = OK 
		return resp
	return _failed_resp 

func showboard_async() -> CmdResponse:
	var response = await _connection_manager.send_message_async('showboard')
	var m = RE_RESPONSE_ONLY.search(response)
	if m:
		var resp = CmdResponse.new()
		resp.response = m.get_string('response')
		if resp.response.length() > 0:
			resp.result = OK 
		return resp
	m = RE_ID_RESPONSE.search(response)
	if m:
		var resp = CmdResponse.new()
		resp.id = m.get('id')
		resp.response = m.get_string('response')
		if resp.response.length() > 0:
			resp.result = OK 
		return resp

	return _failed_resp 
