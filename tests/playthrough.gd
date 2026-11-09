extends SceneTree

# Headless objective playthrough for all 15 levels. Uses game actions and event ticks.
var game: Node

func _initialize() -> void:
 call_deferred("run")

func require(ok: bool, description: String) -> bool:
 if ok:return true
 push_error("Playthrough failed: "+description)
 quit(1)
 return false

func living(kind: String) -> Dictionary:
 for m in game.mols:
  if m.type==kind and not m.dead:return m
 return {}

func piece(kind: String) -> Dictionary:
 for m in game.mols:
  if m.type==kind and not m.dead:return m
 return {}

func ensure_insulin_template() -> bool:
 var rib=game.org("ribosome")
 if rib.get("gene","")!="s_ins" or rib.get("template",{}).is_empty():
  game.transcribe_gene("s_ins")
  var mrna: Dictionary={}
  for m in game.mols:
   if m.type=="mrna" and not m.dead and m.get("gene","")=="s_ins" and not m.get("bound",false):mrna=m
  if not require(not mrna.is_empty(),"nucleus transcribed insulin mRNA"):return false
  var original: Vector2=rib.p
  game.drop_mol(mrna,rib.p)
  if not require(rib.p==original and rib.get("state","")=="awaiting_er","mRNA loaded without teleporting ribosome"):return false
 if rib.get("state","")!="er_bound":game.attach_ribosome_to_er(rib,game.org("er"))
 return require(rib.get("gene","")=="s_ins" and rib.get("state","")=="er_bound","ribosome attaches to its ER section")

func make_vesicle() -> bool:
 var rib=game.org("ribosome")
 var er=game.org("er")
 var golgi=game.org("golgi")
 if not require(not rib.is_empty() and not er.is_empty() and not golgi.is_empty(),"secretory organelles exist"):return false
 for attempt in 8:
  if not ensure_insulin_template():return false
  for cls in 3:
   var aa=game.add_mol("aa",rib.p,true,{"cls":0})
   game.drop_mol(aa,rib.p)
  var protein=piece("protein")
  if not require(not protein.is_empty() and protein.get("gene","")=="s_ins","ribosome made insulin from its template"):return false
  if not require(protein.get("stage","")=="in_er" and protein.get("bound",false),"insulin enters rough ER during translation"):return false
  game.process_er_proteins(1.1)
  if protein.get("misfold",false):
   var lysosome=game.org("lysosome")
   if not require(not lysosome.is_empty(),"misfolded insulin can be recycled"):return false
   game.drop_mol(protein,lysosome.p)
   continue
  if not require(protein.get("stage","")=="folded","rough ER folded insulin"):return false
  game.drop_mol(protein,golgi.p)
  return require(not piece("vesicle").is_empty() and piece("vesicle").get("gene","")=="s_ins","Golgi preserved insulin cargo")
 return require(false,"healthy insulin synthesis succeeded after retry")

func export_one() -> bool:
 if not make_vesicle():return false
 var vesicle=piece("vesicle")
 game.drop_mol(vesicle,game.port_pos(1.0))
 return require(vesicle.dead,"vesicle fused at membrane")

func patch_one() -> bool:
 if game.cracks.is_empty():game.spawn_crack()
 var mito=game.org("mitochondrion")
 for i in 2:game.add_mol("o2",mito.p,true)
 game.add_mol("glucose",mito.p,true)
 game.burn_mito()
 game.add_mol("glucose",game.org("er").p,true)
 game.process_smooth_er(5.1)
 var lipid=piece("lipid")
 if not require(not lipid.is_empty(),"smooth ER made a lipid from intracellular glucose"):return false
 game.drop_mol(lipid,game.port_pos(float(game.cracks[0])))
 return require(lipid.dead,"lipid sealed a crack")

func complete_level(n: int) -> bool:
 game.check_win()
 return require(game.beaten.has(n),"level %d objective completes (ATP %.1f, ADP %.1f, made %d)" % [n,float(game.state.atp),float(game.state.adp),int(game.state.made)])

func gesture_drag(m: Dictionary, target: Vector2) -> void:
 var press=InputEventMouseButton.new()
 press.button_index=MOUSE_BUTTON_LEFT;press.pressed=true;press.position=m.p
 game._unhandled_input(press)
 var motion=InputEventMouseMotion.new()
 motion.position=target
 game._unhandled_input(motion)
 var release=InputEventMouseButton.new()
 release.button_index=MOUSE_BUTTON_LEFT;release.pressed=false;release.position=target
 game._unhandled_input(release)

