extends SceneTree

var game: Node

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool,message: String) -> bool:
	if ok:return true
	push_error(message)
	quit(1)
	return false

func drag(m: Dictionary,target: Vector2) -> void:
	var press=InputEventMouseButton.new()
	press.button_index=MOUSE_BUTTON_LEFT;press.pressed=true;press.position=m.p
	game._unhandled_input(press)
	var motion=InputEventMouseMotion.new()
	motion.position=target
	game._unhandled_input(motion)
	var release=InputEventMouseButton.new()
	release.button_index=MOUSE_BUTTON_LEFT;release.pressed=false;release.position=target
	game._unhandled_input(release)

func run() -> void:
	game=load("res://main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.start_level(1)
	var outside=game.add_mol("glucose",game.cam_center+Vector2(game.radius.x*1.35,0),false)
	drag(outside,game.cam_center)
	if not check(not outside.inside and game.edge_ratio(outside.p)>1.0,"Outside molecule must stop at the membrane"):return
	var inside=game.add_mol("protein",game.cam_center+Vector2(-game.radius.x*.45,0),true)
	drag(inside,game.cam_center+Vector2(-game.radius.x*1.5,0))
	if not check(inside.inside and game.edge_ratio(inside.p)<1.0,"Inside molecule must stop at the membrane"):return
	var opposite=game.add_mol("glucose",game.cam_center+Vector2(game.radius.x*1.4,35),false)
	drag(opposite,game.cam_center+Vector2(-game.radius.x*1.4,35))
	if not check(opposite.p.x>game.cam_center.x and game.edge_ratio(opposite.p)>1.0,"A quick drag must not jump across the cell"):return
	var glut: Dictionary={}
	for port in game.ports:
		if port.type=="glut":glut=port;break
	if not check(not glut.is_empty(),"GLUT port must exist"):return
	var normal=Vector2(glut.p-game.cam_center).normalized()
	var glucose=game.add_mol("glucose",glut.p+normal*55.0,false)
	drag(glucose,glut.p)
	if not check(glucose.get("capture_state","")=="docking" and not glucose.inside,"Dragging glucose to GLUT should begin docking outside the membrane"):return
	for i in 20:game.process_molecules(.05)
	if not check(glucose.inside,"GLUT should finish transporting docked glucose through the membrane"):return
	var gas_outside=game.add_mol("o2",game.cam_center+Vector2(-game.radius.x*1.3,55),false)
	var gas_inside=game.cam_center+Vector2(-game.radius.x*.55,55)
	if not check(game.free_motion_limit(gas_outside,gas_inside).distance_to(gas_inside)<.01,"O2 should pass through the cell wall while dragged"):return
	var co2=game.add_mol("co2",game.cam_center+Vector2(-game.radius.x*.55,-55),true)
	var co2_outside=game.cam_center+Vector2(-game.radius.x*1.3,-55)
	if not check(game.free_motion_limit(co2,co2_outside).distance_to(co2_outside)<.01,"CO2 should pass through the cell wall while dragged"):return
	print("Membrane drag: ordinary molecules stop, gases cross, and transporter import passed")
	quit()
