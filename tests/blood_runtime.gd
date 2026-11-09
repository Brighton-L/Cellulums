extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var game=load("res://main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	seed(20260929)
	game.start_level(2)
	game.state.atp=1000.0
	var saw_oxygen=false
	var saw_nutrients=false
	var peak_oxygen=0
	var peak_exchange_oxygen=0
	var peak_glucose=0
	var peak_amino_acids=0
	for i in 2400:
		if i<800:
			game._process(.05)
		else:
			game.process_blood_flow(.05)
			game.process_molecules(.05)
		var oxygen=game.count_mol("o2")
		var glucose=game.count_mol("glucose")
		var amino_acids=game.count_mol("aa")
		saw_oxygen=saw_oxygen or oxygen>0
		saw_nutrients=saw_nutrients or glucose+amino_acids>0
		peak_oxygen=maxi(peak_oxygen,oxygen)
		peak_exchange_oxygen=maxi(peak_exchange_oxygen,game.local_extracellular_oxygen())
		peak_glucose=maxi(peak_glucose,glucose)
		peak_amino_acids=maxi(peak_amino_acids,amino_acids)
	if game.paused or not saw_oxygen or not saw_nutrients:
		push_error("Circulation must still deliver oxygen and plasma nutrients during normal gameplay")
		quit(1)
		return
	if peak_oxygen>40 or peak_exchange_oxygen>12 or peak_glucose>15 or peak_amino_acids>20:
		push_error("Reduced delivery should avoid large molecule buildup: peaks %d/%d/%d, local O2 %d" % [peak_oxygen,peak_glucose,peak_amino_acids,peak_exchange_oxygen])
		quit(1)
		return
	print("Blood runtime: 120 seconds of carrier movement and low-density resource delivery passed")
	quit()
