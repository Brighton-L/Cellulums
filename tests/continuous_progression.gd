extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool,message: String) -> bool:
	if ok:return true
	push_error(message)
	quit(1)
	return false

func find_mol(game: Node,kind: String,gene := "") -> Dictionary:
	for molecule in game.mols:
		if molecule.dead or molecule.type!=kind:continue
		if gene!="" and molecule.get("gene","")!=gene:continue
		return molecule
	return {}

func run() -> void:
	var game=load("res://main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	if not check(game.continuous_mode and game.guide_active and not game.level_button.visible and game.guide_steps.size()>=11,"A new game should open in one guided living cell, without level select"):return
	if not check(not game.org("nucleus").is_empty() and not game.org("mitochondrion").is_empty() and not game.org("ribosome").is_empty() and not game.org("er").is_empty() and not game.org("golgi").is_empty(),"The opening cell needs its Factory organelles"):return
	game.blood_carriers.clear()
	game.mols.clear()
	game.red_cell_timer=1000.0;game.plasma_timer=1000.0
	game.state.atp=100.0
	game.update_continuous_progress(1000.0)
	if not check(game.guide_index==0 and game.next_mechanic_index==0,"Elapsed time must not advance an action-based tutorial"):return
	var glut: Dictionary={}
	for port in game.ports:
		if port.type=="glut":glut=port;break
	var glucose=game.add_mol("glucose",game.port_dock_point(glut,"glucose"),false)
	game.drop_mol(glucose,glut.p)
	for i in 12:game.process_molecules(.05)
	if not check(glucose.inside and game.guide_index>=1,"GLUT import should advance the first guided step"):return
	var oxygen=game.add_mol("o2",game.cam_center+(glut.p-game.cam_center)*.99,false)
	game.process_molecules(.05)
	if not check(oxygen.inside and game.guide_index>=2,"Oxygen diffusion should advance the guide"):return
	var mito=game.org("mitochondrion")
	game.add_mol("glucose",mito.p,true)
	for i in 2:game.add_mol("o2",mito.p,true)
	game.burn_mito()
	if not check(game.guide_index>=3,"ATP production should advance the guide"):return
	game.transcribe_gene("s_ins")
	if not check(game.guide_index>=4,"Transcribing insulin should advance the guide"):return
	var mrna=find_mol(game,"mrna","s_ins")
	var rib=game.org("ribosome")
	game.load_ribosome_template(rib,mrna)
	game.attach_ribosome_to_er(rib,game.org("er"))
	if not check(game.guide_index>=6,"Loading and attaching the ribosome should advance their steps"):return
	for i in 3:
		var aa=game.add_mol("aa",rib.p,true)
		game.drop_mol(aa,rib.p)
	if not check(game.guide_index>=8,"Amino acids and synthesis should advance their steps"):return
	seed(42)
	game.process_er_proteins(1.1)
	var protein=find_mol(game,"protein","s_ins")
	if not check(not protein.is_empty() and protein.stage=="folded" and game.guide_index>=9,"ER folding should advance the guide"):return
	game.package_protein_in_golgi(protein,game.org("golgi"))
	var vesicle=find_mol(game,"vesicle","s_ins")
	if not check(not vesicle.is_empty() and game.guide_index>=10,"Golgi packaging should advance the guide"):return
	var press=InputEventMouseButton.new()
	press.button_index=MOUSE_BUTTON_LEFT;press.pressed=true;press.position=vesicle.p
	game._unhandled_input(press)
	if not check(game.guide_index>=11,"Picking up the insulin vesicle should advance transport guidance"):return
	game.drop_mol(vesicle,game.port_pos(1.0))
	if not check(game.opening_complete and not game.guide_active and game.state.exported==1,"Exporting insulin should complete the opening without resetting the cell"):return
	var sentinel={"type":"er","p":game.cam_center+Vector2(80,60),"slots":[],"chaperones":0,"lipid_timer":0.0}
	game.orgs.append(sentinel)
	var rail=game.make_rail(game.org("golgi"),{"type":"membrane","p":game.port_pos(.9)})
	game.toolbox["motor"]=17
	game.ups["mito"]=1.3
	game.update_continuous_progress(54.0)
	if not check(not game.guide_active,"The player should have a free-play interval after the opening"):return
	game.update_continuous_progress(2.0)
	if not check(game.guide_active and game.guide_source=="waste" and game.orgs.has(sentinel) and game.rails.has(rail) and int(game.toolbox.motor)==17 and is_equal_approx(float(game.ups.mito),1.3),"The next mechanic must enter the same persistent cell"):return
	var waste=find_mol(game,"waste")
	game.drop_mol(waste,game.org("lysosome").p)
	if not check(not game.guide_active and game.completed_mechanics.has("waste"),"Recycling waste should finish its short guide"):return
	game.update_continuous_progress(71.0)
	if not check(game.guide_active and game.guide_source=="enzymes" and game.orgs.has(sentinel) and game.rails.has(rail),"Later mechanic milestones must preserve the same layout"):return
	for expected in ["signal","repair","quality","endocytosis","rails","combined","virus","homeostasis","osmosis","calcium"]:
		while game.guide_active:
			game.tutorial_event(str(game.guide_steps[game.guide_index].event))
		game.update_continuous_progress(71.0)
		if not check(game.guide_active and game.guide_source==expected and game.orgs.has(sentinel) and game.rails.has(rail) and int(game.toolbox.motor)>=17 and is_equal_approx(float(game.ups.mito),1.3),"Introducing %s must keep the living cell intact" % expected):return
	if not check(game.active_mechanics.size()==game.MECHANIC_SEQUENCE.size(),"Mechanics should accumulate without replacing prior cell state"):return
	print("Continuous progression: action-led opening, free play, and persistent mechanic milestones passed")
	quit()
