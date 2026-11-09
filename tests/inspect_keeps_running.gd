extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool,message: String) -> bool:
	if ok:return true
	push_error(message)
	quit(1)
	return false

func run() -> void:
	var game=load("res://main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.start_level(1)
	game.show_inspect(game.org("mitochondrion"))
	if not check(game.inspect_panel.visible and not game.paused,"Opening organelle info must leave the game running"):return
	var before=float(game.elapsed)
	game._process(.05)
	if not check(game.elapsed>before,"Simulation time must advance while info is open"):return
	game.close_inspect()
	if not check(not game.paused,"Closing info must leave the game running"):return
	game.toggle_pause()
	game.show_inspect(game.org("mitochondrion"))
	game.close_inspect()
	if not check(game.paused,"Closing info must not override a manual pause"):return
	game.toggle_pause()
	var port=game.ports[0]
	var sugar=game.add_mol("glucose",port.p,false)
	var press=InputEventMouseButton.new()
	press.button_index=MOUSE_BUTTON_LEFT;press.pressed=true;press.position=sugar.p
	game._unhandled_input(press)
	var release=InputEventMouseButton.new()
	release.button_index=MOUSE_BUTTON_LEFT;release.pressed=false;release.position=sugar.p
	game._unhandled_input(release)
	if not check(not sugar.inside,"The first click of a double-click must not deliver the resource"):return
	press.double_click=true
	game._unhandled_input(press)
	game._unhandled_input(release)
	if not check(game.inspect_panel.visible and game.inspect_heading.text=="Glucose" and game.inspect_description.text.contains("GLUT") and not game.paused,"Double-clicking glucose must open its own live info panel"):return
	game.close_inspect()
	var oxygen=game.add_mol("o2",game.cam_center+Vector2(-100,30),true)
	press.position=oxygen.p
	game._unhandled_input(press)
	if not check(game.inspect_heading.text=="O₂" and game.inspect_description.text.contains("Mitochondria"),"Gas molecules must show their own information"):return
	game.close_inspect()
	var arriving=game.spawn_capillary_resource("aa")
	for i in 100:
		game.advance_capillary(arriving,.05)
		if arriving.cap_state=="incoming_eject":break
	press.position=arriving.p
	game._unhandled_input(press)
	if not check(game.inspect_heading.text=="Amino Acid","Visible capillary arrivals should also be inspectable"):return
	print("Inspection panel stays live; double-click opens resource information without delivering it")
	quit()
