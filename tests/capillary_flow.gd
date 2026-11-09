extends SceneTree

var game: Node

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool,message: String) -> bool:
	if condition:return true
	push_error(message)
	quit(1)
	return false

func run() -> void:
	game=load("res://main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.start_level(10)
	if not check(game.capillary_path.size()>20,"Capillary path was not read from the bottom texture"):return
	var entry=game.capillary_point(0.0)
	var middle=game.capillary_point(.5)
	var exit_corner=game.capillary_point(1.0)
	if not check(entry.x<middle.x and entry.y<middle.y,"Inputs must enter from the texture's top-left opening"):return
	if not check(exit_corner.x>middle.x and exit_corner.y>middle.y and exit_corner.x>game.capillary_rect().end.x-14.0,"Outputs must reach the bottom-right opening of the drawn texture"):return
	if not check(game.blood_carriers.size()==2 and game.blood_carriers[0].type=="rbc" and game.blood_carriers[1].type=="plasma","Red blood cells and plasma packets should enter the capillary at level start"):return
	if not check(game.count_mol("glucose")==0 and game.count_mol("o2")==0 and game.count_mol("aa")==0,"Nutrients and oxygen must not sit outside at level start"):return
	game.blood_carriers.clear()
	game.red_cell_timer=100.0;game.plasma_timer=100.0
	game.apply_pack_effect("nut_glucose")
	if not check(game.blood_carriers.size()==2 and game.blood_carriers[0].type=="plasma" and int(game.blood_carriers[0].payload.glucose)==4,"Pack glucose should ride in plasma packets"):return
	for i in 90:game.process_blood_flow(.05)
	var rewards=[]
	for m in game.mols:
		if m.type=="glucose" and m.get("cap_state","")=="incoming_eject":rewards.append(m)
	if not check(rewards.size()==8,"Plasma packets should release eight pack glucose molecules near the exchange zone"):return
	var first: Dictionary=rewards[-1]
	var saw_ejection=first.get("cap_state","")=="incoming_eject"
	for i in 30:
		game.advance_capillary(first,.05)
		if first.get("cap_state","")=="incoming_eject":saw_ejection=true
	if not check(saw_ejection and first.get("cap_state","")=="","Incoming resource should cross above the top layer and eject"):return
	if not check(not first.inside,"Ejected resource should start as an outside molecule"):return
	if not check(not game.capillary_blocked(first.p,10.0),"Ejected resource must clear the capillary wall before free drift"):return
	var resizing=game.spawn_capillary_resource("glucose")
	resizing.cap_state="incoming_eject"
	resizing.cap_progress=.5
	resizing.cap_time=.35
	resizing.cap_origin=game.capillary_point(.5)
	resizing.p=resizing.cap_origin
	resizing.cap_target=game.capillary_eject_target(resizing)
	var old_middle=game.capillary_point(.5)
	root.size=Vector2i(1000,620)
	await process_frame
	if not check(old_middle.distance_to(game.capillary_point(.5))>1.0,"Resize test must move the capillary"):return
	if not check(Vector2(resizing.cap_origin).distance_to(game.capillary_point(.5))<.01,"An arriving molecule must follow the capillary when the window resizes"):return
	for i in 30:game.advance_capillary(resizing,.05)
	if not check(resizing.get("cap_state","")=="" and not game.capillary_blocked(resizing.p,10.0),"Arrival must still clear the capillary after resizing"):return
	root.size=Vector2i(1220,760)
	await process_frame
	if not check(not game.capillary_blocked(resizing.p,10.0),"A newly arrived molecule must stay clear of the capillary on a second resize"):return
	var capillary_center=game.capillary_point(.5)
	var safe_side=game.capillary_eject_target({"type":"glucose","p":capillary_center})-capillary_center
	if not check((Vector2(resizing.p)-capillary_center).dot(safe_side)>0.0,"A newly arrived molecule must remain on the cell-facing side after resizing"):return
	exit_corner=game.capillary_point(1.0)
	game.mols.clear();game.blood_carriers.clear()
	game.process_level_events(.05)
	if not check(game.count_mol("o2")==0 and game.count_mol("glucose")==0,"Scarcity must not spawn resources directly"):return
	game.spawn_blood_carrier("rbc",{"o2":3},0.0,.4)
	for i in 30:game.process_blood_flow(.05)
	if not check(game.count_mol("o2")>=2 and game.count_mol("o2")<=3,"A passing red blood cell should unload oxygen according to local demand"):return
	var co2=game.add_mol("co2",game.co2_exchange_edge()+Vector2(48,0),false)
	var saw_wait=false
	var saw_plasma=false
	var saw_descend=false
	var saw_return=false
	for i in 700:
		game.process_molecules(.05)
		var stage=str(co2.get("cap_state",""))
		if stage=="co2_wait":saw_wait=true
		if stage=="co2_plasma_absorb":saw_plasma=true
		if stage=="co2_descend":saw_descend=true
		if stage=="co2_return":saw_return=true
		if co2.dead:break
	if not check(saw_wait and saw_plasma and saw_descend and saw_return and co2.dead and co2.p.distance_to(exit_corner)<.01,"Uncollected CO2 should wait outside, enter plasma, then leave at the bottom-right end"):return
	game.start_level(3)
	var vesicle=game.add_mol("vesicle",game.port_pos(1.0),true,{"gene":"s_ins","destination":"outside","cargo":"insulin","stage":"vesicle"})
	game.drop_mol(vesicle,game.port_pos(1.0))
	var exported: Dictionary={}
	for m in game.mols:
		if m.type=="exported_protein":exported=m;break
	if not check(vesicle.dead and not exported.is_empty() and exported.get("cap_state","")=="co2_seek","Cell-wall export must start the protein's capillary exit"):return
	var saw_protein_return=false
	for i in 500:
		game.advance_capillary(exported,.05)
		if exported.get("cap_state","")=="co2_return":saw_protein_return=true
		if exported.dead:break
	if not check(saw_protein_return and exported.dead and exported.p.distance_to(exit_corner)<.01,"Exported protein must travel from the capillary center to the bottom-right end and disappear"):return
	game.start_level(13)
	for m in game.mols:
		if m.type=="water" and not check(m.get("cap_state","")=="incoming_under" and not m.inside,"Flood water must arrive through the capillary"):return
	for i in 260:game.process_molecules(.05)
	if not check(game.count_mol("water",true)>=12,"Flood water must reach the cell after traveling through the capillary"):return
	game.start_level(11)
	game.state.na_cd=0.0
	game.process_level_events(.05)
	for m in game.mols:
		if m.type=="na" and not check(m.get("cap_state","")=="incoming_under" and not m.inside,"External ions must arrive through the capillary"):return
	print("Capillary flow: arrivals survive resizing, outputs exit, and external water/ions passed")
	quit()
