extends VehicleBody3D

@onready var flw
@onready var frw
@onready var brw
@onready var blw
@onready var steeringAngleText 
@onready var currentView
@onready var numCollisionsNode
@onready var numRequestsText

var http_request_in_progress = false
var steeringAngleValue = 0
var numCollisions = 0
var numRequests = 0
var thread 
var img
var thread0 = true
var DIR = OS.get_executable_path().get_base_dir()
var interpreter_path = DIR.path_join("PythonFiles/venv/bin/python3.11")
var script_path = DIR.path_join("PythonFiles/notif.py")


func _ready():
	if !OS.has_feature("standalone"): # if NOT exported version
		interpreter_path = ProjectSettings.globalize_path("res://PythonFiles/venv/bin/python3.11")
		script_path = ProjectSettings.globalize_path("res://PythonFiles/notif.py")
	
	thread = Thread.new()
	#thread.start(processViewPoint)
	
	
	#initialize all the nodes
	steeringAngleText = get_node("Texts/Steering_Angle")
	numCollisionsNode = get_node("Texts/NumCollisions")
	numRequestsText = get_node("Texts/NumRequests")
	flw = get_node("frontleftwheel")
	frw = get_node("frontrightwheel")
	brw = get_node("backrightwheel")
	blw = get_node("backleftwheel")
	currentView = get_node("overheadview")
	
	
	
	#put all the right settings for the tires
	flw.set_use_as_traction(true)
	flw.set_use_as_steering(true)
	
	frw.set_use_as_traction(true)
	frw.set_use_as_steering(true)
	
	brw.set_use_as_traction(true)
	
	blw.set_use_as_traction(true)
	
	#set up the camera node
	
	
	
	
func _physics_process(delta):
	steeringAngleText.text = "Steering Angle = " + str(steering).substr(0,7)
	steering = Input.get_axis("right","left")*0.4
	engine_force = Input.get_axis("back","forward")*200
	
	if !thread.is_alive():
		if !thread0:
			thread.wait_to_finish()
		print("starting thread")
		img = get_tree().get_root().get_tree().get_root().get_texture().get_image()
		thread.start(processViewPoint)
		thread0 = false
		
		#numRequests = numRequests + 1
		#numRequestsText.text = "Number of Collisions = " + str(numRequests)
	
	#if not http_request_in_progress:
		#start_http_request()
		#numRequests = numRequests + 1
		#numRequestsText.text = "Number of Collisions = " + str(numRequests)
	

func processViewPoint():
	print("processing view")
	var angle=[]
	img.save_png("currentView.png")
	var err = OS.execute(interpreter_path, [script_path, "yuh"], angle)
	print(err)
	print(angle)
	


func start_http_request():
	http_request_in_progress = true
	var headers = ["Content-Type: application/json"]
	
	img = get_tree().get_root().get_tree().get_root().get_texture().get_image()
	#img.save_png("currentView.png")
	var imgData = img.get_data()
	
	#var imgDataBase64 = Marshalls.raw_to_base64(imgData)
	#print(imgDataBase64.length())
	
	
	# 20 times in ten seconds 
	#var url = "https://anandgogoi.pythonanywhere.com"
	
	# 200 times in ten seconds
	var url = "http://127.0.0.1:5000/upload"
	
	var data = {
		"pictureBase64" : imgData
	}
	var dataJSON = JSON.stringify(data)
	
	#var error = $HTTPRequest.request(url)
	var error = $HTTPRequest.request(url,headers,HTTPClient.METHOD_POST,dataJSON)
	
	
	

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var test_json_conv = JSON.new()
	test_json_conv.parse(body.get_string_from_utf8())
	var json = test_json_conv.get_data()
	print(json)
	http_request_in_progress = false
	
	
	
func _on_body_entered(body):
	numCollisions = numCollisions + 1
	numCollisionsNode.text = "Number of Collisions = " + str(numCollisions)
	#if !thread.is_alive():
	#	if !thread0:
			
	#		thread.wait_to_finish()
	#	print("starting thread")
	#	img = get_tree().get_root().get_tree().get_root().get_texture().get_image()
	#	thread.start(processViewPoint)
	#	thread0 = false