func run() -> void:
 game=load("res://main.tscn").instantiate()
 root.add_child(game)
 await process_frame
 # Level 1: use the GLUT receptor, diffuse O2 in, recharge ADP five times.
 game.start_level(1)
 var glut: Dictionary={}
 for p in game.ports:
  if p.type=="glut":glut=p;break
 if not require(not glut.is_empty(),"GLUT port exists"):return
 for i in 5:
  for j in 2:
   var oxygen=game.add_mol("o2",glut.p+Vector2(30,0),false)
   game.drop_mol(oxygen,game.org("mitochondrion").p+Vector2(0,70))
  var glucose=game.add_mol("glucose",glut.p+Vector2(35,0),false)
  if i==0:gesture_drag(glucose,glut.p)
  else:game.drop_mol(glucose,glut.p)
  for step in 70:
   if glucose.inside:break
   game.process_molecules(.05)
  if not require(glucose.inside,"GLUT imports glucose"):return
  game.drop_mol(glucose,game.org("mitochondrion").p)
 if not complete_level(1):return
 # Level 2: assemble the first protein from three amino acids.
 game.start_level(2);game.state.atp=100.0
 game.show_genes()
 await process_frame
 var menu_rect: Rect2=game.overlay.get_global_rect()
 var screen_size: Vector2=game.get_viewport().get_visible_rect().size
 if not require(menu_rect.position.x>=0 and menu_rect.position.y>=0 and menu_rect.end.x<=screen_size.x and menu_rect.end.y<=screen_size.y,"gene menu fits on screen"):return
 game.close_overlay()
 var rib=game.org("ribosome")
 if not ensure_insulin_template():return
 for cls in 3:
  var aa=game.add_mol("aa",rib.p,true,{"cls":0})
  game.drop_mol(aa,rib.p)
 if not complete_level(2):return
 # Levels 3 to 5: export, recycle, then match enzyme colors.
 game.start_level(3);game.state.atp=100.0
 for i in 2:
  if not export_one():return
 if not complete_level(3):return
 game.start_level(4);game.state.atp=100.0
 var ly=game.org("lysosome")
 for m in game.mols.duplicate():
  if m.type=="waste" and not m.dead:game.drop_mol(m,ly.p)
 if not export_one():return
 if not complete_level(4):return
 game.start_level(5);game.state.atp=100.0
 for m in game.mols.duplicate():
  if m.type!="waste" or m.dead:continue
  for o in game.orgs:
   if o.type=="lysosome" and o.enzyme==m.sub:
    game.drop_mol(m,o.p)
    break
 if not export_one():return
 if not complete_level(5):return
 # Level 6: receptor relay and three timed threat bursts.
 game.start_level(6);game.state.atp=100.0
 var receptor: Dictionary={}
 for p in game.ports:
  if p.type=="rx":receptor=p;break
 var hormone=game.add_mol("hormone",receptor.p,false)
 game.drop_mol(hormone,receptor.p)
 for i in 930:game.process_level_events(.05)
 if not complete_level(6):return
 # Level 7: build a lipid vesicle for each membrane crack.
 game.start_level(7);game.state.atp=100.0
 for i in 5:
  if not patch_one():return
 if not complete_level(7):return
 # Level 8: quality control and three healthy exports.
 game.start_level(8);game.state.atp=100.0
 var bad=game.add_mol("protein",game.org("lysosome").p,true,{"raw":true,"misfold":true})
 game.state.misfold+=1
 game.drop_mol(bad,game.org("lysosome").p)
 for i in 3:
  if not export_one():return
 if not complete_level(8):return
 # Level 9: engulf and digest three oversized nutrient chunks.
 game.start_level(9);game.state.atp=100.0
 for i in 3:
  var chunk=game.add_mol("chunk",game.port_pos(.5)*1.0,false)
  game.drop_mol(chunk,game.port_pos(.5))
  var endo=piece("endoves")
  if not require(not endo.is_empty(),"chunk was engulfed"):return
  game.drop_mol(endo,game.org("lysosome").p)
 if not complete_level(9):return
 # Level 10: motor transport from Golgi to membrane.
 game.start_level(10);game.state.atp=100.0
 var transport_rail=game.make_rail(game.org("golgi"),{"type":"membrane","p":game.port_pos(.9)})
 game.select_tool("motor")
 game.place_at(game.rail_pos(transport_rail,.5))
 for i in 3:
  if not make_vesicle():return
  for step in 800:
   game.update_rails(.05)
   if game.state.exported>i:break
  if not require(game.state.exported>i,"motor delivered export %d" % (i+1)):return
 if not complete_level(10):return
 # Level 11: combined patching, viral cleanup and waste removal.
 game.start_level(11);game.state.atp=100.0
 for i in 3:
  if not patch_one():return
 for i in 4:
  var viral=game.add_mol("vrna",game.cam_center,true)
  game.drop_mol(viral,game.org("lysosome").p)
 for m in game.mols.duplicate():
  if m.type=="waste" and not m.dead:game.drop_mol(m,game.org("lysosome").p)
 if not complete_level(11):return
 # Level 12: stop eight viral parts before assembly.
 game.start_level(12);game.state.atp=100.0
 for i in 8:
  var viral=game.add_mol("vrna",game.cam_center,true)
  game.drop_mol(viral,game.org("lysosome").p)
 if not complete_level(12):return
 # Level 13: restore the ion gradient and let water rebalance passively.
 game.start_level(13);game.state.atp=100.0
 var osmotic_pump={}
 for port in game.ports:
  if port.type=="nak":osmotic_pump=port;break
 for molecule in game.mols:
  if molecule.type=="na" and molecule.inside:
   molecule.p=osmotic_pump.p+(game.cam_center-osmotic_pump.p).normalized()*28.0
 for i in 6:game.add_mol("k",osmotic_pump.p+Vector2(28,0),false)
 for i in 3:
  game.process_na_k_pumps(2.1)
 for i in 180:game.process_osmosis(.05)
 if not complete_level(13):return
 # Level 14: survive the full timer with incoming food and autophagy events.
 game.start_level(14);game.state.atp=100.0
 for i in 1801:
  game.process_level_events(.05)
  if game.overlay.visible:game.close_overlay()
 if not complete_level(14):return
 # Level 15: five hormone-triggered calcium waves.
 game.start_level(15);game.state.atp=100.0
 for p in game.ports:
  if p.type=="rx":receptor=p;break
 for i in 5:
  var hormone_mol=game.add_mol("hormone",receptor.p,false)
  game.drop_mol(hormone_mol,receptor.p)
 if not complete_level(15):return
 print("Inside Life: all 15 objectives completed through game actions")
 quit()
