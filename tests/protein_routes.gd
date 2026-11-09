extends SceneTree

var game: Node

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool,message: String) -> bool:
	if ok:return true
	push_error(message)
	quit(1)
	return false

func living(kind: String,gene := "") -> Dictionary:
	for m in game.mols:
		if m.dead or m.type!=kind:continue
		if gene.is_empty() or m.get("gene","")==gene:return m
	return {}

func drag_ribosome(target: Vector2) -> void:
	var rib=game.org("ribosome")
	var press=InputEventMouseButton.new()
	press.button_index=MOUSE_BUTTON_LEFT;press.pressed=true;press.position=rib.p
	game._unhandled_input(press)
	var motion=InputEventMouseMotion.new()
	motion.position=target
	game._unhandled_input(motion)
	var release=InputEventMouseButton.new()
	release.button_index=MOUSE_BUTTON_LEFT;release.pressed=false;release.position=target
	game._unhandled_input(release)

func prepare(key: String) -> Dictionary:
	game.start_level(10)
	game.max_unlocked=15
	game.level=2 # Deterministic route checks without random folding errors.
	game.state.atp=1000.0
	game.transcribe_gene(key)
	var mrna=living("mrna",key)
	if mrna.is_empty():return {}
	var rib=game.org("ribosome")
	var original: Vector2=rib.p
	game.drop_mol(mrna,rib.p)
	var gene: Dictionary=game.GENES[key]
	var er=game.org("er")
	if gene.needs_er:
		if rib.p!=original or rib.state!="awaiting_er":return {}
		drag_ribosome(Vector2(er.p)+Vector2(-34,-26))
		if rib.state!="er_bound" or rib.bound_er!=er:return {}
	var before_toolbox=int(game.toolbox.get(str(gene.get("toolbox_item","")),0))
	for i in 3:
		var aa=game.add_mol("aa",rib.p,true)
		game.drop_mol(aa,rib.p)
	var produced: Dictionary={}
	for m in game.mols:
		if m.type=="protein" and m.get("gene","")==key:produced=m
	return {"rib":rib,"er":er,"mrna":mrna,"protein":produced,"before_toolbox":before_toolbox}

