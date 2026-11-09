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
	game.blood_carriers.clear();game.mols.clear();game.ports.clear()
	game.add_port("glut",0.0)
	var port: Dictionary=game.ports[0]
	var normal=game.port_surface_normal(port)
	var atp=float(game.state.atp)
	var close=game.add_mol("glucose",game.port_dock_point(port,"glucose")+normal*28.0,false,{"v":Vector2.ZERO})
	var distant=game.add_mol("glucose",game.port_dock_point(port,"glucose")+normal*130.0,false,{"v":Vector2.ZERO})
	for i in 90:
		game.process_molecules(.05)
		if close.inside:break
	if not check(close.inside and not distant.inside,"Only glucose near a GLUT port should be captured automatically"):return
	if not check(absf(float(game.state.atp)-atp)<.01,"Basic GLUT transport must not spend ATP directly"):return
	if not check(float(port.transport_cd)>0.0,"GLUT should enter cooldown after transport"):return
	game.mols.clear()
	var waiting=game.add_mol("glucose",game.port_dock_point(port,"glucose"),false,{"v":Vector2.ZERO})
	for i in 15:game.process_molecules(.05)
	if not check(not waiting.inside,"A GLUT port on cooldown should not import another molecule immediately"):return
	for i in 65:game.process_molecules(.05)
	if not check(waiting.inside,"A waiting glucose molecule should enter when GLUT recovers"):return
	var base_range=game.port_capture_radius(port)
	var base_pull=game.port_pull_strength(port)
	var base_cooldown=game.port_transport_cooldown(port)
	game.apply_pack_effect("glut_range")
	game.apply_pack_effect("glut_pull")
	game.apply_pack_effect("glut")
	if not check(game.port_capture_radius(port)>base_range and game.port_pull_strength(port)>base_pull and game.port_transport_cooldown(port)<base_cooldown,"GLUT range, pull, and throughput upgrades should affect separate stats"):return
	for i in 10:game.apply_pack_effect("glut_range")
	if not check(game.port_capture_radius(port)<=base_range*1.8+.01,"Range upgrades must keep capture local"):return
	game.ports.clear();game.mols.clear()
	game.add_port("aa",PI)
	var aa_port: Dictionary=game.ports[0]
	var amino=game.add_mol("aa",game.port_dock_point(aa_port,"aa")+game.port_surface_normal(aa_port)*25.0,false,{"v":Vector2.ZERO})
	for i in 90:game.process_molecules(.05)
	if not check(amino.inside,"AA transporters should capture nearby amino acids through the same docking sequence"):return
	print("Port capture: local attraction, docking, cooldown, upgrades, and ATP-free GLUT passed")
	quit()
