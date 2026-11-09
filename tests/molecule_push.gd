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
	var y=game.cam_center.y+80.0
	var held=game.add_mol("glucose",Vector2(game.cam_center.x-140.0,y),true)
	var pushed=game.add_mol("aa",Vector2(game.cam_center.x-75.0,y),true)
	var original_x=float(pushed.p.x)
	drag(held,Vector2(game.cam_center.x-10.0,y))
	if not check(float(pushed.p.x)>original_x+20.0,"Dragging one molecule must visibly push another"):return
	if not check(pushed.inside and game.edge_ratio(pushed.p)<1.0,"Pushed molecule must stay inside the membrane"):return
	var outside_x=game.cam_center.x+game.radius.x*1.35
	var outer_held=game.add_mol("glucose",Vector2(outside_x,y-100.0),false)
	var outer_pushed=game.add_mol("aa",Vector2(outside_x+65.0,y-100.0),false)
	var outer_original=float(outer_pushed.p.x)
	drag(outer_held,Vector2(outside_x+130.0,y-100.0))
	if not check(float(outer_pushed.p.x)>outer_original+20.0,"Outside molecules must also be easy to push"):return
	if not check(not outer_pushed.inside and game.edge_ratio(outer_pushed.p)>1.0,"Pushing must not carry a molecule through the membrane"):return
	print("Molecule pushing: inside, outside, and membrane limits passed")
	quit()
