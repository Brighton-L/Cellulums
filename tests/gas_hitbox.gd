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
	game.mols.clear()
	var base=game.cam_center+Vector2(-100,55)
	var oxygen=game.add_mol("o2",base,true)
	if not check(game.pick_mol(base+Vector2(11,0))==oxygen,"Visible horizontal O2 sprite should be clickable"):return
	if not check(game.pick_mol(base+Vector2(0,9)).is_empty(),"O2 must not be clickable well above its visible sprite"):return
	var carbon=game.add_mol("co2",base+Vector2(0,14),true)
	if not check(game.pick_mol(carbon.p+Vector2(18,0))==carbon,"Visible horizontal CO2 sprite should be clickable"):return
	if not check(game.pick_mol(carbon.p+Vector2(0,9)).is_empty(),"CO2 must not be clickable well below its visible sprite"):return
	var initial=Vector2(carbon.p)
	game.resolve_molecule_collisions()
	if not check(Vector2(carbon.p).distance_to(initial)<.01,"Vertically separated gases must not collide across transparent sprite space"):return
	carbon.p=base+Vector2(0,6)
	game.resolve_molecule_collisions()
	if not check(Vector2(carbon.p).distance_to(base)>6.0,"Gases that visually overlap should still separate"):return
	carbon.p=base+Vector2(0,16)
	initial=carbon.p
	game.push_molecules_while_dragging(oxygen,base+Vector2(70,0))
	if not check(Vector2(carbon.p).distance_to(initial)<.01,"Dragging O2 past a gas above it must not push through empty vertical space"):return
	print("Gas hitboxes: sprite-sized vertical picking and molecule contact passed")
	quit()
