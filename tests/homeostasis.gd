extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool,message: String) -> bool:
	if condition:return true
	push_error(message)
	quit(1)
	return false

func run() -> void:
	var game=load("res://main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.start_level(13)
	game.mols.clear()
	var pump: Dictionary={}
	for port in game.ports:
		if port.type=="nak":pump=port;break
	if not check(not pump.is_empty(),"Osmosis level needs a sodium-potassium pump"):return
	var na=[]
	var k=[]
	for i in 3:na.append(game.add_mol("na",pump.p+Vector2(-25,i*4),true))
	for i in 2:k.append(game.add_mol("k",pump.p+Vector2(25,i*4),false))
	var atp_before=float(game.state.atp)
	game.process_na_k_pumps(.1)
	if not check(na.all(func(m):return not m.inside) and k.all(func(m):return m.inside) and is_equal_approx(float(game.state.atp),atp_before-1.0),"Pump must exchange three Na for two K using one ATP"):return
	game.process_na_k_pumps(2.1)
	if not check(is_equal_approx(float(game.state.atp),atp_before-1.0),"A pump must not cycle without another complete set of ions"):return
	game.mols.clear()
	var membrane=game.port_pos(1.0)
	var exterior=game.cam_center+(membrane-game.cam_center)*1.11
	for i in 4:game.add_mol("na",game.cam_center,true)
	var water=game.add_mol("water",exterior,false)
	var before=Vector2(water.p).distance_to(membrane)
	game.process_osmosis(.2)
	var fast=before-Vector2(water.p).distance_to(membrane)
	water.p=exterior
	game.ports=game.ports.filter(func(port):return port.type!="aqua")
	game.process_osmosis(.2)
	var slow=before-Vector2(water.p).distance_to(membrane)
	if not check(fast>slow and slow>0.0 and is_equal_approx(float(game.state.atp),atp_before-1.0),"Aquaporins should accelerate passive water movement without ATP"):return
	game.mols.clear()
	for i in 4:game.add_mol("na",exterior,false)
	water=game.add_mol("water",game.cam_center+(membrane-game.cam_center)*.95,true)
	for i in 15:game.process_osmosis(.1)
	if not check(not water.inside and int(game.state.pumped)==1,"An outward osmotic gradient should move water out passively"):return
	game.apply_body_state("after_meal",false)
	if not check(game.blood_glucose_concentration>1.0 and game.blood_aa_concentration>1.0,"After-meal blood should carry extra nutrients"):return
	game.apply_body_state("exercise",false)
	if not check(game.blood_flow_multiplier>1.0 and game.oxygen_demand_multiplier>1.0,"Exercise should raise flow and oxygen demand"):return
	game.apply_body_state("fasting",false)
	if not check(game.blood_glucose_concentration<1.0,"Fasting should reduce glucose delivery"):return
	game.apply_body_state("poor_perfusion",false)
	if not check(game.blood_flow_multiplier<1.0,"Poor perfusion should slow capillary flow and CO2 clearance"):return
	game.apply_body_state("baseline",false)
	game.body_event_timer=.05
	game.advance_body_condition(.1)
	if not check(game.body_state=="after_meal" and game.body_event_timer>60.0,"Body conditions should advance during live play"):return
	game.start_level(7)
	game.mols.clear()
	var er: Dictionary={}
	for organelle in game.orgs:
		if organelle.type=="er" and game.er_ribosome_count(organelle)==0:er=organelle;break
	var glucose=game.add_mol("glucose",er.p,true)
	game.process_smooth_er(5.1)
	if not check(glucose.dead and game.count_mol("lipid",true)==1 and not game.state.has("carbon"),"Smooth ER should make lipid from glucose without a carbon resource"):return
	var lipid: Dictionary={}
	for molecule in game.mols:
		if molecule.type=="lipid" and not molecule.dead:lipid=molecule;break
	var protein=game.add_mol("protein",game.org("golgi").p,true,{"gene":"s_ins","stage":"folded"})
	if not check(game.package_protein_in_golgi(protein,game.org("golgi")) and lipid.dead,"Golgi vesicle formation should consume a lipid"):return
	var refused=game.add_mol("protein",game.org("golgi").p,true,{"gene":"s_ins","stage":"folded"})
	if not check(not game.package_protein_in_golgi(refused,game.org("golgi")) and not refused.dead,"Golgi should wait when it lacks lipid"):return
	var expansion=game.add_mol("lipid",er.p,true)
	game.drop_mol(expansion,er.p)
	if not check(expansion.dead and int(er.segments)==1,"A lipid should expand an ER section"):return
	var membrane_lipid=game.add_mol("lipid",game.cam_center,true)
	game.cracks.clear()
	var radius_before=Vector2(game.radius)
	game.drop_mol(membrane_lipid,game.port_pos(1.0))
	if not check(membrane_lipid.dead and game.radius.x>radius_before.x,"A lipid should expand intact membrane"):return
	game.start_level(13)
	var baseline_atp=float(game.state.atp)
	for i in 900:
		game.process_blood_flow(.05)
		game.process_molecules(.05)
		game.process_level_events(.05)
		if game.overlay.visible:break
	if not check(float(game.state.atp)<baseline_atp and float(game.osmotic_drive())<3.0,"The level's capillary K supply should let its starting pump correct the ion imbalance"):return
	game.check_win()
	if not check(game.beaten.has(13),"Passive water balance should allow the osmotic crisis level to complete"):return
	print("Homeostasis: ion exchange, passive osmosis, body conditions, and lipid uses passed")
	quit()
