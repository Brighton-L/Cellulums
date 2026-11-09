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
	game.start_level(2)
	var rib=game.org("ribosome")
	var template=game.add_mol("mrna",rib.p+Vector2(-55,0),true,{"gene":"c_motor","translations":4})
	if not check(game.load_ribosome_template(rib,template),"mRNA should load into the ribosome"):return
	if not check(template.bound and template.p==game.mrna_slot_pos(rib),"Bound mRNA must occupy the rectangular ribosome slot"):return
	if not check(game.MRNA_SLOT_SIZE.x<game.MRNA_SLOT_SIZE.y and game.MRNA_SLOT_SIZE.x>=10.0 and game.MRNA_SLOT_SIZE.y>=26.4,"The slot must closely fit the vertical mRNA sprite"):return
	for uses in [4,3,2,1]:
		var tex=game.mrna_texture(uses)
		if not check(tex!=null and tex.resource_path.ends_with("MRNA-%dU.png" % uses),"Remaining uses must select the matching mRNA texture"):return
		if not check(int(template.translations)==uses and template.p==game.mrna_slot_pos(rib),"mRNA must stay in its slot until the next translation"):return
		for i in 3:
			var aa=game.add_mol("aa",rib.p,true)
			game.drop_mol(aa,rib.p)
	if not check(template.dead and rib.template.is_empty(),"The fourth translation must clear the slot"):return
	print("mRNA slot: 4U to 1U textures, slot attachment, and degradation passed")
	quit()
