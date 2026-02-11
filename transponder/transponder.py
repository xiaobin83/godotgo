#!/usr/bin/env python3
"""
中转器：连接到12345端口，同时监听8080端口接受多个客户端输入，
将客户端命令转发到12345，并将响应回传给对应客户端。
"""

import socket
import threading
import queue
import time
import argparse

class Transponder:
    def __init__(self, target_host='localhost', target_port=12345, listen_port=8080):
        self.target_host = target_host
        self.target_port = target_port
        self.listen_port = listen_port
        self.server_socket = None
        self.target_socket = None
        self.client_sockets = []
        self.client_queues = {}  # 客户端队列：client_socket -> 命令队列
        self.response_queue = queue.Queue()
        self.running = False
        self.lock = threading.Lock()
        self.last_client = None  # 记录最后发送命令的客户端

    def connect_to_target(self):
        """连接到目标服务器(12345端口)"""
        while self.running:
            try:
                print(f"尝试连接到 {self.target_host}:{self.target_port}...")
                self.target_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                self.target_socket.connect((self.target_host, self.target_port))
                print(f"成功连接到 {self.target_host}:{self.target_port}")
                
                # 启动目标服务器响应处理线程
                threading.Thread(target=self.handle_target_response, daemon=True).start()
                return True
            except Exception as e:
                print(f"连接目标服务器失败: {e}")
                time.sleep(2)  # 重试间隔
        return False

    def handle_target_response(self):
        """处理目标服务器(12345)的响应，分发给客户端"""
        while self.running and self.target_socket:
            try:
                response = self.target_socket.recv(4096)
                if not response:
                    print("目标服务器连接断开")
                    self.target_socket = None
                    # 重新连接
                    self.connect_to_target()
                    continue
                
                # 打印响应内容到标准输出
                print(f"{response.decode().strip()}")
                
                # 将响应只返回给最后发送命令的客户端
                with self.lock:
                    if self.last_client and self.last_client in self.client_sockets:
                        try:
                            self.last_client.send(response)
                        except Exception as e:
                            print(f"发送响应到客户端失败: {e}")
                            self.remove_client(self.last_client)
            except Exception as e:
                print(f"处理目标服务器响应失败: {e}")
                self.target_socket = None
                self.connect_to_target()

    def handle_client(self, client_socket, client_addr):
        """处理客户端连接，接收命令并转发到目标服务器"""
        print(f"客户端 {client_addr} 连接")
        
        with self.lock:
            self.client_sockets.append(client_socket)
            self.client_queues[client_socket] = queue.Queue()
        
        try:
            while self.running:
                # 接收客户端命令
                data = client_socket.recv(4096)
                if not data:
                    print(f"客户端 {client_addr} 断开连接")
                    break
                
                # 转发命令到目标服务器
                if self.target_socket:
                    try:
                        self.last_client = client_socket  # 记录发送命令的客户端
                        self.target_socket.send(data)
                        print(f"转发命令到目标服务器: {data.decode().strip()}")
                    except Exception as e:
                        print(f"转发命令失败: {e}")
                        # 尝试重新连接
                        if not self.target_socket:
                            self.connect_to_target()
                else:
                    # 目标服务器未连接，提示客户端
                    client_socket.send(b"Error: Target server not connected\n")
        except Exception as e:
            print(f"处理客户端失败: {e}")
        finally:
            self.remove_client(client_socket)

    def remove_client(self, client_socket):
        """移除客户端连接"""
        with self.lock:
            if client_socket in self.client_sockets:
                self.client_sockets.remove(client_socket)
                del self.client_queues[client_socket]
            try:
                client_socket.close()
            except:
                pass

    def start(self):
        """启动中转器"""
        self.running = True
        
        # 连接到目标服务器
        if not self.connect_to_target():
            print("无法连接到目标服务器，退出")
            self.running = False
            return
        
        # 启动监听服务器
        try:
            self.server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            self.server_socket.bind(('0.0.0.0', self.listen_port))
            self.server_socket.listen(5)
            print(f"中转器启动成功，监听端口 {self.listen_port}")
            
            # 接受客户端连接
            while self.running:
                client_socket, client_addr = self.server_socket.accept()
                threading.Thread(target=self.handle_client, args=(client_socket, client_addr), daemon=True).start()
        except Exception as e:
            print(f"启动监听服务器失败: {e}")
            self.running = False

    def stop(self):
        """停止中转器"""
        self.running = False
        
        # 关闭所有客户端连接
        with self.lock:
            for client_socket in self.client_sockets:
                try:
                    client_socket.close()
                except:
                    pass
            self.client_sockets.clear()
            self.client_queues.clear()
        
        # 关闭目标服务器连接
        if self.target_socket:
            try:
                self.target_socket.close()
            except:
                pass
        
        # 关闭监听服务器
        if self.server_socket:
            try:
                self.server_socket.close()
            except:
                pass
        
        print("中转器已停止")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='中转器：转发内容到特定端口')
    parser.add_argument('--target-host', default='localhost', help='目标服务器主机地址')
    parser.add_argument('--target-port', type=int, default=12345, help='目标服务器端口')
    parser.add_argument('--listen-port', type=int, default=8080, help='监听端口')
    args = parser.parse_args()
    
    transponder = Transponder(target_host=args.target_host, target_port=args.target_port, listen_port=args.listen_port)
    try:
        transponder.start()
    except KeyboardInterrupt:
        print("收到中断信号，停止中转器...")
    finally:
        transponder.stop()
