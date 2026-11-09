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
	if not check(game.blood_cell_texture!=null and game.plasma_packet_texture!=null,"Both blood-flow textures must load"):return
	if not check(game.red_cell_timer>=12.0 and game.red_cell_timer<=20.0 and game.plasma_timer>=14.0 and game.plasma_timer<=24.0,"Carrier arrival timers must remain leisurely and independent of demand"):return
	game.blood_carriers.clear();game.mols.clear()
	game.red_cell_timer=100.0;game.plasma_timer=100.0
	var red=game.spawn_blood_carrier("rbc",{"o2":3},0.0,.40)
	red.speed=1.0
	if not check(game.pick_blood_carrier(game.capillary_point(.40))==red,"Visible red blood cells should be inspectable in the capillary"):return
	game.show_inspect(red,true)
	if not check(game.inspect_heading.text=="Red Blood Cell" and not game.paused,"Blood-cell information should open without pausing"):return
	game.close_inspect()
	for i in 25:game.process_blood_flow(.05)
	if not check(int(red.released_o2)>=2 and int(red.released_o2)<=3 and game.count_mol("o2")==int(red.released_o2) and int(red.oxygenation)==3-int(red.released_o2) and not red.dead,"A red blood cell must unload according to local demand and continue downstream"):return
	for oxygen in game.mols:
		if not check(not oxygen.inside and oxygen.cap_state=="incoming_eject" and not game.in_cell(oxygen.cap_target),"Released oxygen must emerge outside the capillary and cell"):return
	for i in 500:game.process_molecules(.05)
	if not check(game.count_mol("o2",true)>0,"Red-cell oxygen must be able to diffuse into the cell"):return
	for i in 40:game.process_blood_flow(.05)
	if not check(red.dead and not game.blood_carriers.has(red),"The red blood cell must leave the visible capillary"):return
	game.mols.clear()
	var gradient_cell=game.spawn_blood_carrier("rbc",{"o2":3},0.0,.40)
	for i in 5:game.add_mol("o2",game.capillary_point(.52)+Vector2(45+i*5,15),false)
	if not check(game.red_cell_unload_target(gradient_cell)==0,"High extracellular O2 must suppress unloading"):return
	game.mols.resize(3)
	if not check(game.desired_delivery_units("o2",19.0)>0.0 and game.desired_delivery_units("o2",19.0)<3.0,"Medium extracellular O2 should reduce unloading smoothly"):return
	game.mols.resize(1)
	if not check(game.desired_delivery_units("o2",19.0)>2.0,"Low extracellular O2 should call for more unloading"):return
	for i in 7:game.add_mol("o2",game.cam_center+Vector2(i*8,0),true)
	if not check(game.red_cell_unload_target(gradient_cell)==0,"Abundant cellular O2 must suppress unloading even if nearby extracellular O2 is low"):return
	game.mols.clear()
	if not check(game.red_cell_unload_target(gradient_cell)==3,"An empty oxygen pool should request a full red-cell unload to establish basal supply"):return
	game.blood_carriers.clear();game.mols.clear()
	game.red_cell_timer=100.0;game.plasma_timer=100.0
	var saturated=game.spawn_blood_carrier("rbc",{"o2":3},0.0,.40)
	for i in 5:game.add_mol("o2",game.capillary_point(.52)+Vector2(45+i*5,15),false)
	for i in 25:game.process_blood_flow(.05)
	if not check(int(saturated.released_o2)==0 and not saturated.dead,"A passing red blood cell should carry oxygen onward when local O2 is high"):return
	game.mols.clear()
	var plasma=game.spawn_blood_carrier("plasma",{"glucose":3,"aa":4},0.0,.50)
	plasma.speed=1.0
	game.process_blood_flow(.15)
	if not check(game.count_mol("glucose")==3 and game.count_mol("aa")==4 and not plasma.dead,"A plasma packet must release both nutrients without disappearing"):return
	for nutrient in game.mols:
		if not check(not nutrient.inside,"Plasma nutrients must be released outside the cell"):return
	for i in 55:game.process_blood_flow(.05)
	if not check(plasma.dead and game.count_mol("glucose")==3 and game.count_mol("aa")==4,"A released plasma packet must keep flowing to the exit"):return
	game.mols.clear()
	var empty=game.spawn_blood_carrier("plasma",{"glucose":2},0.0,.51)
	empty.payload={}
	game.process_blood_flow(.1)
	if not check(empty.released and game.mols.is_empty(),"A nutrient-free plasma packet must release nothing"):return
	game.blood_carriers.clear()
	var collector=game.spawn_blood_carrier("rbc",{"o2":0},0.0,.46)
	collector.speed=1.0
	var co2=game.add_mol("co2",game.co2_exchange_edge(),false,{"cap_state":"co2_wait","co2_wait_elapsed":0.0,"co2_wait_limit":12.0})
	game.process_blood_flow(.05)
	if not check(co2.cap_state=="co2_rbc_capture" and not co2.dead and int(collector.co2_load)==0,"An RBC should visibly pull nearby waiting CO2 before collecting it"):return
	for i in 10:
		game.process_blood_flow(.05)
		game.process_molecules(.05)
	if not check(co2.dead and int(collector.co2_load)==1,"A red blood cell should collect CO2 after the capture animation"):return
	game.blood_carriers.clear();game.mols.clear()
	var limited=game.spawn_blood_carrier("rbc",{"o2":0},0.0,.49)
	limited.speed=.25
	for i in 3:game.add_mol("co2",game.co2_exchange_edge()+Vector2(i*3,0),false,{"cap_state":"co2_wait","co2_wait_elapsed":0.0,"co2_wait_limit":12.0})
	for i in 30:
		game.process_blood_flow(.05)
		game.process_molecules(.05)
	if not check(int(limited.co2_load)==2 and game.count_mol("co2")==1,"An RBC should collect at most two nearby CO2 molecules"):return
	game.blood_carriers.clear();game.mols.clear()
	var slow=game.spawn_blood_carrier("rbc",{"o2":0})
	slow.speed=1.0;game.blood_flow_multiplier=.25
	game.process_blood_flow(1.0)
	var slow_progress=float(slow.progress)
	game.blood_carriers.clear()
	var fast=game.spawn_blood_carrier("rbc",{"o2":0})
	fast.speed=1.0;game.blood_flow_multiplier=2.0
	game.process_blood_flow(1.0)
	if not check(float(fast.progress)>slow_progress*5.0,"Flow multiplier must change carrier speed"):return
	game.blood_carriers.clear();game.red_cell_timer=1.0;game.plasma_timer=100.0
	game.blood_flow_multiplier=.25
	game.process_blood_flow(1.0)
	if not check(game.blood_carriers.is_empty(),"Low flow should delay the next red blood cell"):return
	game.blood_flow_multiplier=2.0
	game.process_blood_flow(.4)
	if not check(game.blood_carriers.size()==1 and game.blood_carriers[0].type=="rbc","High flow should increase red blood cell arrival frequency"):return
	var carbon=game.add_mol("co2",game.capillary_point(.5)+Vector2(-90,65),false,{"v":Vector2.ZERO,"cap_state":"co2_seek"})
	var original=Vector2(carbon.p)
	game.blood_flow_multiplier=1.0
	seed(99);game.advance_capillary(carbon,.1)
	var normal_distance=original.distance_to(carbon.p)
	carbon.p=original;carbon.v=Vector2.ZERO
	game.blood_flow_multiplier=.25
	seed(99);game.advance_capillary(carbon,.1)
	if not check(original.distance_to(carbon.p)<normal_distance,"Poor blood flow should slow extracellular CO2 removal"):return
	game.blood_glucose_concentration=0.0;game.blood_aa_concentration=0.0
	for i in 20:
		if not check(game.plasma_payload().is_empty(),"Zero plasma nutrient concentration must suppress nutrient release"):return
	game.blood_glucose_concentration=1.0;game.blood_aa_concentration=1.0
	game.mols.clear()
	if not check(absf(game.desired_delivery_units("glucose",24.0)-3.0)<.01 and absf(game.desired_delivery_units("aa",24.0)-4.0)<.01,"Basal stock floors should request starter nutrients without any consumption history"):return
	for i in 20:
		var starter=game.plasma_payload()
		if not check(starter.has("glucose") and starter.has("aa"),"An empty cell should receive both basal nutrients on the next plasma packet"):return
	for i in 3:game.add_mol("glucose",game.cam_center,true)
	for i in 4:game.add_mol("aa",game.cam_center,true)
	if not check(game.plasma_payload().is_empty(),"Carriers should release nothing when basal stocks are already met and consumption is zero"):return
	game.mols.clear()
	for i in 2:game.add_mol("glucose",game.cam_center,true)
	for i in 2:game.add_mol("aa",game.cam_center,true)
	seed(20260929)
	var glucose_packets=0
	var aa_packets=0
	var both_packets=0
	for i in 2000:
		var payload=game.plasma_payload()
		if payload.has("glucose"):
			glucose_packets+=1
			if not check(int(payload.glucose)>=2 and int(payload.glucose)<=4,"Plasma glucose payloads should contain two to four molecules"):return
		if payload.has("aa"):
			aa_packets+=1
			if not check(int(payload.aa)>=3 and int(payload.aa)<=5,"Plasma amino acid payloads should contain three to five molecules"):return
		if payload.has("glucose") and payload.has("aa"):both_packets+=1
	if not check(absf(float(glucose_packets)/2000.0-1.0/3.0)<.05 and absf(float(aa_packets)/2000.0-.5)<.05 and absf(float(both_packets)/2000.0-1.0/6.0)<.05,"Plasma rolls should be independent and smoothly reflect each nutrient's stock gap"):return
	game.mols.clear()
	var near_cell=game.capillary_eject_target({"type":"glucose","p":game.capillary_point(.52)})
	for i in 3:game.add_mol("glucose",near_cell,false)
	if not check(absf(game.effective_resource_stock("glucose")-2.1)<.01,"Nearby extracellular nutrients should count at 70% toward available stock"):return
	game.mols.clear()
	game.record_resource_consumption("glucose",5.0)
	game.update_demand_estimates(5.0)
	var first_rate=float(game.predicted_use_rate.glucose)
	if not check(first_rate>.10 and first_rate<.20,"Recent consumption should raise the smoothed demand gradually"):return
	game.update_demand_estimates(5.0)
	if not check(float(game.predicted_use_rate.glucose)<first_rate and float(game.predicted_use_rate.glucose)>0.0,"Smoothed demand should decay gradually after consumption stops"):return
	game.predicted_use_rate.glucose=.10
	game.blood_flow_multiplier=1.0
	game.mols.clear()
	for i in 3:game.add_mol("glucose",game.cam_center,true)
	if not check(absf(game.desired_delivery_units("glucose",19.0)-2.185)<.01,"At target stock, delivery should follow predicted consumption with a 15% buffer"):return
	game.predicted_use_rate.aa=8.0/60.0
	for i in 26:game.add_mol("aa",near_cell,false)
	for i in 7:game.add_mol("aa",game.cam_center,true)
	if not check(game.desired_delivery_units("aa",24.0)==0.0 and not game.plasma_payload().has("aa"),"A large existing amino acid pool must override recent demand"):return
	game.start_level(2)
	game.blood_carriers.clear();game.mols.clear()
	var mito=game.org("mitochondrion")
	game.add_mol("glucose",mito.p,true)
	for i in 2:game.add_mol("o2",mito.p,true)
	game.burn_mito()
	if not check(float(game.consumption_pending.glucose)==1.0 and float(game.consumption_pending.o2)==2.0,"Mitochondrial reactions must record glucose and oxygen use"):return
	game.transcribe_gene("s_ins")
	var transcript: Dictionary={}
	for molecule in game.mols:
		if molecule.type=="mrna" and not molecule.dead:
			transcript=molecule
			break
	var rib=game.org("ribosome")
	game.drop_mol(transcript,rib.p)
	game.attach_ribosome_to_er(rib,game.org("er"))
	var amino=game.add_mol("aa",rib.p,true)
	game.drop_mol(amino,rib.p)
	if not check(float(game.consumption_pending.aa)==1.0,"Ribosome translation must record amino acid use"):return
	print("Blood flow: red cells, plasma, CO2 pickup, downstream exit, and flow controls passed")
	quit()
