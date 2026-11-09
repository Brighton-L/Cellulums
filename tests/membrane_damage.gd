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
	game.start_level(7)
	game.mols.clear()
	game.cracks.clear()
	game.crack_data.clear()
	game.ports.clear()
	game.add_port("glut",0.0)
	var port: Dictionary=game.ports[0]
	var point: Vector2=game.port_pos(0.0)
	var outward: Vector2=game.port_surface_normal(port)
	game.cracks.append(0.0)
	var damage: Dictionary=game.crack_state(0.0)
	if not check(game.port_damaged(port),"A tear should disable a nearby GLUT port"):return
	game.add_port("aa",PI)
	if not check(not game.port_damaged(game.ports[-1]),"A distant port should keep working despite local damage"):return
	var incoming=game.add_mol("glucose",game.port_dock_point(port,"glucose"),false)
	if not check(not game.bind_molecule_to_port(incoming,port),"Damaged GLUT should not capture glucose"):return
	incoming.dead=true
	var glucose=game.add_mol("glucose",point-outward*28.0,true)
	if not check(game.leak_through_crack(0.0) and not glucose.inside and not glucose.dead,"A tear should leak stored glucose out without destroying it"):return
	glucose.dead=true
	var amino=game.add_mol("aa",point+outward*32.0,false)
	if not check(game.leak_through_crack(0.0) and amino.inside,"A tear should also allow small molecules to leak inward"):return
	game.mols.clear()
	var first_lipid=game.add_mol("lipid",game.cam_center,true)
	game.drop_mol(first_lipid,point)
	if not check(first_lipid.dead and game.cracks.is_empty() and not game.port_damaged(port) and int(game.state.patched)==1,"Lipid should seal an ordinary tear and restore its port"):return
	var healthy_glucose=game.add_mol("glucose",game.port_dock_point(port,"glucose"),false)
	if not check(game.bind_molecule_to_port(healthy_glucose,port),"Repaired GLUT should capture again"):return
	game.mols.clear()
	port.bound_mol={}
	game.cracks.append(0.0)
	damage=game.crack_state(0.0)
	game.process_membrane_damage(55.1)
	if not check(int(damage.severity)==2 and game.port_damaged(port),"An ignored tear should grow into a larger rupture"):return
	var sodium=game.add_mol("na",point+outward*31.0,false)
	if not check(game.leak_through_crack(0.0) and sodium.inside and game.osmotic_drive()>0.0,"A rupture should admit sodium and disturb osmotic balance"):return
	var swell_before=float(game.state.swell)
	game.process_membrane_damage(1.0)
	if not check(float(game.state.swell)>swell_before,"Ion imbalance through a rupture should increase swelling"):return
	game.mols.clear()
	var second_lipid=game.add_mol("lipid",game.cam_center,true)
	game.drop_mol(second_lipid,point)
	if not check(second_lipid.dead and game.cracks.has(0.0) and damage.material and int(game.state.patched)==1,"A large rupture must remain open after lipid alone"):return
	var spare_lipid=game.add_mol("lipid",game.cam_center,true)
	game.drop_mol(spare_lipid,point)
	if not check(not spare_lipid.dead,"A rupture that already has lipid should not consume another one"):return
	var protein=game.add_mol("protein",game.cam_center,true,{"gene":"c_repair","stage":"nascent"})
	game.drop_mol(protein,point)
	if not check(protein.dead and game.cracks.is_empty() and int(game.state.patched)==2 and not game.port_damaged(port),"Repair protein plus lipid should seal a large rupture"):return
	game.cracks.append(0.0)
	damage=game.crack_state(0.0)
	var stabilizer=game.add_mol("protein",game.cam_center,true,{"gene":"c_repair","stage":"nascent"})
	game.drop_mol(stabilizer,point)
	game.process_membrane_damage(56.0)
	if not check(damage.protein and int(damage.severity)==1,"Repair protein should slow the growth of a tear"):return
	game.mols.clear()
	game.cracks.clear()
	game.crack_data.clear()
	game.add_port("nak",1.0)
	var pump: Dictionary=game.ports[-1]
	game.cracks.append(1.0)
	var sodium_ions=[]
	var potassium_ions=[]
	for i in 3:sodium_ions.append(game.add_mol("na",pump.p-Vector2.ONE*20.0,true))
	for i in 2:potassium_ions.append(game.add_mol("k",pump.p+Vector2.ONE*20.0,false))
	var atp_before=float(game.state.atp)
	game.process_na_k_pumps(.1)
	if not check(is_equal_approx(float(game.state.atp),atp_before) and sodium_ions[0].inside,"A pump next to a crack should pause instead of spending ATP"):return
	var final_lipid=game.add_mol("lipid",game.cam_center,true)
	game.drop_mol(final_lipid,game.port_pos(1.0))
	game.process_na_k_pumps(.1)
	if not check(is_equal_approx(float(game.state.atp),atp_before-1.0) and not sodium_ions[0].inside and potassium_ions[0].inside,"Repairing the membrane should restore a nearby pump"):return
	print("Membrane damage: local port failure, two-way leakage, rupture growth, swelling, and layered repair passed")
	quit()
