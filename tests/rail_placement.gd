extends SceneTree

var game: Node

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, message: String) -> bool:
	if condition:return true
	push_error(message)
	quit(1)
	return false

func click(position: Vector2,button := MOUSE_BUTTON_LEFT) -> void:
	var event=InputEventMouseButton.new()
	event.button_index=button
	event.pressed=true
	event.position=position
	game._unhandled_input(event)

func run() -> void:
	game=load("res://main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.start_level(10)
	var initial=int(game.toolbox["microtubule"])
	game.select_tool("microtubule")
	if not check(game.placing=="microtubule" and game.rail_start.is_empty(),"Rail click should enter output selection"):return
	if not check(int(game.toolbox["microtubule"])==initial,"Selecting the rail should not consume it"):return
	click(game.cam_center)
	if not check(game.rail_start.is_empty(),"An empty spot cannot be a rail output"):return
	var golgi=game.org("golgi")
	click(golgi.p)
	if not check(game.rail_start==golgi,"First click should choose the output organelle"):return
	click(golgi.p)
	if not check(game.rails.is_empty() and game.rail_start==golgi,"Same organelle cannot receive its own rail"):return
	var edge=game.port_pos(.9)
	click(edge)
	if not check(game.rails.size()==1 and game.rails[0].rec.type=="membrane","Second click should connect to the membrane"):return
	if not check(game.rails[0].motors.size()==1 and game.rails[0].motors[0].starter,"Connected rail should include a starter motor"):return
	var rail=game.rails[0]
	var initial_motors=int(game.toolbox["motor"])
	game.select_tool("motor")
	game.place_at(game.rail_pos(rail,.5))
	if not check(rail.motors.size()==2 and not rail.motors[1].starter and int(game.toolbox["motor"])==initial_motors-1,"Adding a second motor should consume one toolbox item"):return
	var idle_position=game.rail_pos(rail,float(rail.motors[0].p))
	if not check(idle_position.distance_to(golgi.p)>20 and idle_position.distance_to(golgi.p)<=31.1,"Golgi rail and idle motor should start at its drawn edge"):return
	if not check(idle_position.distance_to(Vector2(rail.waypoints[0]))<.01,"Rail should begin at the source edge under the idle motor"):return
	if not check(int(game.toolbox["microtubule"])==initial-1 and game.placing.is_empty(),"Successful connection should consume one rail and exit connect mode"):return
	game.select_tool("microtubule")
	game.select_tool("microtubule")
	if not check(game.placing.is_empty(),"Clicking the rail tool again should cancel connect mode"):return
	game.select_tool("microtubule")
	click(game.cam_center,MOUSE_BUTTON_RIGHT)
	if not check(game.placing.is_empty(),"Right click should cancel connect mode"):return
	for kind in ["ribosome","er","mitochondrion","lysosome"]:
		var source=game.org(kind)
		var receiver={"type":"membrane","p":game.port_pos(.9)}
		var attached=game.make_rail(source,receiver)
		var expected=game.rail_source_edge(source,receiver.p)
		if not check(attached.motors.size()==1 and attached.motors[0].starter,"Every rail should start with its own motor"):return
		if not check(game.rail_pos(attached,float(attached.motors[0].p)).distance_to(expected)<.01,"Idle motor must begin on the edge of %s" % kind):return
	game.context_rail=0
	game.context_motor=0
	game.context_action(1)
	if not check(rail.motors.size()==1 and not rail.motors[0].starter and int(game.toolbox["motor"])==initial_motors-1,"Removing the starter motor must not refund it"):return
	game.context_rail=0
	game.context_motor=0
	game.context_action(1)
	if not check(rail.motors.is_empty() and int(game.toolbox["motor"])==initial_motors,"Removing an added motor should refund it"):return
	var rail_to_remove=game.make_rail(golgi,{"type":"membrane","p":game.port_pos(.8)})
	rail_to_remove.motors.append({"p":0.0,"state":"idle","cargo":{},"stalled":false,"starter":false})
	var before_refund=int(game.toolbox["motor"])
	game.context_rail=game.rails.find(rail_to_remove)
	game.context_motor=-1
	game.context_action(1)
	if not check(not game.rails.has(rail_to_remove) and int(game.toolbox["motor"])==before_refund+1,"Removing a rail should refund added motors only"):return
	print("Rail placement: included motor, output/receiver, inventory, and refund rules passed")
	quit()
