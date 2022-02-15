#!/usr/bin/env python3

import socket
import struct
import sys

sock = None
serverProperties = {}

def readPacket():
	try:
		lengthBytes = sock.recv(4)
		assert len(lengthBytes) == 4, f"expected 4 bytes (packet length) but recv returned {len(lengthBytes)} ({lengthBytes})"
		length = struct.unpack("<i", lengthBytes)[0]
		assert length >= 9 and length < 6000, f"Bad packet length {length}"
		
		packet = sock.recv(length)
		assert len(packet) == length, f"expected {length} bytes but recv returned {len(packet)} ({packet})"
		
		respID, type, payload = struct.unpack(f"<ii{length - 9}sx", packet)
		return (respID, type, payload[:-1])
	except socket.timeout:
		raise
	except Exception as err:
		print(f"Failed to read packet: {err}", file=sys.stderr)
		raise SystemExit(2)

def writePacket(reqID, type, payload):
	payloadLen = len(payload)
	try:
		sock.sendall(
			struct.pack(
				f"<iii{payloadLen}sxx",
				payloadLen + 10,
				reqID,
				type,
				payload
			)
		)
	except socket.timeout:
		raise
	except Exception as err:
		print(f"Failed to write packet: {err}", file=sys.stderr)
		raise SystemExit(2)

def reqCounter():
	counter = 0
	while True:
		yield counter % 0x7FFF_FFFF
		counter += 1
reqCounter = reqCounter()

def login(password):
	reqID = next(reqCounter)
	writePacket(reqID, 3, password.encode("ascii"))
	respID, type, payload = readPacket()
	
	if respID != reqID or type != 2 or payload != b"":
		if type == 2 and respID == -1:
			print("Login failed (bad password)", file=sys.stderr)
			raise SystemExit(1)
		else:
			raise ValueError(f"Bad login response packet, expected ({reqID}, 2, '') but got ({respID}, {type}, {payload})")

def sendCommand(cmd):
	from io import BytesIO

	assert len(cmd) < 1450, "Commands must be limited to 1450 characters"
	payload = cmd.encode("ascii")
	
	mainReq = next(reqCounter)
	sentinelReq = next(reqCounter)
	writePacket(mainReq, 2, payload)
	
	first = True
	buf = BytesIO()
	while True:
		if first:
			# delay sentinel as MC impl cannot handle two requests at once, causes disconnect
			first = False
		else:
			# send a bogus request that *should* always fit into one packet,
			# to detect when the main request has actually finished
			writePacket(sentinelReq, 2, b"")
		
		try:
			respID, type, payload = readPacket()
			if respID == sentinelReq: break
			elif type != 0 or respID != mainReq:
				raise ValueError(f"Bad command response packet: expected type 0 id {mainReq} but got type {type} id {respID} (payload {payload})")
			
			buf.write(payload)
		except socket.timeout:
			print("Timed out reading response", file=sys.stderr)
			break
	return buf.getvalue()

def readServerProperties():
	import os

	propFile = "server.properties"
	while not os.path.exists(propFile):
		next = os.path.join("..", propFile)
		if os.path.abspath(next) == os.path.abspath(propFile):
			print("Warning: could not locate server.properties", file=sys.stderr)
			serverProperties["_sentinel"] = False # prevent function from being ran again
			return
		propFile = next
	
	with open(propFile, "r") as f:
		for line in f:
			line = line.strip()
			if line.startswith("#"): continue
			serverProperties.update([line.split("=", 1)])

def guessOption(argVal, serverProp, type, fallback):
	if argVal != None: return argVal
	if not any(serverProperties): readServerProperties() # lazy load
	
	value = None
	prop = serverProperties.get(serverProp, "")
	if prop != "":
		value = type(prop) if type != str else prop
	else:
		value = fallback()
	
	return value

def main():
	import argparse
	
	parser = argparse.ArgumentParser(description="Minecraft RCON client")
	parser.add_argument("--host", "-H", help="Server hostname/IP address")
	parser.add_argument("--port", "-P", help="Server port")
	parser.add_argument("--password", "-p", help="RCON password")
	parser.add_argument("--no-interactive", "-n", help="Exit with error if no commands are given as arguments.", action="store_true")
	parser.add_argument("commands", nargs="*", help="Command(s) to run, one per argument. ")
	args = parser.parse_args()
	
	haveCmdlist = len(args.commands) > 0
	if not haveCmdlist and args.no_interactive:
		print("Error: no commands specified in argv", file=sys.stderr)
		raise SystemExit(1)
	
	hostname = guessOption(args.host, "server-ip", str, lambda: socket.gethostbyname("localhost"))
	port = guessOption(args.port, "rcon.port", int, lambda: 25575)
	def pwfallback():
		print("RCON password is not set in server.properties, therefore it is disabled!", file=sys.stderr)
		raise SystemExit(1)
	password = guessOption(args.password, "rcon.password", str, pwfallback)
	
	global sock
	sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	try: sock.connect((hostname, port))
	except:
		print(f"Failed to connect to server at {hostname}:{port}", file=sys.stderr)
		raise SystemExit(255)
	sock.settimeout(1.0)
	
	login(password)
	
	if haveCmdlist:
		for cmdline in args.commands:
			print(sendCommand(cmdline).decode("ascii"))
	else:
		print("Login successful", file=sys.stderr)
		while True:
			try:
				cmdline = input("> ")
				print(sendCommand(cmdline).decode("ascii"))
			except (KeyboardInterrupt, EOFError):
				print() # newline after prompt
				break
			except Exception as err:
				print(err, file=sys.stderr)
	
	sock.close()

if __name__ == "__main__":
	main()
