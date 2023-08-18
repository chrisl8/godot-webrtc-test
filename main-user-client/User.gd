# Edit this file to switch between ENetMultiplayerPeer and WebRTCMultiplayerPeer to prove that
# ENet works but WebRTC does not.

extends Node

var instance_num                            := -1
var client: Client
var user_name: String                       =  ""
var host_name: String                       =  ""
var current_lobby_name: String              =  ""
var current_lobby_list: String              =  ""
var is_host: bool                           =  false
var ID                                      := -1
var peers: Dictionary
var peer_count                              := -1
var network_initialized: bool               =  false
var game_started: bool                      =  false
var game_scene_initialize_in_progress: bool =  false
var game_scene_initialized: bool            =  false
var level_scene                             := preload("res://scene.tscn")
var is_server: bool                         =  false
var server_name: String                     =  ""
var server_id                               := -1
var server_password: String                 =  ""
var local_debug_instance_number             := -1
var mult: SceneMultiplayer                  =  null
var connection_list: Dictionary             =  {}

var rtc_peer: WebRTCMultiplayerPeer # Comment to disable WebRTC
#var rtc_peer: ENetMultiplayerPeer # Comment to disale ENet

signal reset
signal delete_main_menu


func _process(_delta) -> void:
	if not network_initialized or not game_started:
		return
	delete_main_menu.emit()

	# Having ONLY the server do this in order to allow MultiplayerSpawner
	# to cause other instances to load the scene.
	if not User.is_server:
		return

	# Initialize the Level if it isn't yet
	if not game_scene_initialized:
		if not game_scene_initialize_in_progress:
			game_scene_initialize_in_progress = true
			load_level.call_deferred(level_scene)
		elif get_node_or_null("../Main/Level/game_scene"):
			game_scene_initialized = true
		return


func load_level(scene: PackedScene):
	print(User.ID, " Loading Scene")
	var level_parent := get_tree().get_root().get_node("Main/Level")
	for c in level_parent.get_children():
		level_parent.remove_child(c)
		c.queue_free()
	level_parent.set_multiplayer_authority(server_id, true)
	var game_scene = scene.instantiate()
	game_scene.name = "game_scene"
	level_parent.add_child(game_scene)


func client_listener_init():
	client.offer_received.connect(_offer_received)
	client.answer_received.connect(_answer_received)
	client.ice_received.connect(_ice_received)
	client.reset_connection.connect(reset_connection)
	client.game_start_received.connect(_game_start_received)


func init_connection():
	rtc_peer = WebRTCMultiplayerPeer.new() # Comment to disable WebRTC
	#rtc_peer = ENetMultiplayerPeer.new() # Comment to disale ENet
	if User.is_server:
		rtc_peer.create_mesh(ID) # Comment to disable WebRTC
		#rtc_peer.create_server(8080)
	else:
		rtc_peer.create_mesh(ID) # Comment to disable WebRTC
		#rtc_peer.create_client('127.0.0.1', 8080)

	connection_list.clear()

	for peer_id in peers.keys():
		var connection := WebRTCPeerConnection.new()
		connection.initialize({"iceServers": [ { "urls": ["stun:stun.l.google.com:19302"]}]})
		connection.session_description_created.connect(session_created.bind(connection))
		connection.ice_candidate_created.connect(ice_created.bind(connection))
		connection_list[peer_id] = connection
		rtc_peer.add_peer(connection, peer_id) # Comment to disable ENet

	get_tree().get_multiplayer().multiplayer_peer = rtc_peer

	network_initialized = true


func session_created(type: String, sdp: String, connection):
	connection.set_local_description(type, sdp)
	if type == "offer":
		client.send_offer(type, sdp, connection_list.find_key(connection))
	else:
		client.send_answer(type, sdp, connection_list.find_key(connection))


func ice_created(media: String, index: int, _name: String, connection):
	client.send_ice(media, index, _name, connection_list.find_key(connection))


func _ice_received(media: String, index: int, _name: String, sender_id):
	connection_list.get(sender_id).add_ice_candidate(media, index, _name)


func _offer_received(type: String, sdp: String, sender_id):
	connection_list.get(sender_id).set_remote_description(type, sdp)


func _answer_received(type: String, sdp: String, sender_id):
	connection_list.get(sender_id).set_remote_description(type, sdp)


func _game_start_received(peer_ids: String):
	var arr = peer_ids.split("***", false)
	for id_string in arr:
		User.connection_list.get(id_string.to_int()).create_offer()


func reset_connection():
	for connection in connection_list.values():
		connection.close()

	client.queue_free()
	user_name = ""
	is_host = false
	current_lobby_list = ""
	current_lobby_name = ""
	host_name = ""
	ID = -1
	peers.clear()
	var game_scene_node := get_node_or_null("../Main/game_scene")
	if game_scene_node and is_instance_valid(game_scene_node):
		game_scene_node.queue_free()
	reset.emit()

