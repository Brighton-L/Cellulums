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
	var middle=game.capillary_point(.5)
	var upper=middle+Vector2(0,-85)
	var lower=middle+Vector2(0,85)
	if not check(not game.capillary_blocked(upper,10) and not game.capillary_blocked(lower,10),"Test positions must be clear of the capillary"):return
	var above=game.add_mol("glucose",upper,false)
	drag(above,lower)
	if not check(above.p.y<middle.y and not game.capillary_blocked(above.p,10),"Dragging down must stop at the capillary"):return
	var below=game.add_mol("aa",lower,false)
	drag(below,upper)
	if not check(below.p.y>middle.y and not game.capillary_blocked(below.p,12),"Dragging up must stop at the capillary"):return
	var drifting=game.add_mol("glucose",upper+Vector2(22,0),false,{"v":Vector2(0,400)})
	game.process_molecules(.5)
	if not check(drifting.p.y<middle.y and not game.capillary_blocked(drifting.p,10),"Drift must bounce off the capillary without tunneling"):return
	print("Capillary wall: drag from both sides and drift collision passed")
	quit()
