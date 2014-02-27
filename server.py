from __future__ import print_function
__author__ = "Frederik Lauber"
__copyright__ = "Copyright 2014"
__license__ = "GPLv3"
__version__ = "0.1"
__maintainer__ = "Frederik Lauber"
__status__ = "Development"
__contact__ = "https://flambda.de/impressum.html"

import serial
import SocketServer
import threading
import time
import urllib
from string import Template
SERIAL_DEVICE = "/dev/ttyGPIO"
CABLE_PORTS = ["B4", "B6"]
SERIAL_TIMEOUT = 10
COMMAND_TEMPLATE = Template("${pin}${action}\r\n")
#For States:
# 0 -> off
# 1 -> on
# ? -> get state (pull down is installed)

HOST = "10.23.42.210"

PORT_CURRENT_STATE = 7877
MAXIMAL_TIME_BETWEEN_STATES = 2
PORT_CHANGE_STATE = 7876
MAX_THREADS = 50

class CableRapper(threading.Thread):
	def __init__(self, serial_device, cable_end_1, cable_end_2, timeout = 10):
		self.serial_name = serial_device
		self._con = None
		self.cable_connections = [cable_end_1, cable_end_2]
		self.timeout = timeout
		self.event = threading.Event()
		self.open = None

	@property
	def con(self):
		if self._con is None:
			self._con = serial.Serial(self.serial_name, 9600, timeout=self.timeout)
		return self._con

	def state_updater(self):
		while True:
			while True:
				try:
					self.con.write(COMMAND_TEMPLATE.substitute(pin = self.cable_connections[0], action="=1"))
					self.con.write(COMMAND_TEMPLATE.substitute(pin = self.cable_connections[1], action="=0"))
					self.con.write(COMMAND_TEMPLATE.substitute(pin = self.cable_connections[1], action="?"))
					new_open = int(self.con.readline().strip()[-1])
				except serial.SerialException:
					self._con = None
				else:
					break
			if not self.open == new_open:
				self.open = new_open
				self.event.set()
				self.event.clear()
			else:
				time.sleep(0.2)

def meta_creator_set_wait_timeout(cable, timeout=None):
	#creates a server class which wait on Cable.event 
	#with an timeout, if timeout is None, it will wait
	#until event is set
	class ServerHandler(SocketServer.BaseRequestHandler):
		def handle(self):
			if threading.active_count() > MAX_THREADS:
				#emergency to limit threads
				#if we have python 3.2, use 
				#concurent.futures to create a limit worker 
				#pool
				return
			while True:
				self.request.sendall(str(cable.open))
				cable.event.wait(timeout)
	return ServerHandler


class ThreadedTCPServer(SocketServer.ThreadingMixIn, SocketServer.TCPServer):
	pass


def space_api_client(cable):
	def meta():
		url_mapper = ["http://spaceapi.hasi.it/set_open/false", "http://spaceapi.hasi.it/set_open/true"]
		previous_state = None
		while True:
			state = cable.open
			if not state == previous_state or cable.event.wait():
				try:
					urllib.urlopen(url_mapper[state])
					previous_state = state
				except Exception:
					pass
	return meta

if __name__ == "__main__":
		cable = _CABLE = CableRapper(SERIAL_DEVICE, CABLE_PORTS[0], CABLE_PORTS[1])
		#Set Up Cable Updater
		cable_thread = threading.Thread(target=cable.state_updater)
		cable_thread.daemon = True
		cable_thread.start()
		#Set up Servers
		ChangeServer = ThreadedTCPServer((HOST, PORT_CHANGE_STATE), meta_creator_set_wait_timeout(cable))
		StateServer = ThreadedTCPServer((HOST, PORT_CURRENT_STATE), meta_creator_set_wait_timeout(cable, MAXIMAL_TIME_BETWEEN_STATES))
		change_thread = threading.Thread(target=ChangeServer.serve_forever)
		state_thread = threading.Thread(target=StateServer.serve_forever)
		change_thread.start()
		state_thread.start()
		#Set Up Space Api client
		space_api_thread = threading.Thread(target=space_api_client(cable))
		space_api_thread.daemon = True	
		space_api_thread.start()


