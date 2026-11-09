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
	var count=int(game.toolbox.get("glutport",0))
	var ports_before=game.ports.size()
	game.placing="glutport"
	game.place_at(game.cam_center)
	if not check(game.ports.size()==ports_before and int(game.toolbox.get("glutport",0))==count,"A GLUT port dropped away from the wall must not be placed or consumed"):return
	var wall_point=game.cam_center+Vector2(game.radius.x*.75,game.radius.y*.66)
	game.toolbox_drag_kind="glutport"
	game.toolbox_drag_pos=wall_point
	game.update_placement_preview()
	var angle=atan2(wall_point.y-game.cam_center.y,wall_point.x-game.cam_center.x)
	var expected=game.port_pos(angle)
	if not check(game.placement_preview.visible and game.placement_preview.kind=="glutport" and (game.placement_preview.position+game.placement_preview.size*.5).distance_to(expected)<.01,"The GLUT drag preview must reuse its toolbar icon and snap to the wall"):return
	game.toolbox_drag_kind=""
	game.placing="glutport"
	game.place_at(wall_point)
	if not check(game.ports.size()==ports_before+1 and game.ports[-1].p.distance_to(expected)<.01 and int(game.toolbox.get("glutport",0))==count-1,"GLUT placement must follow the HTML wall projection"):return
	var aa_count=int(game.toolbox.get("aaport",0))
	game.placing="aaport"
	game.place_at(game.cam_center+Vector2(-game.radius.x,0))
	if not check(game.ports[-1].type=="aa" and int(game.toolbox.get("aaport",0))==aa_count-1,"AA ports must use the same membrane placement rule"):return
	game.toolbox_drag_kind="mitochondrion"
	game.toolbox_drag_pos=game.cam_center+Vector2(24,15)
	game.update_placement_preview()
	if not check(game.placement_preview.visible and game.placement_preview.kind=="mitochondrion","Other parts must also use their toolbar artwork while placing"):return
	print("Toolbar placement: wall band, HTML port projection, and shared drag artwork passed")
	quit()
