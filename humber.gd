extends VehicleBody

# variáveis do veículo
var horse_power = 200
var accel_speed = 20

var steer_angle = deg2rad(30)
var steer_speed = 3

var brake_power = 40
var brake_speed = 40

# variáveis do canhão
onready var muzzle = get_node("turrent/gun/muzzle") # localização do cano
onready var rocket_scn = preload("res://rocket.tscn") # carrega o recurso do foguete

var can_fire = true
var fire_rate = 1.0

func _physics_process(delta):
	# Engine
	var throt_input = -Input.get_action_strength("W") + Input.get_action_strength("S")
	engine_force = lerp(engine_force, throt_input * horse_power, accel_speed * delta)

	# Steering
	var steer_input = -Input.get_action_strength("D") + Input.get_action_strength("A")
	steering = lerp(steering, steer_input * steer_angle, steer_speed * delta)

	# Brakes
	var brake_input = Input.get_action_strength("SPACE")
	#print("Brake Input: ", brake_input) 
	brake = lerp(brake, brake_input * brake_power, brake_speed * delta)

func _integrate_forces(_state):
	
	if Input.is_action_pressed("RMB"):
		print("movendo canhão")
		$turrent.rotation.y = lerp_angle($turrent.rotation.y, $camera.rotation.y, 0.02)
		$turrent/gun.rotation.x = lerp_angle($turrent/gun.rotation.x, $camera.rotation.x, 0.02)
		$turrent/gun.rotation.x = clamp($turrent/gun.rotation.x, deg2rad(-5), deg2rad(30))
		$camera.spring_length = lerp($camera.spring_length, 3, 0.1)
	else:
		$camera.spring_length = lerp($camera.spring_length, 5, 0.1)
		
	# Disparo	
	if Input.is_action_pressed("LMB") and can_fire:

		$camera.spring_length = lerp($camera.spring_length, 6, 0.1)
		var rocket = rocket_scn.instance() # instancia um foguete
		muzzle.add_child(rocket) # adiciona o foguete ao cano
		rocket.set_as_toplevel(true) # torna o foguete um nó de primeiro nível
		can_fire = false # impede que o jogador dispare novamente	

		print("Carregando...")
		yield(get_tree().create_timer(fire_rate), "timeout") # aguarda o tempo de recarga
		$camera.spring_length = lerp($camera.spring_length, 5, 0.1)

		can_fire = true # permite que o jogador dispare novamente
		print("Pronto para disparar!")
		
