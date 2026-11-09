extends SceneTree

var game: Node

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool,message: String) -> bool:
	if ok:return true
	push_error(message)
	quit(1)
	return false

func run() -> void:
	game=load("res://main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.start_level(14)
	game.mols.clear()
	var a=game.add_mol("glucose",game.cam_center+Vector2(-20,60),true,{"v":Vector2(30,0)})
	var b=game.add_mol("aa",game.cam_center+Vector2(-10,60),true,{"v":Vector2(-30,0)})
	game.process_molecules(.05)
	if not check(a.p.distance_to(b.p)>=game.push_radius(a)+game.push_radius(b)-2.0,"Free molecules must separate when they collide"):return
	if not check(a.v.x<30 and b.v.x> -30,"Free molecules must exchange momentum on contact"):return
	game.mols.clear()
	var first=game.add_mol("glucose",game.capillary_point(.5)+Vector2(0,-100),false,{"v":Vector2(0,80)})
	var second=game.add_mol("aa",first.p+Vector2(10,0),false,{"v":Vector2.ZERO})
	game.process_molecules(.05)
	if not check(first.p.distance_to(second.p)>=game.push_radius(first)+game.push_radius(second)-2.0,"Outside molecules must also collide while drifting"):return
	game.mols.clear()
	var arrivals=[]
	for i in 20:arrivals.append(game.spawn_capillary_resource("glucose",i*.04))
	for frame in 400:game.process_molecules(.05)
	for m in arrivals:
		if not check(m.get("cap_state","")=="","Crowded capillary arrivals must finish ejecting"):return
		if not check(not game.capillary_blocked(m.p,10.0),"Ejected molecules must remain clear of the capillary wall"):return
	for kind in ["o2","aa","hormone","chunk","water","ca","na"]:
		game.mols.clear()
		var arrival=game.spawn_capillary_resource(kind)
		for frame in 120:
			game.advance_capillary(arrival,.05)
			if arrival.get("cap_state","") in ["ion_seek",""]:break
		if not check(arrival.get("cap_state","") in ["ion_seek",""],"Each molecule type must finish ejecting"):return
		var clearance=float(game.RADII[kind])+2.0
		if not check(not game.capillary_blocked(arrival.p,clearance),"Every ejected molecule type must clear the capillary wall"):return
	print("Passive collisions and crowded capillary ejection passed")
	quit()