func run() -> void:
	game=load("res://main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	if not check(game.GENES.size()==13,"Expected 13 starting genes"):return
	game.start_level(2)
	game.max_unlocked=1
	if not check(game.gene_unlocked("s_ins") and not game.gene_unlocked("e_chaperone") and not game.gene_unlocked("m_nak") and not game.gene_unlocked("n_dna_repair"),"Only Beginning genes should be initially unlocked"):return
	var atp=float(game.state.atp)
	game.transcribe_gene("e_chaperone")
	if not check(is_equal_approx(float(game.state.atp),atp) and living("mrna","e_chaperone").is_empty(),"Locked genes must not transcribe"):return
	game.max_unlocked=4
	if not check(game.gene_unlocked("e_chaperone") and not game.gene_unlocked("m_nak"),"Protein Processing should unlock before Homeostasis"):return
	game.max_unlocked=11
	if not check(game.gene_unlocked("m_nak") and not game.gene_unlocked("n_dna_repair"),"Homeostasis should unlock before Stress"):return
	game.max_unlocked=12
	if not check(game.gene_unlocked("n_dna_repair"),"Stress genes should unlock later"):return
	var rib=game.org("ribosome")
	var no_template=game.add_mol("aa",rib.p,true)
	game.drop_mol(no_template,rib.p)
	if not check(not no_template.dead and game.state.made==0 and rib.gene=="","No protein without mRNA"):return
	game.transcribe_gene("s_ins")
	if not check(is_equal_approx(float(game.state.atp),atp-2.0),"All transcription should cost 2 ATP"):return
	var mrna=living("mrna","s_ins")
	var original: Vector2=rib.p
	game.drop_mol(mrna,rib.p)
	if not check(rib.p==original and rib.state=="awaiting_er" and rib.bound_er.is_empty(),"Loading mRNA must not teleport ribosome"):return
	var waiting_aa=game.add_mol("aa",rib.p,true)
	game.drop_mol(waiting_aa,rib.p)
	if not check(not waiting_aa.dead and game.state.made==0,"ER translation must wait for physical attachment"):return
	var first_er=game.org("er")
	var second_er={"type":"er","p":game.cam_center+Vector2(-game.radius.x*.2,game.radius.y*.55),"chaperones":0,"lipid_timer":0.0}
	game.orgs.append(second_er)
	drag_ribosome(Vector2(first_er.p)+Vector2(-34,-26))
	if not check(rib.state=="er_bound" and rib.bound_er==first_er and game.er_ribosome_count(first_er)==1 and game.er_ribosome_count(second_er)==0,"Ribosome should attach to one ER section"):return
	var lipid_precursor=game.add_mol("glucose",second_er.p,true)
	first_er.lipid_timer=5.0
	second_er.lipid_timer=5.0
	game.process_smooth_er(.1)
	if not check(living("lipid").get("source_er",{})==second_er and lipid_precursor.dead,"Only smooth ER should consume glucose to produce lipid"):return
	drag_ribosome(Vector2(second_er.p)+Vector2(-34,-26))
	if not check(rib.bound_er==second_er and game.er_ribosome_count(first_er)==0 and game.er_ribosome_count(second_er)==1,"Dragging between ER sections should switch the rough region"):return
	drag_ribosome(Vector2(first_er.p)+Vector2(-34,-26))
	if not check(rib.bound_er==first_er and game.er_ribosome_count(first_er)==1,"Ribosome should reattach to its chosen ER section"):return
	for translation in 4:
		for i in 3:
			var aa=game.add_mol("aa",rib.p,true)
			game.drop_mol(aa,rib.p)
		var protein=living("protein","s_ins")
		if not check(not protein.is_empty() and protein.stage=="in_er" and protein.bound and protein.bound_er==first_er,"Secretory protein should enter its ER directly"):return
		var direct_rail=game.make_rail(rib,{"type":"membrane","p":game.port_pos(1.0)})
		direct_rail.motors.append({"p":0.0,"state":"idle","cargo":{},"stalled":false})
		game.rail_pickup(direct_rail,direct_rail.motors[0])
		if not check(direct_rail.motors[0].cargo.is_empty(),"Rail must not take nascent ER protein from ribosome"):return
		game.rails.erase(direct_rail)
		game.process_er_proteins(1.1)
		if not check(protein.stage=="folded" and not protein.bound,"Rough ER should release folded cargo"):return
		protein.dead=true
		if translation<3 and not check(not mrna.dead and int(mrna.translations)==3-translation,"mRNA should support repeated translation"):return
	if not check(mrna.dead and rib.gene=="" and rib.state=="free","mRNA should degrade after four translations"):return
	var glucose=game.add_mol("glucose",first_er.p,true)
	game.drop_mol(glucose,first_er.p)
	if not check(not glucose.dead and living("lipoves").is_empty(),"Glucose drop must not make lipid vesicle"):return
	var removal=prepare("s_ins")
	var spare_er={"type":"er","p":game.cam_center+Vector2(-game.radius.x*.2,game.radius.y*.55),"chaperones":0,"lipid_timer":0.0}
	game.orgs.append(spare_er)
	game.context_org=spare_er
	game.context_action(1)
	if not check(removal.rib.bound_er==removal.er and removal.rib.state=="er_bound","Removing another ER must leave this ribosome attached"):return
	game.context_org=removal.er
	game.context_action(1)
	if not check(removal.rib.bound_er.is_empty() and removal.rib.state=="awaiting_er" and removal.mrna.bound,"Removing the bound ER must detach only its ribosome and keep its mRNA"):return
	for key in game.GENES:
		var made=prepare(str(key))
		if not check(not made.is_empty() and not made.protein.is_empty(),"Gene %s must make a protein" % key):return
		var protein: Dictionary=made.protein
		var gene: Dictionary=game.GENES[key]
		if not check(protein.gene==key and protein.destination==gene.destination and protein.product==gene.product,"Protein %s must keep identity" % key):return
		if gene.needs_er:
			if not check(protein.stage=="in_er" and protein.bound_er==made.er,"ER protein should not be loose in cytoplasm"):return
			game.process_er_proteins(1.1)
			if gene.needs_golgi:
				if not check(protein.stage=="folded","Rough ER should fold %s" % key):return
				game.drop_mol(protein,game.org("golgi").p)
				var vesicle=living("vesicle",str(key))
				if gene.get("ready_at","")=="golgi":
					var item=str(gene.toolbox_item)
					if not check(protein.dead and protein.stage=="ready" and vesicle.is_empty() and int(game.toolbox.get(item,0))==int(made.before_toolbox)+1,"Golgi packaging should immediately add %s to the toolbar" % key):return
					var ports_before=game.ports.size()
					game.select_tool(item)
					game.place_at(game.port_pos(1.0))
					if not check(game.ports.size()==ports_before+1 and game.ports[-1].type==gene.product and int(game.toolbox.get(item,0))==int(made.before_toolbox),"Player should place the packaged %s from the toolbar" % key):return
				elif gene.destination=="lysosome":
					if not check(not vesicle.is_empty() and vesicle.cargo==gene.product and vesicle.destination==gene.destination,"Golgi should preserve %s cargo" % key):return
					var ly=game.org("lysosome")
					game.drop_mol(vesicle,game.port_pos(1.0))
					if not check(not vesicle.dead,"Lysosome cargo must refuse membrane"):return
					game.drop_mol(vesicle,ly.p)
					if not check(vesicle.dead and int(ly.get("enzyme_counts",{}).get("protein",0))==1,"Lysosomal protease must install with protein specificity"):return
				else:
					if not check(not vesicle.is_empty() and vesicle.cargo==gene.product and vesicle.destination==gene.destination,"Golgi should preserve %s cargo" % key):return
					var before=int(game.state.exported)
					game.drop_mol(vesicle,game.org("lysosome").p)
					if not check(not vesicle.dead,"Membrane cargo must refuse lysosome"):return
					var ports_before=game.ports.size()
					var parts_before=int(game.toolbox.get(str(gene.get("toolbox_item","")),0))
					game.drop_mol(vesicle,game.port_pos(1.0))
					if not check(vesicle.dead,"Membrane cargo must fuse"):return
					if gene.destination=="outside":
						if not check(int(game.state.exported)==before+1 and not living("exported_protein",str(key)).is_empty(),"Insulin must export outside"):return
					else:
						if not check(int(game.state.exported)==before and game.ports.size()==ports_before and int(game.toolbox[gene.toolbox_item])==parts_before+1,"Vesicle fusion should add a placeable component without choosing its position"):return
						game.select_tool(str(gene.toolbox_item))
						game.place_at(game.port_pos(1.0))
						if not check(game.ports.size()==ports_before+1 and game.ports[-1].type==gene.product and int(game.toolbox.get(str(gene.toolbox_item),0))==parts_before,"Player should install manufactured membrane component from toolbox"):return
						if gene.product=="nak":
							var pump=game.ports[-1]
							var sodium=[]
							var potassium=[]
							for i in 3:sodium.append(game.add_mol("na",pump.p+Vector2(-20,0),true))
							for i in 2:potassium.append(game.add_mol("k",pump.p+Vector2(20,0),false))
							var before_atp=float(game.state.atp)
							game.process_level_events(.05)
							if not check(not sodium[0].inside and not sodium[1].inside and not sodium[2].inside and potassium[0].inside and potassium[1].inside and is_equal_approx(float(game.state.atp),before_atp-1.0),"Installed Na⁺/K⁺ pump must exchange 3 Na⁺ for 2 K⁺ using 1 ATP"):return
			else:
				if not check(protein.dead and protein.stage=="ready" and int(made.er.chaperones)==0 and int(game.toolbox.get("erchaperone",0))==int(made.before_toolbox)+1,"Folded chaperone should enter toolbox without auto-installing"):return
				var target_er={"type":"er","p":game.cam_center+Vector2(-game.radius.x*.2,game.radius.y*.55),"chaperones":0,"lipid_timer":0.0}
				game.orgs.append(target_er)
				game.select_tool("erchaperone")
				game.place_at(target_er.p)
				if not check(int(target_er.chaperones)==1 and int(made.er.chaperones)==0 and int(game.toolbox.get("erchaperone",0))==int(made.before_toolbox),"Player should choose which ER receives the chaperone"):return
				game.mode="qc"
				if not check(game.er_fold_failure_chance(target_er)<game.er_fold_failure_chance(made.er),"Chaperone should lower only its chosen ER section's folding failure chance"):return
		elif gene.destination=="microtubule":
			if not check(protein.stage=="ready" and protein.dead and made.rib.state=="free" and int(game.toolbox.get("motor",0))==int(made.before_toolbox)+1,"Free ribosome should add a completed Motor Protein to toolbox"):return
			var rail=game.make_rail(game.org("golgi"),{"type":"membrane","p":game.port_pos(.9)})
			var motors=rail.motors.size()
			game.select_tool("motor")
			game.place_at(game.rail_pos(rail,.5))
			if not check(rail.motors.size()==motors+1 and int(game.toolbox.get("motor",0))==int(made.before_toolbox),"Player should choose the rail for a manufactured motor"):return
		elif gene.destination=="cytoplasm":
			if not check(protein.stage=="nascent" and not protein.dead,"Cytoplasmic protein must remain physical"):return
			game.drop_mol(protein,game.cam_center+Vector2(0,70))
			if not check(protein.stage=="installed" and not protein.dead,"Placed cytoplasmic protein must stay visible"):return
		elif gene.destination=="crack":
			game.cracks.append(1.0)
			game.drop_mol(protein,game.port_pos(1.0))
			if not check(protein.dead and not game.cracks.is_empty() and game.crack_state(1.0).protein,"Repair protein should stabilize a tear until lipid material arrives"):return
			var repair_lipid=game.add_mol("lipid",game.cam_center,true)
			game.drop_mol(repair_lipid,game.port_pos(1.0))
			if not check(repair_lipid.dead and game.cracks.is_empty(),"Lipid should finish sealing a protein-stabilized tear"):return
		elif gene.destination=="nucleus":
			game.drop_mol(protein,game.org("nucleus").p)
			if not check(protein.dead and int(game.ups.get("dna_repair",0))>0,"DNA repair protein must enter nucleus"):return
	var transported=prepare("m_glut")
	game.process_er_proteins(1.1)
	var ports_before=game.ports.size()
	var parts_before=int(game.toolbox.get("glutport",0))
	game.drop_mol(transported.protein,game.org("golgi").p)
	if not check(game.ports.size()==ports_before and int(game.toolbox.get("glutport",0))==parts_before+1 and living("vesicle","m_glut").is_empty(),"Golgi packaging must put GLUT in the toolbar without membrane delivery"):return
	game.select_tool("glutport")
	game.place_at(game.port_pos(.9))
	if not check(game.ports.size()==ports_before+1 and game.ports[-1].type=="glut","Player should place the packaged GLUT where desired"):return
	var er_transport=prepare("s_ins")
	game.process_er_proteins(1.1)
	var er_rail=game.make_rail(er_transport.er,game.org("golgi"))
	game.select_tool("motor")
	game.place_at(game.rail_pos(er_rail,.5))
	for frame in 900:
		game.update_rails(.05)
		if not living("vesicle","s_ins").is_empty():break
	if not check(not living("vesicle","s_ins").is_empty() and er_rail.motors[0].cargo.is_empty(),"Rail should collect folded insulin from its source rough ER and deliver it to Golgi"):return
	print("Protein routes: physical ER attachment, local folding, unlocks, smooth lipids, and destinations passed")
	quit()
