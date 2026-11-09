extends Node2D

# Inside Life: native Godot recreation of the supplied canvas game.
class ToolboxMini extends Control:
	var kind := ""
	var visual_font: Font

	func ellipse(center: Vector2, radii: Vector2, color: Color, filled := true, width := 1.0, rotation := 0.0) -> void:
		var points=PackedVector2Array()
		for i in 65:
			var angle=float(i)/64.0*TAU
			points.append(center+Vector2(radii.x*cos(angle),radii.y*sin(angle)).rotated(rotation))
		if filled:draw_colored_polygon(points,color)
		else:draw_polyline(points,color,width,true)

	func curve(a: Vector2, control: Vector2, b: Vector2, color: Color, width: float) -> void:
		var points=PackedVector2Array()
		for i in 13:
			var t=float(i)/12.0
			points.append(a*pow(1.0-t,2)+control*2.0*(1.0-t)*t+b*t*t)
		draw_polyline(points,color,width,true)

	func ring(center: Vector2, radius: float, color: Color, width := 2.0) -> void:
		draw_arc(center,radius,0,TAU,48,color,width,true)

	func _draw() -> void:
		var p=size*0.5
		var scale_factor=minf(size.x,size.y)/92.0
		var drawing_font=visual_font if visual_font else ThemeDB.fallback_font
		match kind:
			"mitochondrion":
				ellipse(p,Vector2(36,22)*scale_factor,Color("#7a3a3e"),true,1.0,.4)
				ellipse(p,Vector2(36,22)*scale_factor,Color("#c86a6a"),false,2*scale_factor,.4)
				for i in 3:
					var y=(i-1)*8-8
					curve(p+Vector2(-16,y)*scale_factor,p+Vector2(0,y+11)*scale_factor,p+Vector2(16,y)*scale_factor,Color("#c86a6a",.7),2*scale_factor)
			"ribosome":
				for i in 3:
					var q=p+Vector2((i-1)*11,(i%2)*7)*scale_factor
					draw_circle(q,7*scale_factor,Color("#6a5a8e"))
					ring(q,7*scale_factor,Color("#9a8abe"),1.5*scale_factor)
			"er":
				ellipse(p,Vector2(44,24)*scale_factor,Color("#3a5e3e"),true,1.0,.6)
				ellipse(p,Vector2(44,24)*scale_factor,Color("#7ac87a"),false,2*scale_factor,.6)
				for i in 5:
					var j=i-2
					curve(p+Vector2(-30+j*4,j*7-4)*scale_factor,p+Vector2(j*2,j*7+8)*scale_factor,p+Vector2(30+j*4,j*7-4)*scale_factor,Color("#7ac87a",.5),scale_factor)
			"golgi":
				for i in 4:
					var q=p+Vector2(0,i*7-10)*scale_factor
					var radii=Vector2(30-i*4,9)*scale_factor
					ellipse(q,radii,Color("#5e4a2e"),true,1.0,.15)
					ellipse(q,radii,Color("#d8b86a"),false,1.5*scale_factor,.15)
			"lysosome":
				draw_circle(p,22*scale_factor,Color("#4e2e2e"))
				ring(p,22*scale_factor,Color("#c87a5a"),2*scale_factor)
				draw_string(drawing_font,p+Vector2(0,4)*scale_factor,"pH 5",HORIZONTAL_ALIGNMENT_CENTER,-1,10*scale_factor,Color("#c87a5a"))
			"microtubule","motor":
				draw_line(p+Vector2(-26,14)*scale_factor,p+Vector2(26,-14)*scale_factor,Color("#9ad0ff",.3),9*scale_factor)
				draw_line(p+Vector2(-26,14)*scale_factor,p+Vector2(26,-14)*scale_factor,Color("#9ad0ff"),3*scale_factor)
				if kind=="motor":
					draw_circle(p,10*scale_factor,Color("#ffd166"));ring(p,10*scale_factor,Color.WHITE,1.5*scale_factor)
			"glutport","aaport","ca2port","rxport","nakport","aquaport":
				var fill=Color("#7ec8e8") if kind=="aquaport" else (Color("#ffd76a") if kind=="glutport" else (Color("#e06a8a") if kind=="aaport" else (Color("#ffe066") if kind=="ca2port" else (Color("#e8a05a") if kind=="nakport" else Color("#7ee89b")))))
				draw_circle(p,19*scale_factor,fill);ring(p,19*scale_factor,Color(1,1,1,.5),1.5*scale_factor)
				var label="H₂O" if kind=="aquaport" else ("G" if kind=="glutport" else ("A" if kind=="aaport" else ("Ca" if kind=="ca2port" else ("Na" if kind=="nakport" else "R"))))
				draw_string(ThemeDB.fallback_font,p+Vector2(-7,7)*scale_factor,label,HORIZONTAL_ALIGNMENT_LEFT,-1,20*scale_factor,Color("#2e2418"))
			"erchaperone":
				ellipse(p,Vector2(37,21)*scale_factor,Color("#3a5e3e"),true,1.0,.6)
				ellipse(p,Vector2(37,21)*scale_factor,Color("#7ac87a"),false,2*scale_factor,.6)
				draw_string(drawing_font,p+Vector2(-13,7)*scale_factor,"CH",HORIZONTAL_ALIGNMENT_LEFT,-1,18*scale_factor,Color("#e9f3d5"))
			_:
				draw_string(ThemeDB.fallback_font,p+Vector2(-14,4)*scale_factor,kind.substr(0,4),HORIZONTAL_ALIGNMENT_LEFT,-1,11*scale_factor,Color("#8aa0c0"))

const BG = Color("#FFE7B8")
const CELL_INNER = Color("#F6CF91")
const CELL_WALL = Color("#DF9A5F")
const GOLD = Color("#ffd76a")
const TEXT = Color("#c8d6e8")
const MUTED = Color("#8aa0c0")
const LEVELS = [
	{"title":"Level 1 - Keep Alive","objective":"Cell work burns ATP (building, folding, packaging all cost ATP). Drag glucose through a GLUT transporter (yellow port) and let O2 diffuse in. Reach 40 ATP.","tip":"Plasma brings glucose to the yellow GLUT port. Red blood cells release O₂, which diffuses into the cell.","goal":"atp","amount":40,"spawn":{"glucose":6,"o2":5},"org":["nucleus","mitochondrion"]},
	{"title":"Level 2 - Building Blocks","objective":"Transcribe insulin mRNA, load a ribosome, drag that ribosome onto ER, then feed it 3 amino acids.","tip":"Plasma brings AAs to the pink port. Load insulin mRNA into the ribosome, attach it to ER, then feed it 3 AAs.","goal":"made","amount":1,"spawn":{"glucose":4,"o2":4,"aa":4},"org":["nucleus","mitochondrion","ribosome","er"]},
	{"title":"Level 3 - The Factory","objective":"Produce and EXPORT 2 insulin proteins: mRNA to ER-bound ribosome, rough ER folding, Golgi, vesicle, membrane.","tip":"Attach the loaded ribosome to ER. Translation feeds insulin into it; after folding, move the cargo to Golgi and the vesicle to membrane.","goal":"exported","amount":2,"spawn":{"glucose":5,"o2":5,"aa":9},"org":["nucleus","mitochondrion","ribosome","er","golgi"]},
	{"title":"Level 4 - Garbage Day","objective":"A folding error dumped 5 damaged proteins. Digest them in the lysosome (lingering waste drains ATP), then export 1 more insulin.","tip":"Drag waste onto the lysosome to recycle amino acids. Transcribe insulin mRNA at the nucleus before making the next protein.","goal":"cleanup","amount":1,"spawn":{"glucose":4,"o2":4},"org":["nucleus","mitochondrion","ribosome","er","golgi","lysosome"]},
	{"title":"Level 5 - Enzyme Keys","objective":"Waste now comes in three flavors (protein/sugar/lipid), each color-coded. Drag each waste piece to the MATCHING-color lysosome: red digests protein, blue digests sugar, gold digests lipid. Clear all 6 waste, then export 1 insulin.","tip":"Look at the waste color, find the lysosome ringed in the same color, drag it there. Wrong lysosome = refused.","goal":"cleanup","amount":1,"mode":"enz","spawn":{"glucose":4,"o2":4,"aa":3},"org":["nucleus","mitochondrion","ribosome","er","golgi"]},
	{"title":"Level 6 - Signal Relay","objective":"Threat bursts hit faster than your base cell can work. Adrenaline (green) cannot enter - dock it at the receptor (green port). The relay to the nucleus triggers ALERT MODE: 2x ATP, 2x import speed for 20s. Survive 3 bursts with waste kept low.","tip":"Time your adrenaline relays so alert mode covers each waste burst. Watch the nucleus glow gold while alerted.","goal":"bursts","amount":3,"mode":"signal","spawn":{"glucose":4,"o2":4,"aa":3,"hormone":2},"org":["nucleus","mitochondrion","ribosome","er","golgi","lysosome"]},
	{"title":"Level 7 - Membrane Patch","objective":"Smooth ER turns intracellular glucose and ATP into lipids. Drag lipids onto membrane cracks to seal 5.","tip":"Keep glucose coming through GLUT. A smooth ER section consumes glucose and ATP to make lipids for repair, vesicles, and growth.","goal":"patched","amount":5,"mode":"patch","spawn":{"glucose":8,"o2":10,"aa":2},"org":["nucleus","mitochondrion","ribosome","er","golgi","lysosome"]},
	{"title":"Level 8 - ER Quality Control","objective":"Rough ER folding may reject a damaged protein (red rim). Export 3 healthy insulin proteins and recycle every rejected chain.","tip":"Attach the loaded ribosome to ER. Healthy folded insulin goes to Golgi; rejected red-rim proteins go to lysosome. ER chaperones improve one section's folding.","goal":"qc","amount":3,"mode":"qc","spawn":{"glucose":5,"o2":5,"aa":12},"org":["nucleus","mitochondrion","ribosome","er","golgi","lysosome"]},
	{"title":"Level 9 - Endocytosis","objective":"Big nutrient chunks (gold) drift by outside - too large for any transporter. Press one against the membrane to engulf it, then digest the endocytic vesicle in the lysosome. Digest 3 chunks.","tip":"Drag a chunk onto the membrane edge - the cell swallows it whole. Then vesicle (gold) to lysosome: +3 glucose +2 AAs.","goal":"engulfed","amount":3,"mode":"endo","spawn":{"glucose":3,"o2":4,"chunk":2},"org":["nucleus","mitochondrion","ribosome","er","golgi","lysosome"]},
	{"title":"Level 10 - Cytoskeleton Highways","objective":"Export 3 insulin - vesicles only move by motor protein. Place a Microtubule (click Golgi, then membrane), stick a Motor Protein on the rail, and the Golgi hands vesicles to the motor for delivery (costs ATP).","tip":"Motor mRNA on a free ribosome makes a Motor Protein for your toolbox. Place it on the rail you choose.","goal":"exported","amount":3,"mode":"rail","spawn":{"glucose":5,"o2":5,"aa":9},"org":["nucleus","mitochondrion","ribosome","er","golgi","lysosome"]},
	{"title":"Level 11 - Combined Stress","objective":"Everything at once: typed waste bursts, cracking membrane, and a virus running at half speed. Patch 3 cracks, keep waste clear, and destroy 4 viral parts.","tip":"Use adrenaline relays (green hormone still spawns) for 2x speed when the bursts stack up.","goal":"chaos","amount":4,"mode":"chaos","spawn":{"glucose":4,"o2":4,"aa":4,"hormone":2},"org":["nucleus","mitochondrion","ribosome","er","golgi","lysosome"]},
	{"title":"Level 12 - Virus Attack","objective":"FINAL BOSS. A virus injected its RNA: every ~8s it hijacks a ribosome to build a capsomer from your amino acids. Destroy 8 viral parts (red RNA / orange capsomers) in the lysosome before 10 accumulate.","tip":"Drag viral parts onto the lysosome (1 ATP each). Replace stolen AAs by recycling waste. Keep ATP up.","goal":"killed","amount":8,"mode":"virus","spawn":{},"org":["nucleus","mitochondrion","ribosome","er","golgi","lysosome"]},
	{"title":"Chapter 2 - Level 13: Osmotic Crisis","objective":"Restore the salt balance before the cell swells. Na⁺/K⁺ pumps exchange 3 Na⁺ inside for 2 K⁺ outside using 1 ATP; water then leaves passively through aquaporins.","tip":"Keep ATP available and watch the pump beside the incoming K⁺ supply. Water follows the solute gradient without spending ATP.","goal":"osmotic_stable","amount":1,"mode":"osmosis","spawn":{"glucose":6,"o2":5},"org":["nucleus","mitochondrion","ribosome","er","golgi","lysosome"]},
	{"title":"Chapter 2 - Level 14: Starvation","objective":"Fasting makes plasma glucose scarce. Recycle your own organelle fragments (autophagy waste) in the lysosome and stay alive (ATP>0) for 90 seconds.","tip":"Watch for rare glucose from plasma packets. Recycle autophagy waste in the lysosome for more fuel.","goal":"survived","amount":90,"mode":"starve","spawn":{},"org":["nucleus","mitochondrion","ribosome","er","golgi","lysosome"]},
	{"title":"Level 15 - Calcium Spark","objective":"Hormones keep arriving. Each time one docks the green receptor, a signal relays to the nucleus AND gold Ca2+ channels open 3 seconds - a calcium SPARK floods in. Then the cell pumps Ca2+ back out (1 ATP each) to keep cytosol low. Trigger 5 sparks.","tip":"Drag adrenaline onto the GREEN receptor or the gold Ca2+ channel port. Sparks auto-fire on relay; pumping is automatic. Keep glucose/O2 flowing so ATP does not run dry.","goal":"waves","amount":5,"mode":"ca2","spawn":{"glucose":5,"o2":5,"hormone":4},"org":["nucleus","mitochondrion","ribosome","er","golgi","lysosome"]}
]
const GENES = {
	"s_ins":{"name":"Insulin","group":"Beginning","ribosome":"er_bound","needs_er":true,"needs_golgi":true,"transport":"vesicle","destination":"outside","product":"insulin","desc":"Secreted from the cell after ER and Golgi processing."},
	"m_glut":{"name":"GLUT transporter","group":"Beginning","ribosome":"er_bound","needs_er":true,"needs_golgi":true,"transport":"toolbox","destination":"membrane","product":"glut","toolbox_item":"glutport","ready_at":"golgi","desc":"After Golgi packaging, a placeable GLUT port enters the toolbox."},
	"m_aa":{"name":"AA transporter","group":"Beginning","ribosome":"er_bound","needs_er":true,"needs_golgi":true,"transport":"toolbox","destination":"membrane","product":"aa","toolbox_item":"aaport","ready_at":"golgi","desc":"After Golgi packaging, a placeable AA port enters the toolbox."},
	"c_motor":{"name":"Motor protein","group":"Beginning","ribosome":"free","needs_er":false,"needs_golgi":false,"transport":"cytosol","destination":"microtubule","product":"motor","toolbox_item":"motor","ready_at":"translation","desc":"A free ribosome makes a placeable rail motor."},
	"l_enzyme":{"name":"Lysosomal enzyme","group":"Protein Processing","ribosome":"er_bound","needs_er":true,"needs_golgi":true,"transport":"vesicle","destination":"lysosome","product":"lysosomal_enzyme","enzyme_class":"protein","desc":"A protein-digesting enzyme sent through Golgi to a lysosome."},
	"e_chaperone":{"name":"ER chaperone","group":"Protein Processing","ribosome":"er_bound","needs_er":true,"needs_golgi":false,"transport":"er","destination":"er","product":"chaperone","toolbox_item":"erchaperone","ready_at":"er","desc":"After ER folding, place it in an ER section of your choice."},
	"c_proteasome":{"name":"Proteasome component","group":"Protein Processing","ribosome":"free","needs_er":false,"needs_golgi":false,"transport":"cytosol","destination":"cytoplasm","product":"proteasome","desc":"Supports degradation of damaged cytosolic proteins."},
	"m_nak":{"name":"Na⁺/K⁺ pump","group":"Homeostasis","ribosome":"er_bound","needs_er":true,"needs_golgi":true,"transport":"vesicle","destination":"membrane","product":"nak","toolbox_item":"nakport","ready_at":"membrane","desc":"Vesicle fusion makes a placeable sodium pump."},
	"m_ion":{"name":"Ca²⁺ channel","group":"Homeostasis","ribosome":"er_bound","needs_er":true,"needs_golgi":true,"transport":"vesicle","destination":"membrane","product":"ca","toolbox_item":"ca2port","ready_at":"membrane","desc":"Vesicle fusion makes a placeable calcium channel."},
	"m_rx":{"name":"Receptor","group":"Homeostasis","ribosome":"er_bound","needs_er":true,"needs_golgi":true,"transport":"vesicle","destination":"membrane","product":"rx","toolbox_item":"rxport","ready_at":"membrane","desc":"Vesicle fusion makes a placeable adrenaline receptor."},
	"c_repair":{"name":"Membrane repair protein","group":"Stress / Advanced","ribosome":"free","needs_er":false,"needs_golgi":false,"transport":"cytosol","destination":"crack","product":"repair","desc":"Stabilizes a tear. Combine with lipid to seal a large rupture."},
	"c_antiox":{"name":"Antioxidant enzyme","group":"Stress / Advanced","ribosome":"free","needs_er":false,"needs_golgi":false,"transport":"cytosol","destination":"cytoplasm","product":"antioxidant","desc":"Works in the cytoplasm to reduce oxidative damage."},
	"n_dna_repair":{"name":"DNA repair protein","group":"Stress / Advanced","ribosome":"free","needs_er":false,"needs_golgi":false,"transport":"cytosol","destination":"nucleus","product":"dna_repair","desc":"Made in the cytoplasm, then imported into the nucleus."}
}
const GENE_GROUPS = ["Beginning","Protein Processing","Homeostasis","Stress / Advanced"]
const GENE_UNLOCK_LEVELS = {"Beginning":1,"Protein Processing":4,"Homeostasis":11,"Stress / Advanced":12}
const TRANSCRIPTION_COST := 2
const MRNA_TRANSLATIONS := 4
const RADII = {"glucose":8,"o2":6,"co2":6,"aa":10,"mrna":8,"protein":9,"exported_protein":9,"vesicle":13,"waste":8,"hormone":9,"lipoves":12,"chunk":16,"endoves":14,"water":5,"vrna":9,"capsomer":7,"ca":5,"na":5,"k":5,"lipid":8}
const GAS_HITBOX = {"o2":Vector2(12.5,5.0),"co2":Vector2(20.0,5.0)}
const COLORS = {"glucose":"#e8b04a","o2":"#5aa8e8","co2":"#9aa0a6","aa":"#e06a8a","mrna":"#8ab8e8","protein":"#8ae0c8","exported_protein":"#8ae0c8","vesicle":"#ffd76a","waste":"#8a7a8c","hormone":"#7ee89b","lipoves":"#c8a2e8","chunk":"#d8c86a","endoves":"#d8b86a","water":"#7ec8e8","vrna":"#e85a5a","capsomer":"#e8a05a","ca":"#ffe066","na":"#e88a5a","k":"#a86ae8","lipid":"#c8a2e8"}
const TEX_PATHS = {"glucose":"Glucose","o2":"O2","co2":"CO2","aa":"AminoAcid","mrna1":"MRNA-1U","mrna2":"MRNA-2U","mrna3":"MRNA-3U","mrna4":"MRNA-4U","vrna":"ViralRNA","virus":"ViralRNA","atp":"ATP","adp":"ADP","waste":"Waste4","lipoves":"Lipid","lipid":"Lipid"}
const MRNA_DRAW_SIDE := 52.8
const MRNA_SLOT_SIZE := Vector2(14.0,30.0)
const MRNA_SLOT_OFFSET := Vector2(29.0,3.0)
const CAPILLARY_IMAGE_SIZE := 512.0
const BLOOD_EXCHANGE_START := 0.42
const BLOOD_EXCHANGE_END := 0.62
const RBC_CO2_CAPTURE_RADIUS := 84.0
const RBC_CO2_CAPTURE_SECONDS := 0.42
const DEMAND_SAMPLE_SECONDS := 5.0
const DEMAND_SMOOTHING_SECONDS := 35.0
const DEMAND_STOCK_SECONDS := 30.0
const RESOURCE_STOCK_FLOORS := {"glucose":3.0,"aa":4.0,"o2":3.0}
const PORT_BASE_CAPTURE_RADIUS := 46.0
const PORT_BASE_PULL_STRENGTH := 90.0
const PORT_DOCK_SECONDS := 0.20
const PORT_TRANSLOCATE_SECONDS := 0.28
const ORG_POS = {"nucleus":Vector2(0,-0.42),"mitochondrion":Vector2(-0.5,0.30),"ribosome":Vector2(0.44,-0.46),"er":Vector2(0.62,0.12),"golgi":Vector2(0.28,0.55),"lysosome":Vector2(-0.48,-0.55)}
const OPENING_GUIDE = [
	{"event":"glucose_imported","focus":"glut","title":"GLUT transporter","explain":"GLUT brings glucose into the cell.","action":"Guide glucose to a yellow GLUT port."},
	{"event":"oxygen_entered","focus":"o2","title":"Oxygen","explain":"O₂ diffuses through the membrane.","action":"Let an O₂ molecule enter the cell."},
	{"event":"atp_made","focus":"mitochondrion","title":"Mitochondrion","explain":"Glucose and O₂ recharge ADP into ATP.","action":"Bring glucose to the mitochondrion."},
	{"event":"insulin_transcribed","focus":"nucleus","title":"Nucleus","explain":"DNA holds the insulin instruction.","action":"Open the nucleus; transcribe insulin mRNA."},
	{"event":"insulin_loaded","focus":"mrna","title":"mRNA template","explain":"The mRNA tells a ribosome what to build.","action":"Drop insulin mRNA onto a ribosome."},
	{"event":"ribosome_attached","focus":"er","title":"Rough ER","explain":"An ER-bound ribosome makes secreted proteins.","action":"Drag the loaded ribosome onto the ER."},
	{"event":"aa_supplied","focus":"aa","title":"Amino acids","explain":"A ribosome needs three amino acids.","action":"Feed amino acids to the loaded ribosome."},
	{"event":"insulin_synthesized","focus":"ribosome","title":"Protein synthesis","explain":"The template directs insulin production.","action":"Complete the three-amino-acid chain."},
	{"event":"insulin_folded","focus":"er","title":"ER processing","explain":"The rough ER folds the new insulin.","action":"Let the ER finish processing it."},
	{"event":"insulin_packaged","focus":"golgi","title":"Golgi processing","explain":"The Golgi packages folded insulin.","action":"Bring the folded protein to the Golgi."},
	{"event":"vesicle_transport","focus":"vesicle","title":"Transport vesicle","explain":"The vesicle carries insulin to the wall.","action":"Pick up the vesicle and move it outward."},
	{"event":"insulin_exported","focus":"membrane","title":"Export insulin","explain":"A vesicle fuses with the membrane.","action":"Deliver the insulin vesicle to the wall."}
]
const MECHANIC_SEQUENCE = ["waste","enzymes","signal","repair","quality","endocytosis","rails","combined","virus","homeostasis","osmosis","calcium"]
var textures: Dictionary = {}
var capillary_bottom: Texture2D
var capillary_top: Texture2D
var blood_cell_texture: Texture2D
var plasma_packet_texture: Texture2D
var capillary_mask: Image
var capillary_top_mask: Image
var capillary_path: Array[Vector2] = []
var capillary_distances: Array[float] = []
var capillary_length := 0.0
var capillary_viewport_size := Vector2.ZERO
var blood_carriers: Array[Dictionary] = []
var blood_flow_multiplier := 1.0
var blood_glucose_concentration := 1.0
var blood_aa_concentration := 1.0
var oxygen_demand_multiplier := 1.0
var body_state := "baseline"
var body_event_timer := 65.0
var body_event_index := 0
var red_cell_timer := 0.0
var plasma_timer := 0.0
var consumption_pending := {"glucose":0.0,"aa":0.0,"o2":0.0}
var predicted_use_rate := {"glucose":0.0,"aa":0.0,"o2":0.0}
var demand_sample_elapsed := 0.0
var level := 1
var continuous_mode := false
var opening_complete := false
var guide_active := false
var guide_steps: Array[Dictionary] = []
var guide_index := 0
var guide_source := ""
var learning_events: Dictionary = {}
var active_mechanics: Array[String] = []
var completed_mechanics: Array[String] = []
var next_mechanic_index := 0
var free_play_time := 0.0
var guide_delay := 55.0
var state: Dictionary = {}
var mols: Array[Dictionary] = []
var orgs: Array[Dictionary] = []
var ports: Array[Dictionary] = []
var cracks: Array[float] = []
var crack_data: Dictionary = {}
var rails: Array[Dictionary] = []
var goals: Array[Dictionary] = []
var toolbox: Dictionary = {}
var ups: Dictionary = {}
var dragging: Dictionary = {}
var drag_offset := Vector2.ZERO
var molecule_drag_press := Vector2.ZERO
var molecule_drag_moved := false
var ribosome_drag: Dictionary = {}
var ribosome_press := Vector2.ZERO
var ribosome_moved := false
var placing := ""
var rail_start: Dictionary = {}
var paused := false
var mode := ""
var elapsed := 0.0
var spawn_timer := 0.0
var pack_timer := 0.0
var toast_time := 0.0
var toast_text := ""
var overlay: PanelContainer
var overlay_margin: MarginContainer
var ui: CanvasLayer
var hud: Label
var title_label: Label
var goal_label: Label
var toolbox_panel: PanelContainer
var toolbox_row: HBoxContainer
var toast_label: Label
var overlay_body: VBoxContainer
var cam_center := Vector2.ZERO
var radius := Vector2.ZERO
var font: Font
var bold_font: Font
var max_unlocked := 1
var beaten: Array = []
var campaign := false
var campaign_chain := 1
var rail_tick := 0.0
var toolbox_signature := ""
var goal_row: HBoxContainer
var goal_widgets: Array[Dictionary] = []
var goal_panels: Array[PanelContainer] = []
var goal_done_count := 0
var hud_widgets: Dictionary = {}
var inspect_panel: PanelContainer
var inspect_heading: Label
var inspect_description: Label
var context_menu: PopupMenu
var context_org: Dictionary = {}
var context_rail := -1
var context_motor := -1
var pause_button: Button
var level_button: Button
var toolbox_drag_kind := ""
var toolbox_drag_start := Vector2.ZERO
var toolbox_drag_pos := Vector2.ZERO
var placement_preview: ToolboxMini
var pack_rolls: Dictionary = {}
var pack_menu_open := false
var relay_dots: Array[Dictionary] = []
var pops: Array[Dictionary] = []
var park_label: Label

func _ready() -> void:
	randomize()
	for key in TEX_PATHS:
		textures[key] = load("res://textures/%s.png" % TEX_PATHS[key])
	for i in 4:textures["waste%d" % (i+1)] = load("res://textures/Waste%d.png" % (i+1))
	capillary_bottom=load("res://textures/Capilary-Bottom.png")
	capillary_top=load("res://textures/Capilary-Top.png")
	blood_cell_texture=load("res://textures/BloodCell.png")
	plasma_packet_texture=load("res://textures/PlasmaPacket.png")
	build_capillary_path()
	var source_font=SystemFont.new()
	source_font.font_names=PackedStringArray(["Georgia","Times New Roman"])
	font=source_font
	var heavy_font=SystemFont.new()
	heavy_font.font_names=PackedStringArray(["Georgia","Times New Roman"])
	heavy_font.font_weight=700
	bold_font=heavy_font
	var save = ConfigFile.new()
	if save.load("user://inside_life_progress.cfg") == OK:
		max_unlocked = clampi(int(save.get_value("progress","max",1)),1,15)
		beaten = save.get_value("progress","beaten",[])
	make_ui()
	start_continuous()
	capillary_viewport_size=get_viewport_rect().size
	get_viewport().size_changed.connect(_on_resize)

func _on_resize() -> void:
	var old_c = cam_center
	var old_r = radius
	var old_capillary_rect=capillary_rect_for_size(capillary_viewport_size)
	dimensions()
	var new_capillary_rect=capillary_rect()
	if old_r.x > 0:
		for m in mols:
			var cap_state=str(m.get("cap_state",""))
			if cap_state in ["incoming_under","co2_descend","co2_return"]:
				m.p=capillary_point(float(m.get("cap_progress",0.0)))
			elif cap_state=="incoming_eject":
				m.cap_origin=capillary_point(float(m.get("cap_progress",.5)))
				m.p=m.cap_origin
				m.cap_target=capillary_eject_target(m)
				var t=clampf(float(m.get("cap_time",0.0))/.7,0.0,1.0)
				m.p=Vector2(m.cap_origin).lerp(Vector2(m.cap_target),1.0-pow(1.0-t,2))
			elif cap_state=="co2_suck":
				m.cap_origin=remap_capillary_position(Vector2(m.cap_origin),old_capillary_rect,new_capillary_rect)
				var t=clampf(float(m.get("cap_time",0.0))/.35,0.0,1.0)
				m.p=Vector2(m.cap_origin).lerp(capillary_point(.5),t*t*(3.0-2.0*t))
			elif cap_state=="co2_wait":
				m.p=co2_exchange_edge()
			elif cap_state=="co2_rbc_capture":
				m.cap_origin=remap_capillary_position(Vector2(m.cap_origin),old_capillary_rect,new_capillary_rect)
				var carrier: Dictionary=m.get("rbc_carrier",{})
				if not carrier.is_empty():
					var t=clampf(float(m.get("cap_time",0.0))/RBC_CO2_CAPTURE_SECONDS,0.0,1.0)
					m.p=Vector2(m.cap_origin).lerp(capillary_point(float(carrier.progress)),t*t*(3.0-2.0*t))
			elif cap_state=="co2_plasma_absorb":
				m.cap_origin=remap_capillary_position(Vector2(m.cap_origin),old_capillary_rect,new_capillary_rect)
				var t=clampf(float(m.get("cap_time",0.0))/.45,0.0,1.0)
				m.p=Vector2(m.cap_origin).lerp(capillary_point(.5),t*t*(3.0-2.0*t))
			elif m.get("cap_arrived",false) and not m.inside and old_capillary_rect.grow(90.0).has_point(m.p):
				m.p=remap_capillary_position(Vector2(m.p),old_capillary_rect,new_capillary_rect)
				var clearance=float(RADII.get(str(m.type),8))+2.0
				if capillary_blocked(m.p,clearance):
					m.p=capillary_point(.5)
					m.p=capillary_eject_target(m)
			else:
				m.p = cam_center + Vector2((m.p.x-old_c.x)*radius.x/old_r.x,(m.p.y-old_c.y)*radius.y/old_r.y)
		for o in orgs:
			o.p = cam_center + Vector2((o.p.x-old_c.x)*radius.x/old_r.x,(o.p.y-old_c.y)*radius.y/old_r.y)
			if o.has("home_p"):
				var home: Vector2=o.home_p
				o.home_p=cam_center+Vector2((home.x-old_c.x)*radius.x/old_r.x,(home.y-old_c.y)*radius.y/old_r.y)
			var template: Dictionary=o.get("template",{})
			if not template.is_empty():template.p=mrna_slot_pos(o)
		for rib in orgs:
			if rib.type!="ribosome" or rib.get("state","")!="er_bound":continue
			var er: Dictionary=rib.get("bound_er",{})
			if er.is_empty():continue
			rib.p=Vector2(er.p)+Vector2(rib.get("attach_offset",Vector2(-34,-26)))
			var bound_template: Dictionary=rib.get("template",{})
			if not bound_template.is_empty():bound_template.p=mrna_slot_pos(rib)
		for p in ports:
			p.p = port_pos(p.a)
		for r in rails:rebuild_rail_path(r)
	toolbox_signature=""
	capillary_viewport_size=get_viewport_rect().size
	update_placement_preview()
	update_ui()
	if pack_menu_open:render_pack_menu()
	queue_redraw()

func dimensions() -> void:
	var v = get_viewport_rect().size
	cam_center = Vector2(v.x/2.0,96.0+(v.y-96.0)/2.0+20.0)
	radius = Vector2(v.x*0.32,minf((v.y-96.0)*0.42,275.0))*(1.0+.015*float(state.get("membrane_growth",0)))

func in_cell(p: Vector2) -> bool:
	return pow((p.x-cam_center.x)/radius.x,2)+pow((p.y-cam_center.y)/radius.y,2)<1.0
func edge_ratio(p: Vector2) -> float:
	return Vector2((p.x-cam_center.x)/radius.x,(p.y-cam_center.y)/radius.y).length()
func membrane_drag_limit(m: Dictionary,target: Vector2) -> Vector2:
	var start: Vector2=m.p
	var a=Vector2((start.x-cam_center.x)/radius.x,(start.y-cam_center.y)/radius.y)
	var b=Vector2((target.x-cam_center.x)/radius.x,(target.y-cam_center.y)/radius.y)
	var d=b-a
	var hit=target
	var crossed=false
	var qa=d.dot(d)
	if qa>0.000001:
		var qb=2.0*a.dot(d)
		var qc=a.dot(a)-1.0
		var discriminant=qb*qb-4.0*qa*qc
		if discriminant>=0.0:
			var root=sqrt(discriminant)
			var first=(-qb-root)/(2.0*qa)
			var second=(-qb+root)/(2.0*qa)
			var crossing=second if m.inside else first
			if crossing>=0.0 and crossing<=1.0:
				hit=start.lerp(target,crossing)
				crossed=true
	var radial=Vector2((hit.x-cam_center.x)/radius.x,(hit.y-cam_center.y)/radius.y)
	if radial.length_squared()<0.000001:radial=Vector2.RIGHT
	radial=radial.normalized()
	var edge=cam_center+Vector2(radial.x*radius.x,radial.y*radius.y)
	var normal=Vector2(radial.x/radius.x,radial.y/radius.y).normalized()
	var clearance=float(RADII.get(str(m.type),8))+2.0
	if not crossed:
		var signed_distance=(target-edge).dot(normal)
		if m.inside and signed_distance<=-clearance:return target
		if not m.inside and signed_distance>=clearance:return target
	return edge+normal*(-clearance if m.inside else clearance)
func capillary_pixel_solid(p: Vector2) -> bool:
	if capillary_mask==null:return false
	var rect=capillary_rect()
	if not rect.has_point(p):return false
	var x=clampi(int((p.x-rect.position.x)*CAPILLARY_IMAGE_SIZE/rect.size.x),0,capillary_mask.get_width()-1)
	var y=clampi(int((p.y-rect.position.y)*CAPILLARY_IMAGE_SIZE/rect.size.y),0,capillary_mask.get_height()-1)
	return capillary_mask.get_pixel(x,y).a>.25 or (capillary_top_mask!=null and capillary_top_mask.get_pixel(x,y).a>.25)
func capillary_blocked(p: Vector2,clearance: float) -> bool:
	var rect=capillary_rect().grow(clearance)
	if not rect.has_point(p):return false
	if capillary_pixel_solid(p):return true
	for i in 12:
		var angle=TAU*float(i)/12.0
		if capillary_pixel_solid(p+Vector2(cos(angle),sin(angle))*clearance):return true
	return false
func capillary_clear_point(p: Vector2,clearance: float,inside: bool) -> Vector2:
	for distance in range(4,161,4):
		for i in 16:
			var angle=TAU*float(i)/16.0
			var candidate=p+Vector2(cos(angle),sin(angle))*float(distance)
			if in_cell(candidate)==inside and not capillary_blocked(candidate,clearance):return candidate
	return p
func capillary_motion_limit(m: Dictionary,target: Vector2) -> Vector2:
	if not str(m.get("cap_state","")).is_empty():return target
	var start: Vector2=m.p
	var clearance=float(RADII.get(str(m.type),8))+2.0
	if capillary_blocked(start,clearance):
		return target if not capillary_blocked(target,clearance) else capillary_clear_point(start,clearance,m.inside)
	var length=start.distance_to(target)
	if length<.001:return target
	var steps=maxi(1,ceili(length/maxf(2.0,clearance*.4)))
	var last_free=start
	for step in range(1,steps+1):
		var sample=start.lerp(target,float(step)/float(steps))
		if capillary_blocked(sample,clearance):return last_free
		last_free=sample
	return target
func free_motion_limit(m: Dictionary,target: Vector2) -> Vector2:
	if m.type in ["o2","co2"]:return capillary_motion_limit(m,target)
	return capillary_motion_limit(m,membrane_drag_limit(m,target))
func push_radius(m: Dictionary) -> float:
	return maxf(18.0,float(RADII.get(str(m.type),8))*2.25)
func molecule_contact(a: Dictionary,b: Dictionary,gap: Vector2) -> Dictionary:
	if GAS_HITBOX.has(str(a.type)) or GAS_HITBOX.has(str(b.type)):
		var half_a: Vector2=GAS_HITBOX.get(str(a.type),Vector2.ONE*push_radius(a))
		var half_b: Vector2=GAS_HITBOX.get(str(b.type),Vector2.ONE*push_radius(b))
		var overlap=half_a+half_b+Vector2.ONE*1.0-gap.abs()
		if overlap.x<=0.0 or overlap.y<=0.0:return {}
		if overlap.x<overlap.y:return {"normal":Vector2.RIGHT if gap.x>=0.0 else Vector2.LEFT,"overlap":overlap.x}
		return {"normal":Vector2.DOWN if gap.y>=0.0 else Vector2.UP,"overlap":overlap.y}
	var distance=gap.length()
	var overlap=push_radius(a)+push_radius(b)-distance
	if overlap<=0.0:return {}
	return {"normal":gap/distance if distance>.001 else Vector2.RIGHT,"overlap":overlap}
func push_molecules_while_dragging(held: Dictionary,target: Vector2) -> Vector2:
	var start: Vector2=held.p
	var movement=target-start
	if movement.length_squared()<.0001:return target
	var direction=movement.normalized()
	var travel=movement.length()
	for other in mols:
		if other==held or other.dead or other.get("bound",false) or other.inside!=held.inside or not str(other.get("cap_state","")).is_empty():continue
		var along=clampf((Vector2(other.p)-start).dot(direction),0.0,travel)
		var closest=start+direction*along
		var hit=molecule_contact(held,other,Vector2(other.p)-closest)
		if hit.is_empty():continue
		var contact=push_radius(held)+push_radius(other)
		var distance=Vector2(other.p).distance_to(closest)
		var amount=minf(travel,maxf(8.0,float(hit.overlap)+12.0)) if GAS_HITBOX.has(str(held.type)) or GAS_HITBOX.has(str(other.type)) else minf(travel,contact*1.6)*(1.0-distance/contact*.35)
		other.p=free_motion_limit(other,Vector2(other.p)+direction*amount)
		other.v=direction*minf(100.0,amount*3.0)
		if other.get("parked",false):other.parked=false
	for pass_index in 3:
		for other in mols:
			if other==held or other.dead or other.get("bound",false) or other.inside!=held.inside or not str(other.get("cap_state","")).is_empty():continue
			var gap=Vector2(other.p)-target
			var hit=molecule_contact(held,other,gap)
			if hit.is_empty():continue
			var push_direction: Vector2=hit.normal
			other.p=free_motion_limit(other,Vector2(other.p)+push_direction*(float(hit.overlap)+3.0))
			other.v=push_direction*90.0
			if other.get("parked",false):other.parked=false
			var remaining=molecule_contact(held,other,Vector2(other.p)-target)
			if not remaining.is_empty():target=free_motion_limit(held,target-push_direction*(float(remaining.overlap)+2.0))
	return free_motion_limit(held,target)
func port_pos(a: float) -> Vector2:
	return cam_center+Vector2(radius.x*cos(a),radius.y*sin(a))
func mrna_slot_pos(rib: Dictionary) -> Vector2:
	return Vector2(rib.p)+MRNA_SLOT_OFFSET
func mrna_texture(uses: int) -> Texture2D:
	return textures.get("mrna%d" % clampi(uses,1,4))
func build_capillary_path() -> void:
	capillary_path.clear();capillary_distances.clear();capillary_length=0.0
	capillary_mask=capillary_bottom.get_image()
	capillary_top_mask=capillary_top.get_image()
	var image=capillary_mask
	var columns: Array[int]=[]
	for x in range(40,image.get_width(),8):columns.append(x)
	if columns.is_empty() or columns[-1]!=image.get_width()-1:columns.append(image.get_width()-1)
	for x in columns:
		var low=image.get_height()
		var high=-1
		for y in image.get_height():
			if image.get_pixel(x,y).a>.25:
				low=mini(low,y);high=maxi(high,y)
		if high<0:continue
		var point=Vector2(x,(low+high)*.5)
		if not capillary_path.is_empty():capillary_length+=capillary_path[-1].distance_to(point)
		capillary_path.append(point)
		capillary_distances.append(capillary_length)
func capillary_rect_for_size(viewport_size: Vector2) -> Rect2:
	var side=minf(CAPILLARY_IMAGE_SIZE,minf(viewport_size.x*.42,(viewport_size.y-76.0)*.72))*.75
	return Rect2(Vector2(viewport_size.x-side,76.0),Vector2.ONE*side)
func capillary_rect() -> Rect2:
	return capillary_rect_for_size(get_viewport_rect().size)
func remap_capillary_position(p: Vector2,old_rect: Rect2,new_rect: Rect2) -> Vector2:
	if old_rect.size.x<=0.0:return p
	var relative=(p-old_rect.position)/old_rect.size
	return new_rect.position+relative*new_rect.size
func capillary_point(progress: float) -> Vector2:
	var rect=capillary_rect()
	if capillary_path.is_empty():return rect.get_center()
	var distance=clampf(progress,0.0,1.0)*capillary_length
	var local=capillary_path[-1]
	for i in range(1,capillary_path.size()):
		if distance<=capillary_distances[i]:
			var segment=capillary_distances[i]-capillary_distances[i-1]
			local=capillary_path[i-1].lerp(capillary_path[i],(distance-capillary_distances[i-1])/maxf(segment,.001))
			break
	return rect.position+Vector2(rect.size.x*local.x/CAPILLARY_IMAGE_SIZE,rect.size.y*local.y/CAPILLARY_IMAGE_SIZE)
func capillary_eject_target(m: Dictionary) -> Vector2:
	var origin: Vector2=m.p
	var tangent=(capillary_point(.52)-capillary_point(.48)).normalized()
	var outward=Vector2(-tangent.y,tangent.x)
	if outward.dot(cam_center-origin)<0.0:outward=-outward
	var clearance=float(RADII.get(str(m.type),8))+4.0
	for distance in range(8,241,4):
		var candidate=origin+outward*float(distance)
		if not in_cell(candidate+outward*8.0) and not capillary_blocked(candidate,clearance) and not capillary_blocked(candidate+outward*8.0,clearance):
			return candidate+outward*8.0
	return capillary_clear_point(origin,clearance,false)
func co2_exchange_edge() -> Vector2:
	var center=capillary_point(.5)
	var tangent=(capillary_point(.52)-capillary_point(.48)).normalized()
	var outward=Vector2(-tangent.y,tangent.x)
	if outward.dot(cam_center-center)<0.0:outward=-outward
	var clearance=float(RADII.co2)+4.0
	for distance in range(12,121,4):
		var candidate=center+outward*float(distance)
		if not in_cell(candidate) and not capillary_blocked(candidate,clearance):return candidate
	return capillary_eject_target({"type":"co2","p":center})
func spawn_capillary_resource(kind: String,delay := 0.0) -> Dictionary:
	return add_mol(kind,capillary_point(0.0),false,{"v":Vector2.ZERO,"cap_state":"incoming_under","cap_progress":0.0,"cap_delay":delay})
func record_resource_consumption(kind: String,amount := 1.0) -> void:
	if consumption_pending.has(kind):consumption_pending[kind]=float(consumption_pending[kind])+amount
func apply_body_state(condition: String,announce := true) -> void:
	body_state=condition
	blood_flow_multiplier=1.0
	blood_glucose_concentration=1.0
	blood_aa_concentration=1.0
	oxygen_demand_multiplier=1.0
	match condition:
		"after_meal":
			blood_glucose_concentration=1.6;blood_aa_concentration=1.4
		"fasting":
			blood_glucose_concentration=.4;blood_aa_concentration=.7
		"exercise":
			blood_flow_multiplier=1.5;oxygen_demand_multiplier=1.5
		"poor_perfusion":
			blood_flow_multiplier=.45;oxygen_demand_multiplier=1.15
	if announce:say("Body condition: %s" % condition.replace("_"," ").capitalize())
func advance_body_condition(dt: float) -> void:
	if mode=="starve" or continuous_mode and not opening_complete:return
	body_event_timer-=dt
	if body_event_timer>0.0:return
	var sequence=["after_meal","exercise","fasting","poor_perfusion","baseline"]
	apply_body_state(sequence[body_event_index%sequence.size()])
	body_event_index+=1
	body_event_timer=65.0
func update_demand_estimates(dt: float) -> void:
	demand_sample_elapsed+=dt
	if demand_sample_elapsed<DEMAND_SAMPLE_SECONDS:return
	var smoothing=1.0-exp(-demand_sample_elapsed/DEMAND_SMOOTHING_SECONDS)
	for kind in ["glucose","aa","o2"]:
		var recent_rate=float(consumption_pending[kind])/demand_sample_elapsed
		predicted_use_rate[kind]=lerpf(float(predicted_use_rate[kind]),recent_rate,smoothing)
		consumption_pending[kind]=0.0
	demand_sample_elapsed=0.0
func effective_resource_stock(kind: String) -> float:
	var stock=0.0
	for molecule in mols:
		if molecule.dead or molecule.type!=kind:continue
		if molecule.inside:stock+=1.0
		elif edge_ratio(Vector2(molecule.p))<=2.3:stock+=.7
	return stock
func desired_delivery_units(kind: String,carrier_interval: float) -> float:
	var rate=float(predicted_use_rate.get(kind,0.0))*(oxygen_demand_multiplier if kind=="o2" else 1.0)
	var target_stock=maxf(float(RESOURCE_STOCK_FLOORS[kind]),rate*DEMAND_STOCK_SECONDS)
	var stock_error=target_stock-effective_resource_stock(kind)
	var passage_seconds=carrier_interval/maxf(.1,blood_flow_multiplier)
	return maxf(0.0,rate*1.15*passage_seconds+stock_error)
func plasma_payload() -> Dictionary:
	var payload={}
	var glucose_chance=clampf(desired_delivery_units("glucose",19.0)/3.0,0.0,1.0)
	var aa_chance=clampf(desired_delivery_units("aa",19.0)/4.0,0.0,1.0)
	if randf()<glucose_chance*clampf(blood_glucose_concentration,0.0,1.0):
		payload.glucose=randi_range(2,4)
		if blood_glucose_concentration>1.0:payload.glucose=maxi(1,roundi(int(payload.glucose)*blood_glucose_concentration))
	if randf()<aa_chance*clampf(blood_aa_concentration,0.0,1.0):
		payload.aa=randi_range(3,5)
		if blood_aa_concentration>1.0:payload.aa=maxi(1,roundi(int(payload.aa)*blood_aa_concentration))
	return payload
func spawn_blood_carrier(kind: String,payload: Dictionary = {},delay := 0.0,progress := 0.0) -> Dictionary:
	var contents=payload.duplicate(true)
	if kind=="plasma" and contents.is_empty():contents=plasma_payload()
	if kind=="rbc" and not contents.has("o2"):contents.o2=3
	var carrier={"type":kind,"progress":progress,"delay":delay,"speed":randf_range(.90,1.10),"payload":contents,"oxygenation":int(contents.get("o2",0)) if kind=="rbc" else 0,"unload_target":-1,"released":false,"released_o2":0,"co2_load":0,"co2_target":{},"dead":false}
	blood_carriers.append(carrier)
	return carrier
func local_extracellular_oxygen() -> int:
	var center=capillary_point(.52)
	var nearby=0
	for molecule in mols:
		if molecule.dead or molecule.inside or molecule.type!="o2":continue
		if Vector2(molecule.p).distance_to(center)<240.0:nearby+=1
	return nearby
func red_cell_unload_target(carrier: Dictionary) -> int:
	var desired=desired_delivery_units("o2",16.0)
	var requested=mini(3,floori(desired))
	if requested<3 and randf()<desired-float(requested):requested+=1
	return mini(requested,int(carrier.oxygenation))
func release_blood_resource(kind: String,progress: float) -> Dictionary:
	var origin=capillary_point(progress)
	var molecule=add_mol(kind,origin,false,{"v":Vector2.ZERO,"cap_state":"incoming_eject","cap_time":0.0,"cap_origin":origin,"cap_progress":progress})
	molecule.cap_target=capillary_eject_target(molecule)
	return molecule
func process_blood_flow(dt: float) -> void:
	update_demand_estimates(dt)
	var flow=maxf(.1,blood_flow_multiplier)
	red_cell_timer-=dt*flow
	plasma_timer-=dt*flow
	if red_cell_timer<=0.0:
		spawn_blood_carrier("rbc")
		red_cell_timer+=randf_range(12.0,20.0)
	if plasma_timer<=0.0:
		spawn_blood_carrier("plasma")
		plasma_timer+=randf_range(14.0,24.0)
	for carrier in blood_carriers:
		if carrier.dead:continue
		if float(carrier.delay)>0.0:
			carrier.delay=float(carrier.delay)-dt
			continue
		carrier.progress=minf(1.0,float(carrier.progress)+dt*.20*flow*float(carrier.speed))
		if carrier.type=="rbc":
			if int(carrier.unload_target)<0 and float(carrier.progress)>=BLOOD_EXCHANGE_START:
				carrier.unload_target=red_cell_unload_target(carrier)
			var load=int(carrier.unload_target)
			while int(carrier.released_o2)<load:
				var threshold=BLOOD_EXCHANGE_START+(BLOOD_EXCHANGE_END-BLOOD_EXCHANGE_START)*(float(carrier.released_o2)+.5)/float(load)
				if float(carrier.progress)<threshold:break
				release_blood_resource("o2",threshold)
				carrier.released_o2=int(carrier.released_o2)+1
				carrier.oxygenation=maxi(0,int(carrier.oxygenation)-1)
			var active_target: Dictionary=carrier.get("co2_target",{})
			if not active_target.is_empty() and active_target.dead:carrier.co2_target={}
			if float(carrier.progress)>=BLOOD_EXCHANGE_START and float(carrier.progress)<=BLOOD_EXCHANGE_END and int(carrier.co2_load)<2 and carrier.co2_target.is_empty():
				var blood_position=capillary_point(float(carrier.progress))
				var nearest: Dictionary={}
				var nearest_distance=RBC_CO2_CAPTURE_RADIUS
				for molecule in mols:
					if molecule.dead or molecule.type!="co2" or molecule.inside or str(molecule.get("cap_state","")) not in ["co2_seek","co2_wait"]:continue
					var distance=Vector2(molecule.p).distance_to(blood_position)
					if distance<nearest_distance:nearest=molecule;nearest_distance=distance
				if not nearest.is_empty():
					carrier.co2_target=nearest
					nearest.cap_state="co2_rbc_capture"
					nearest.cap_time=0.0
					nearest.cap_origin=Vector2(nearest.p)
					nearest.rbc_carrier=carrier
					nearest.v=Vector2.ZERO
		elif not carrier.released and float(carrier.progress)>=.52:
			carrier.released=true
			for nutrient in ["glucose","aa"]:
				for i in int(carrier.payload.get(nutrient,0)):
					release_blood_resource(nutrient,randf_range(.49,.55))
		if float(carrier.progress)>=1.0:carrier.dead=true
	blood_carriers=blood_carriers.filter(func(carrier):return not carrier.dead)
func add_mol(kind: String, p: Vector2, inside: bool, extra := {}) -> Dictionary:
	var m = {"type":kind,"p":p,"v":Vector2(randf_range(-8,8),randf_range(-8,8)),"inside":inside,"dead":false}
	m.merge(extra,true)
	mols.append(m)
	return m
func spawn_outside(kind: String) -> void:
	spawn_capillary_resource(kind)
func add_waste(n: int, typed := false) -> void:
	for i in n:
		var a=randf()*TAU
		var sub=["protein","sugar","lipid"].pick_random() if typed else "protein"
		add_mol("waste",cam_center+Vector2(radius.x*cos(a),radius.y*sin(a))*0.30,true,{"sub":sub,"typed":typed})
		state.waste += 1
func add_port(kind: String, a: float) -> void:
	ports.append({"type":kind,"a":a,"p":port_pos(a),"pump_cd":0.0,"transport_cd":0.0,"bound_mol":{}})
func crack_state(angle: float) -> Dictionary:
	if not crack_data.has(angle):crack_data[angle]={"severity":1,"age":0.0,"leak_cd":5.0,"material":false,"protein":false}
	return crack_data[angle]
func port_damaged(port: Dictionary) -> bool:
	for angle in cracks:
		var width=.19 if int(crack_state(angle).severity)==1 else .30
		if absf(wrapf(float(port.a)-angle,-PI,PI))<width:return true
	return false
func seal_crack(angle: float,at: Vector2) -> void:
	cracks.erase(angle)
	crack_data.erase(angle)
	state.patched=int(state.patched)+1
	tutorial_event("membrane_repaired")
	pop(at+Vector2(0,-14),"MEMBRANE SEALED",Color("#7ee89b"))
	say("Membrane sealed. Nearby ports are working again.")
func apply_crack_repair(angle: float,material: String,at: Vector2) -> bool:
	if not cracks.has(angle):return false
	var damage=crack_state(angle)
	if material=="lipid":
		if bool(damage.material):say("This rupture already has lipid. Add a repair protein.");return false
		damage.material=true
	elif material=="protein":
		if bool(damage.protein):say("This tear is already stabilized. Add a lipid.");return false
		damage.protein=true
	else:return false
	if bool(damage.material) and (int(damage.severity)<2 or bool(damage.protein)):
		seal_crack(angle,at)
	else:
		pop(at+Vector2(0,-14),"LIPID ADDED" if material=="lipid" else "REPAIR STABILIZED",Color("#c8a2e8") if material=="lipid" else Color("#7ee89b"))
		say("Large rupture needs a lipid and repair protein." if int(damage.severity)>=2 else "Repair protein stabilized the tear. Add a lipid to seal it.")
	return true
func leak_through_crack(angle: float) -> bool:
	var point=port_pos(angle)
	var chosen: Dictionary={}
	var best=INF
	for molecule in mols:
		if molecule.dead or molecule==dragging or molecule.get("bound",false) or molecule.type not in ["glucose","aa","na","k","water","ca"]:continue
		if not str(molecule.get("cap_state","")).is_empty() or not str(molecule.get("capture_state","")).is_empty():continue
		if elapsed-float(molecule.get("last_leak",-100.0))<3.0:continue
		var distance=Vector2(molecule.p).distance_to(point)
		if distance>72.0:continue
		var preference=0.0
		if molecule.type=="na" and not molecule.inside:preference=12.0
		elif molecule.type=="k" and molecule.inside:preference=12.0
		elif molecule.type in ["glucose","aa"] and molecule.inside:preference=8.0
		var score=distance-preference
		if score<best:best=score;chosen=molecule
	if chosen.is_empty():return false
	var outward=port_surface_normal({"p":point})
	chosen.inside=not bool(chosen.inside)
	var offset=outward*(float(RADII.get(str(chosen.type),8))+20.0)
	chosen.p=point-offset if chosen.inside else capillary_clear_point(point+offset,float(RADII.get(str(chosen.type),8))+2.0,false)
	chosen.v=(-outward if chosen.inside else outward)*35.0
	chosen.last_leak=elapsed
	pop(point+Vector2(0,-20),"LEAK",Color("#e05a5a"))
	return true
func process_membrane_damage(dt: float) -> void:
	for angle in cracks:
		var damage=crack_state(angle)
		damage.age=float(damage.age)+dt
		if int(damage.severity)<2 and float(damage.age)>=(100.0 if bool(damage.protein) else 55.0):
			damage.severity=2
			damage.age=0.0
			pop(port_pos(angle)+Vector2(0,-25),"RUPTURE GROWING",Color("#e05a5a"))
			say("An untreated tear became a large rupture. It needs lipid and repair protein.")
		damage.leak_cd=float(damage.leak_cd)-dt
		if float(damage.leak_cd)<=0.0:
			var interval=5.0 if int(damage.severity)==1 else 2.0
			if bool(damage.material) or bool(damage.protein):interval*=1.8
			damage.leak_cd=interval
			leak_through_crack(angle)
		if int(damage.severity)>=2 and osmotic_drive()>0.0:
			state.swell=clampf(float(state.swell)+dt*minf(8.0,osmotic_drive())*.0006,0.0,.3)
func membrane_integrity() -> int:
	var loss=0
	for angle in cracks:
		var damage=crack_state(angle)
		loss+=12 if int(damage.severity)==1 else 24
		if bool(damage.material) or bool(damage.protein):loss-=4
	return maxi(0,100-loss)
func port_capture_radius(port: Dictionary) -> float:
	var upgrade=str(port.type)+"_range"
	return PORT_BASE_CAPTURE_RADIUS*minf(1.8,float(ups.get(upgrade,1.0)))
func port_pull_strength(port: Dictionary) -> float:
	var upgrade=str(port.type)+"_pull"
	return PORT_BASE_PULL_STRENGTH*float(ups.get(upgrade,1.0))
func port_transport_cooldown(port: Dictionary) -> float:
	var upgrade="glut" if port.type=="glut" else "aa_rate"
	var speed=float(ups.get(upgrade,1.0))*(2.0 if state.alert>0.0 else 1.0)
	return 2.0/maxf(.1,speed)
func port_surface_normal(port: Dictionary) -> Vector2:
	var radial=Vector2(port.p)-cam_center
	return Vector2(radial.x/(radius.x*radius.x),radial.y/(radius.y*radius.y)).normalized()
func port_dock_point(port: Dictionary,kind: String) -> Vector2:
	return Vector2(port.p)+port_surface_normal(port)*(float(RADII.get(kind,8))+5.0)
func port_inner_point(port: Dictionary,kind: String) -> Vector2:
	return Vector2(port.p)-port_surface_normal(port)*(float(RADII.get(kind,8))+16.0)
func bind_molecule_to_port(m: Dictionary,port: Dictionary) -> bool:
	var bound: Dictionary=port.get("bound_mol",{})
	if port_damaged(port) or float(port.get("transport_cd",0.0))>0.0 or not bound.is_empty():return false
	port.bound_mol=m
	m.capture_port=port
	m.capture_state="docking"
	m.capture_time=0.0
	m.capture_origin=Vector2(m.p)
	m.v=Vector2.ZERO
	return true
func advance_port_transit(m: Dictionary,dt: float) -> void:
	var port: Dictionary=m.get("capture_port",{})
	if port.is_empty():m.erase("capture_state");return
	m.capture_time=float(m.get("capture_time",0.0))+dt
	if m.capture_state=="docking":
		var t=clampf(float(m.capture_time)/PORT_DOCK_SECONDS,0.0,1.0)
		var normal=port_surface_normal(port)
		var tangent=Vector2(-normal.y,normal.x)
		m.p=Vector2(m.capture_origin).lerp(port_dock_point(port,str(m.type)),t)+tangent*sin(t*TAU*2.0)*1.5*(1.0-t)
		if t>=1.0:m.capture_state="translocating";m.capture_time=0.0
	else:
		var t=clampf(float(m.capture_time)/PORT_TRANSLOCATE_SECONDS,0.0,1.0)
		m.p=port_dock_point(port,str(m.type)).lerp(port_inner_point(port,str(m.type)),t*t*(3.0-2.0*t))
		if t>=1.0:
			m.inside=true
			if m.type=="glucose":tutorial_event("glucose_imported")
			m.p=port_inner_point(port,str(m.type))
			m.v=(cam_center-Vector2(m.p)).normalized()*25.0
			m.erase("capture_state");m.erase("capture_port");m.erase("capture_time");m.erase("capture_origin");m.erase("capture_hint")
			port.bound_mol={}
			port.transport_cd=port_transport_cooldown(port)
			pop(Vector2(port.p)+Vector2(0,-16),"+1 glucose" if m.type=="glucose" else "+1 AA",Color("#e8b04a") if m.type=="glucose" else Color("#e06a8a"))
func attract_to_port(m: Dictionary,dt: float) -> bool:
	var wanted="glut" if m.type=="glucose" else "aa"
	var best: Dictionary={}
	var nearest=INF
	for port in ports:
		var bound: Dictionary=port.get("bound_mol",{})
		if port.type!=wanted or not bound.is_empty() or port_damaged(port):continue
		var dock=port_dock_point(port,str(m.type))
		var distance=Vector2(m.p).distance_to(dock)
		if distance<port_capture_radius(port) and distance<nearest:
			best=port;nearest=distance
	if best.is_empty():m.capture_hint=0.0;return false
	m.capture_hint=1.0
	var dock=port_dock_point(best,str(m.type))
	if nearest<=8.0 and bind_molecule_to_port(m,best):return true
	var desired=(dock-Vector2(m.p)).normalized()*port_pull_strength(best)
	m.v=Vector2(m.v).lerp(desired,minf(1.0,dt*2.2))
	return false
func org(kind: String) -> Dictionary:
	for o in orgs:
		if o.type==kind:return o
	return {}
func nearest_org(kind: String, p: Vector2, limit := INF) -> Dictionary:
	var best: Dictionary={}
	var d=limit
	for o in orgs:
		if o.type==kind and p.distance_to(o.p)<d:
			best=o;d=p.distance_to(o.p)
	return best
func start_level(n: int) -> void:
	continuous_mode=false
	var previous=state.duplicate()
	dimensions()
	level=clampi(n,1,15)
	var l=LEVELS[level-1]
	mode=l.get("mode","")
	mols.clear();orgs.clear();ports.clear();cracks.clear();crack_data.clear();rails.clear();goals.clear();relay_dots.clear();pops.clear();blood_carriers.clear();dragging={};molecule_drag_moved=false;ribosome_drag={};placing="";rail_start={}
	toolbox_drag_kind=""
	if is_instance_valid(placement_preview):placement_preview.visible=false
	state={"atp":15.0,"adp":36.0,"made":0,"exported":0,"waste":0,"recycled":0,"atp_made":0,"patched":0,"membrane_growth":0,"bursts":0,"engulfed":0,"killed":0,"pumped":0,"survived":0.0,"waves":0,"misfold":0,"alert":0.0,"swell":0.05,"osmotic_stable_time":0.0,"water_flux":0.0,"ca_timer":0.0,"ca_spawn":0.0,"virus_cd":4.0,"rep_cd":16.0,"burst_cd":9.0,"burst_timer":0.0,"burst_active":false,"water_cd":4.0,"na_cd":10.0,"burst_wave":0,"burst_waste_cd":.5,"spill_timer":0.0,"crack_cd":10.0,"chunk_cd":6.0,"starve_waste_cd":60.0,"virus_hits":0,"signals_relayed":0}
	dimensions()
	if not previous.is_empty() and n!=1:
		state.atp=previous.atp;state.adp=previous.adp
	if mode in ["virus","osmosis"]:state.atp=25.0
	if mode=="starve":state.atp=20.0
	body_event_index=0
	body_event_timer=65.0
	apply_body_state("fasting" if mode=="starve" else "baseline",false)
	consumption_pending={"glucose":0.0,"aa":0.0,"o2":0.0}
	predicted_use_rate={"glucose":0.0,"aa":0.0,"o2":0.0}
	demand_sample_elapsed=0.0
	red_cell_timer=randf_range(12.0,20.0)
	plasma_timer=randf_range(14.0,24.0)
	elapsed=0;spawn_timer=0;pack_timer=0;paused=false;campaign=false;campaign_chain=1
	for kind in l.org:
		var q=ORG_POS[kind]
		var position=cam_center+Vector2(radius.x*q.x*0.92,radius.y*q.y*0.82)
		orgs.append({"type":kind,"p":position,"home_p":position,"slots":[],"gene":"","template":{},"state":"free","bound_er":{},"chaperones":0,"lipid_timer":0.0})
	if level>=7:
		var smooth_position=cam_center+Vector2(-radius.x*.12,radius.y*.60)
		orgs.append({"type":"er","p":smooth_position,"home_p":smooth_position,"slots":[],"chaperones":0,"lipid_timer":0.0})
	if mode=="chaos":orgs.append({"type":"lysosome","p":cam_center+Vector2(radius.x*.46,radius.y*.72),"slots":[]})
	if mode=="enz":
		orgs.append({"type":"lysosome","p":cam_center+Vector2(radius.x*.4,radius.y*.7),"enzyme":"protein","slots":[]})
		orgs.append({"type":"lysosome","p":cam_center+Vector2(-radius.x*.42,radius.y*.72),"enzyme":"sugar","slots":[]})
		orgs.append({"type":"lysosome","p":cam_center+Vector2(-radius.x*.44,-radius.y*.55),"enzyme":"lipid","slots":[]})
	for a in [3.49,5.93,1.4]:add_port("glut",a)
	for a in [2.6,0.17]:add_port("aa",a)
	if mode in ["signal","chaos","ca2"]:add_port("rx",4.5)
	if mode=="chaos":add_port("rx",4.5)
	if mode in ["ca2","chaos"]:add_port("ca",4.2)
	spawn_blood_carrier("rbc",{},0.0,.20)
	spawn_blood_carrier("plasma",{},0.0,.24)
	var arrival_index=0
	for kind in l.spawn:
		if kind in ["glucose","o2","aa"]:continue
		for i in int(l.spawn[kind]):
			spawn_capillary_resource(kind,.35+arrival_index*.16)
			arrival_index+=1
	if level==4:add_waste(5)
	elif mode=="enz":add_waste(6,true)
	elif level>=4 and mode!="virus":add_waste(2,mode=="chaos")
	if mode=="chaos":
		add_mol("vrna",cam_center+Vector2(radius.x*.35,radius.y*.1),true)
	if mode=="starve":add_waste(4)
	if mode=="virus":
		add_waste(3)
		add_mol("vrna",cam_center+Vector2(radius.x*.35,radius.y*.1),true)
	if mode=="osmosis":
		for i in 14:spawn_capillary_resource("water",.35+arrival_index*.16+i*.16)
		for i in 9:add_mol("na",cam_center+Vector2(radius.x*.62,randf_range(-35,35)),true)
		add_port("nak",atan2(capillary_point(.5).y-cam_center.y,capillary_point(.5).x-cam_center.x))
		add_port("aqua",2.2)
		for i in 6:spawn_capillary_resource("k",.5+arrival_index*.16+i*.16)
		toolbox["aquaport"]=int(toolbox.get("aquaport",0))+2
	if level in [11,12]:
		for i in 6:spawn_capillary_resource("k",.5+arrival_index*.16+i*.16)
	if level>=7 and mode!="patch":
		for i in 3:add_mol("lipid",cam_center+Vector2(-radius.x*.10+i*17,radius.y*.35),true)
	if mode=="patch":
		cracks.append(randf()*TAU);cracks.append(randf()*TAU)
	for item in ["ribosome","golgi","lysosome","mitochondrion","microtubule","glutport","aaport","motor"]:toolbox[item]=int(toolbox.get(item,0))+3
	var p_amt=2+int(floor(level*.8))
	goals=[{"kind":"protein","amount":p_amt,"base":0,"done":false,"next_issued":false},{"kind":"energy","amount":30+level*8,"base":0,"done":false,"next_issued":false}]
	if level>=4:goals.append({"kind":"recycle","amount":2+int(floor(level*.5)),"base":0,"done":false,"next_issued":false})
	goal_done_count=0
	close_overlay()
	var cfg=ConfigFile.new();cfg.load("user://inside_life_progress.cfg");cfg.set_value("progress","current",level);cfg.set_value("progress","max",max_unlocked);cfg.set_value("progress","beaten",beaten);cfg.save("user://inside_life_progress.cfg")
	build_goal_cards()
	update_ui()
	queue_redraw()

func start_continuous() -> void:
	state={}
	toolbox.clear()
	ups.clear()
	start_level(3)
	continuous_mode=true
	mode=""
	max_unlocked=3
	beaten.clear()
	opening_complete=false
	guide_active=true
	guide_steps.clear()
	for step in OPENING_GUIDE:guide_steps.append(step.duplicate(true))
	guide_index=0
	guide_source="opening"
	learning_events.clear()
	active_mechanics.clear()
	completed_mechanics.clear()
	next_mechanic_index=0
	free_play_time=0.0
	guide_delay=55.0
	blood_carriers.clear()
	spawn_blood_carrier("rbc",{"o2":3},999.0,.42)
	spawn_blood_carrier("plasma",{"glucose":5,"aa":9},0.0,.50)
	red_cell_timer=1000.0
	plasma_timer=20.0
	if is_instance_valid(level_button):level_button.visible=false
	goals=[{"kind":"protein","amount":2,"base":0,"done":false,"next_issued":false},{"kind":"energy","amount":30,"base":0,"done":false,"next_issued":false}]
	build_goal_cards()
	update_ui()
	queue_redraw()

func tutorial_event(event_name: String) -> void:
	if not continuous_mode or not guide_active or guide_index>=guide_steps.size():return
	if event_name!=str(guide_steps[guide_index].event):return
	if event_name=="glucose_imported" and guide_source=="opening":
		for carrier in blood_carriers:
			if carrier.type=="rbc":carrier.delay=0.0
		red_cell_timer=15.0
	if event_name=="aquaporin_placed" and guide_source=="osmosis":
		for i in 5:spawn_capillary_resource("water",float(i)*.12)
	learning_events[event_name]=true
	advance_guidance()

func advance_guidance() -> void:
	if not guide_active:return
	while guide_index<guide_steps.size() and learning_events.get(str(guide_steps[guide_index].event),false):guide_index+=1
	if guide_index<guide_steps.size():
		queue_redraw()
		return
	guide_active=false
	if guide_source=="opening":
		opening_complete=true
		say("Insulin exported. Your cell is yours to grow.")
	else:
		completed_mechanics.append(guide_source)
		say("%s learned. Keep playing with your cell." % guide_source.capitalize())
	free_play_time=0.0
	guide_delay=55.0 if next_mechanic_index==0 else 70.0
	queue_redraw()

func update_continuous_progress(dt: float) -> void:
	if not continuous_mode or not opening_complete or guide_active:return
	free_play_time+=dt
	if overlay.visible or next_mechanic_index>=MECHANIC_SEQUENCE.size() or free_play_time<guide_delay:return
	introduce_mechanic(str(MECHANIC_SEQUENCE[next_mechanic_index]))
	next_mechanic_index+=1
	free_play_time=0.0

func guide_step(event_name: String,focus: String,title: String,explain: String,action: String) -> void:
	guide_steps.append({"event":event_name,"focus":focus,"title":title,"explain":explain,"action":action})

func introduce_mechanic(kind: String) -> void:
	if not active_mechanics.has(kind):active_mechanics.append(kind)
	guide_source=kind
	guide_index=0
	guide_steps.clear()
	match kind:
		"waste":
			if org("lysosome").is_empty():orgs.append({"type":"lysosome","p":cam_center+Vector2(-radius.x*.48,-radius.y*.54),"slots":[]})
			add_waste(2)
			guide_step("waste_recycled","lysosome","Lysosome","Lysosomes recycle damaged material.","Drag waste into the lysosome.")
			goals.append({"kind":"recycle","amount":2,"base":state.recycled,"done":false,"next_issued":false})
			build_goal_cards()
		"enzymes":
			for entry in [["protein",Vector2(.47,.62)],["sugar",Vector2(-.44,.68)],["lipid",Vector2(-.48,-.56)]]:
				orgs.append({"type":"lysosome","p":cam_center+Vector2(radius.x*entry[1].x,radius.y*entry[1].y),"enzyme":entry[0],"slots":[]})
			add_waste(3,true)
			guide_step("typed_waste_recycled","waste","Enzyme specificity","Different waste needs matching enzymes.","Match colored waste to its lysosome.")
		"signal":
			add_port("rx",4.5)
			spawn_capillary_resource("hormone")
			guide_step("signal_received","rx","Cell signaling","A receptor detects outside hormones.","Bring adrenaline to the green receptor.")
		"repair":
			var smooth_position=cam_center+Vector2(-radius.x*.12,radius.y*.60)
			orgs.append({"type":"er","p":smooth_position,"home_p":smooth_position,"slots":[],"chaperones":0,"lipid_timer":0.0})
			add_mol("lipid",smooth_position+Vector2(40,15),true)
			spawn_crack()
			guide_step("membrane_repaired","crack","Membrane repair","Tears leak resources and block nearby ports.","Drag a lipid onto the red crack.")
		"quality":
			var er=org("er")
			add_mol("protein",Vector2(er.p)+Vector2(46,20),true,{"gene":"s_ins","stage":"misfolded","misfold":true})
			state.misfold=int(state.misfold)+1
			guide_step("misfold_recycled","lysosome","Quality control","Misfolded proteins must be recycled.","Bring the damaged protein to a lysosome.")
		"endocytosis":
			spawn_capillary_resource("chunk")
			guide_step("chunk_engulfed","chunk","Endocytosis","Large nutrients enter inside a vesicle.","Press a gold chunk against the membrane.")
			guide_step("chunk_digested","lysosome","Digest the vesicle","The lysosome breaks down the chunk.","Move its vesicle to a lysosome.")
		"rails":
			toolbox["microtubule"]=int(toolbox.get("microtubule",0))+1
			toolbox["motor"]=int(toolbox.get("motor",0))+1
			guide_step("rail_created","golgi","Microtubule","Rails include a motor that carries cargo.","Connect Golgi to the membrane.")
		"combined":
			add_waste(2,true)
			spawn_crack()
			guide_step("membrane_repaired","crack","Combined stress","More than one threat can arrive at once.","Repair the new membrane crack.")
			guide_step("waste_recycled","waste","Keep recycling","Balance repair with cleanup.","Recycle a waste piece.")
		"virus":
			add_mol("vrna",cam_center+Vector2(radius.x*.35,radius.y*.1),true)
			guide_step("virus_destroyed","viral","Viral RNA","A virus can hijack protein production.","Take viral RNA to a lysosome.")
		"homeostasis":
			var capillary_center=capillary_point(.5)
			var pump_angle=atan2((capillary_center.y-cam_center.y)/radius.y,(capillary_center.x-cam_center.x)/radius.x)
			var pump_position=port_pos(pump_angle)
			toolbox["nakport"]=int(toolbox.get("nakport",0))+2
			for i in 3:add_mol("na",cam_center+(pump_position-cam_center)*.85+Vector2(0,float(i-1)*15.0),true)
			for i in 2:spawn_capillary_resource("k",float(i)*.15)
			guide_step("pump_placed","membrane","Na⁺/K⁺ pump","Place a pump near incoming potassium.","Install a pump on the nearby membrane.")
			guide_step("ion_exchange","nak","Ion balance","Each cycle costs 1 ATP.","Bring 2 K⁺ close for a 3-for-2 exchange.")
		"osmosis":
			toolbox["aquaport"]=int(toolbox.get("aquaport",0))+1
			for i in 6:add_mol("na",cam_center+Vector2(radius.x*.55,float(i-3)*12.0),true)
			for i in 4:spawn_capillary_resource("k",float(i)*.12)
			state.osmotic_challenge=maxf(0.0,4.0-osmotic_drive())
			guide_step("aquaporin_placed","membrane","Aquaporin","Water crosses passively; ports speed it.","Place an aquaporin on the membrane.")
			guide_step("water_crossed","aqua","Osmosis","Water follows the solute gradient.","Watch water cross without spending ATP.")
		"calcium":
			if not ports.any(func(port):return port.type=="rx"):add_port("rx",4.5)
			add_port("ca",4.2)
			spawn_capillary_resource("hormone")
			guide_step("calcium_spark","ca","Calcium signaling","A receptor opens calcium channels briefly.","Dock adrenaline to trigger a spark.")
	learning_events.clear()
	guide_active=true
	update_ui()
	queue_redraw()

func make_ui() -> void:
	ui=CanvasLayer.new();add_child(ui)
	var full=Control.new();full.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);full.mouse_filter=Control.MOUSE_FILTER_IGNORE;ui.add_child(full)
	var source_theme=Theme.new();source_theme.default_font=font;full.theme=source_theme
	var top=ColorRect.new();top.color=Color("#0a0f1a");top.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE);top.offset_bottom=76;top.mouse_filter=Control.MOUSE_FILTER_IGNORE;full.add_child(top)
	for y in [43.0,75.0]:
		var divider=ColorRect.new();divider.color=Color("#2a3a55");divider.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE);divider.offset_top=y;divider.offset_bottom=y+1;divider.mouse_filter=Control.MOUSE_FILTER_IGNORE;full.add_child(divider)
	hud=Label.new();hud.visible=false;full.add_child(hud)
	var hud_row=HBoxContainer.new();hud_row.position=Vector2(16,4);hud_row.add_theme_constant_override("separation",9);full.add_child(hud_row)
	for item in [["atp","⚡ ATP"],["adp","🔄 ADP"],["glucose","🍞 Glucose"],["aa","AAs"],["o2","O₂"],["exported","🚀 Exported"],["waste","● Waste"],["integrity","🛡 Integrity"]]:
		var chip=PanelContainer.new()
		var style=StyleBoxFlat.new();style.bg_color=Color("#111a2c");style.border_color=Color("#2a3a55");style.set_border_width_all(1);style.set_corner_radius_all(8);style.set_content_margin_all(5)
		chip.add_theme_stylebox_override("panel",style)
		var label=Label.new();label.add_theme_color_override("font_color",GOLD);label.add_theme_font_size_override("font_size",13);chip.add_child(label)
		hud_row.add_child(chip);hud_widgets[item[0]]={"panel":chip,"label":label,"prefix":item[1]}
	var title_row=HBoxContainer.new();title_row.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP);title_row.offset_left=-300;title_row.offset_right=300;title_row.offset_top=45;title_row.offset_bottom=74;title_row.alignment=BoxContainer.ALIGNMENT_CENTER;title_row.add_theme_constant_override("separation",12);full.add_child(title_row)
	title_label=Label.new();title_label.custom_minimum_size.x=330;title_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;title_label.vertical_alignment=VERTICAL_ALIGNMENT_CENTER;title_label.add_theme_color_override("font_color",GOLD);title_label.add_theme_font_override("font",bold_font);title_label.add_theme_font_size_override("font_size",18);title_label.mouse_filter=Control.MOUSE_FILTER_IGNORE;title_row.add_child(title_label)
	pause_button=Button.new();pause_button.text="⏸ Pause";pause_button.custom_minimum_size=Vector2(96,28);pause_button.pressed.connect(toggle_pause);title_row.add_child(pause_button)
	var pause_style=StyleBoxFlat.new();pause_style.bg_color=Color("#111a2c");pause_style.border_color=Color("#3a4a68");pause_style.set_border_width_all(1);pause_style.set_corner_radius_all(7);pause_button.add_theme_stylebox_override("normal",pause_style)
	level_button=Button.new();level_button.text="Levels";level_button.custom_minimum_size=Vector2(86,28);level_button.pressed.connect(show_levels);title_row.add_child(level_button)
	var levels_style=StyleBoxFlat.new();levels_style.bg_color=Color("#2e3d22");levels_style.border_color=Color("#8a7a4c");levels_style.set_border_width_all(1);levels_style.set_corner_radius_all(7);level_button.add_theme_stylebox_override("normal",levels_style);level_button.add_theme_color_override("font_color",Color("#d9c87a"))
	goal_label=Label.new();goal_label.visible=false;full.add_child(goal_label)
	goal_row=HBoxContainer.new();goal_row.position=Vector2(12,96);goal_row.add_theme_constant_override("separation",10);goal_row.mouse_filter=Control.MOUSE_FILTER_IGNORE;full.add_child(goal_row)
	toolbox_panel=PanelContainer.new();toolbox_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM);full.add_child(toolbox_panel)
	var toolbox_style=StyleBoxFlat.new();toolbox_style.bg_color=Color(0.03,0.047,0.086,0.92);toolbox_style.border_color=Color("#8a7a4c");toolbox_style.set_border_width_all(1);toolbox_style.set_corner_radius_all(10);toolbox_style.corner_radius_bottom_left=0;toolbox_style.corner_radius_bottom_right=0;toolbox_style.content_margin_left=14;toolbox_style.content_margin_right=14;toolbox_style.content_margin_top=10;toolbox_style.content_margin_bottom=10;toolbox_panel.add_theme_stylebox_override("panel",toolbox_style)
	toolbox_row=HBoxContainer.new();toolbox_row.add_theme_constant_override("separation",12);toolbox_panel.add_child(toolbox_row)
	toast_label=Label.new();toast_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM);toast_label.offset_left=-440;toast_label.offset_right=440;toast_label.offset_top=-116;toast_label.offset_bottom=-82;toast_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;toast_label.add_theme_color_override("font_color",Color.WHITE);toast_label.mouse_filter=Control.MOUSE_FILTER_IGNORE;full.add_child(toast_label)
	park_label=Label.new();park_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM);park_label.offset_left=-185;park_label.offset_right=185;park_label.offset_top=-148;park_label.offset_bottom=-123;park_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;park_label.add_theme_color_override("font_color",GOLD);park_label.add_theme_font_size_override("font_size",12);park_label.mouse_filter=Control.MOUSE_FILTER_IGNORE;park_label.visible=false;full.add_child(park_label)
	overlay=PanelContainer.new();overlay.set_anchors_and_offsets_preset(Control.PRESET_CENTER);overlay.visible=false;full.add_child(overlay)
	set_overlay_size(Vector2(560,240))
	overlay_margin=MarginContainer.new();overlay_margin.add_theme_constant_override("margin_left",28);overlay_margin.add_theme_constant_override("margin_right",28);overlay_margin.add_theme_constant_override("margin_top",22);overlay_margin.add_theme_constant_override("margin_bottom",22);overlay.add_child(overlay_margin)
	overlay_body=VBoxContainer.new();overlay_body.add_theme_constant_override("separation",10);overlay_margin.add_child(overlay_body)
	inspect_panel=PanelContainer.new();inspect_panel.position=Vector2(965,84);inspect_panel.custom_minimum_size=Vector2(300,150);inspect_panel.visible=false;full.add_child(inspect_panel)
	var im=MarginContainer.new();im.add_theme_constant_override("margin_left",12);im.add_theme_constant_override("margin_right",12);im.add_theme_constant_override("margin_top",12);im.add_theme_constant_override("margin_bottom",12);inspect_panel.add_child(im)
	var iv=VBoxContainer.new();im.add_child(iv)
	inspect_heading=Label.new();inspect_heading.add_theme_color_override("font_color",GOLD);inspect_heading.add_theme_font_size_override("font_size",16);iv.add_child(inspect_heading)
	inspect_description=Label.new();inspect_description.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;inspect_description.custom_minimum_size=Vector2(275,100);inspect_description.add_theme_color_override("font_color",MUTED);iv.add_child(inspect_description)
	var inspect_close=Button.new();inspect_close.text="Close";inspect_close.pressed.connect(close_inspect);iv.add_child(inspect_close)
	context_menu=PopupMenu.new();context_menu.id_pressed.connect(context_action);full.add_child(context_menu)
	placement_preview=ToolboxMini.new();placement_preview.visual_font=font;placement_preview.size=Vector2(80,80);placement_preview.mouse_filter=Control.MOUSE_FILTER_IGNORE;placement_preview.visible=false;full.add_child(placement_preview)

func update_ui() -> void:
	if not is_instance_valid(hud):return
	var values={"atp":int(state.atp),"adp":int(state.adp),"glucose":count_mol("glucose",true),"aa":count_mol("aa",true),"o2":count_mol("o2",true),"exported":state.exported,"waste":state.waste,"integrity":membrane_integrity()}
	for key in hud_widgets:
		var widget=hud_widgets[key]
		widget.label.text="%s %s" % [widget.prefix,values[key]]
		widget.panel.visible=not ((key=="aa" and level<2) or (key=="exported" and level<3) or (key=="waste" and (not continuous_mode and level<4 or continuous_mode and not active_mechanics.has("waste"))))
	title_label.text="Inside Life — Living Cell" if continuous_mode else ("CAMPAIGN CHAIN %d  —  " % campaign_chain if campaign else "")+LEVELS[level-1].title
	pause_button.text="▶ Resume" if paused else "⏸ Pause"
	var parts=[]
	for g in goals:
		var val=goal_value(g.kind)-g.base
		parts.append("%s  %d / %d" % [g.kind.to_upper(),mini(val,int(g.amount)),g.amount])
	goal_label.text="    |    ".join(parts)
	for i in mini(goals.size(),goal_widgets.size()):
		var g=goals[i]
		var progress=mini(goal_value(g.kind)-g.base,int(g.amount))
		var widget=goal_widgets[i]
		var icon="🧬" if g.kind=="protein" else ("⚡" if g.kind=="energy" else "🧪")
		widget.title.text="%s %s REQUEST" % [icon,str(g.kind).to_upper()]
		widget.progress.text="DONE ✓" if g.get("done",false) else ("%d / %d" % [progress,g.amount])
		widget.progress.add_theme_color_override("font_color",Color("#7fd66a") if g.get("done",false) else Color.WHITE)
		widget.subtitle.text="export proteins" if g.kind=="protein" else ("generate ATP" if g.kind=="energy" else "digest waste")
		var style=goal_panels[i].get_theme_stylebox("panel").duplicate()
		style.border_color=Color("#7fd66a") if g.get("done",false) else Color("#8a7a4c")
		goal_panels[i].add_theme_stylebox_override("panel",style)
	var signature=JSON.stringify(toolbox)+("|rail" if placing=="microtubule" else "")
	if signature==toolbox_signature:return
	toolbox_signature=signature
	var slot_count=0
	for key in toolbox:
		if int(toolbox[key])>0:slot_count+=1
	var available=get_viewport_rect().size.x*0.92
	var slot_size=92
	var gap=12
	var side=14
	var vert=10
	if slot_count*slot_size+maxi(0,slot_count-1)*gap+side*2>available:
		slot_size=72;gap=8;side=10;vert=8
	if slot_count*slot_size+maxi(0,slot_count-1)*gap+side*2>available:
		slot_size=56;gap=6;side=8;vert=6
	toolbox_row.add_theme_constant_override("separation",gap)
	var panel_style=toolbox_panel.get_theme_stylebox("panel").duplicate()
	panel_style.content_margin_left=side;panel_style.content_margin_right=side;panel_style.content_margin_top=vert;panel_style.content_margin_bottom=vert
	toolbox_panel.add_theme_stylebox_override("panel",panel_style)
	var panel_width=slot_count*slot_size+maxi(0,slot_count-1)*gap+side*2
	if slot_count==0:panel_width=270
	var panel_height=slot_size+vert*2
	toolbox_panel.offset_left=-panel_width/2.0;toolbox_panel.offset_right=panel_width/2.0;toolbox_panel.offset_top=-panel_height;toolbox_panel.offset_bottom=0
	for child in toolbox_row.get_children():child.queue_free()
	if toolbox.is_empty():
		var lab=Label.new();lab.text="Finished parts from packs and protein synthesis appear here";lab.add_theme_color_override("font_color",MUTED);toolbox_row.add_child(lab)
	else:
		for key in toolbox:
			if int(toolbox[key])<=0:continue
			var button=Button.new()
			button.custom_minimum_size=Vector2(slot_size,slot_size)
			button.tooltip_text=toolbox_item_name(str(key))
			var button_style=StyleBoxFlat.new();button_style.bg_color=Color("#111a2c");button_style.border_color=GOLD if key=="microtubule" and placing=="microtubule" else Color("#2a3a55");button_style.set_border_width_all(3 if key=="microtubule" and placing=="microtubule" else 1);button_style.set_corner_radius_all(12)
			button.add_theme_stylebox_override("normal",button_style)
			var hover_style=button_style.duplicate();hover_style.border_color=GOLD;button.add_theme_stylebox_override("hover",hover_style)
			var mini_icon=ToolboxMini.new();mini_icon.kind=str(key);mini_icon.visual_font=font;mini_icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);mini_icon.mouse_filter=Control.MOUSE_FILTER_IGNORE;button.add_child(mini_icon)
			var count_label=Label.new();count_label.text=str(toolbox[key]);count_label.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT);count_label.offset_left=-25;count_label.offset_right=-4;count_label.offset_top=-23;count_label.offset_bottom=-2;count_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT;count_label.add_theme_color_override("font_color",GOLD);count_label.add_theme_font_size_override("font_size",16 if slot_size==92 else 12);count_label.mouse_filter=Control.MOUSE_FILTER_IGNORE;button.add_child(count_label)
			button.pressed.connect(select_tool.bind(str(key)))
			button.gui_input.connect(toolbox_gui_input.bind(str(key)))
			toolbox_row.add_child(button)

func build_goal_cards() -> void:
	if not is_instance_valid(goal_row):return
	goal_widgets.clear();goal_panels.clear()
	for c in goal_row.get_children():c.queue_free()
	for g in goals:
		var panel=PanelContainer.new()
		panel.custom_minimum_size=Vector2(150,62)
		var style=StyleBoxFlat.new();style.bg_color=Color("#0b111f");style.border_color=Color("#8a7a4c");style.set_border_width_all(1);style.set_corner_radius_all(8);style.set_content_margin_all(4)
		panel.add_theme_stylebox_override("panel",style)
		var lines=VBoxContainer.new();lines.add_theme_constant_override("separation",0);panel.add_child(lines)
		var title=Label.new();title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;title.add_theme_color_override("font_color",GOLD);title.add_theme_font_override("font",bold_font);title.add_theme_font_size_override("font_size",12);lines.add_child(title)
		var progress=Label.new();progress.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;progress.add_theme_color_override("font_color",Color.WHITE);progress.add_theme_font_override("font",bold_font);progress.add_theme_font_size_override("font_size",16);lines.add_child(progress)
		var subtitle=Label.new();subtitle.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;subtitle.add_theme_color_override("font_color",MUTED);subtitle.add_theme_font_size_override("font_size",10);lines.add_child(subtitle)
		goal_row.add_child(panel);goal_widgets.append({"title":title,"progress":progress,"subtitle":subtitle});goal_panels.append(panel)

func goal_value(kind: String) -> int:
	match kind:
		"protein":return int(state.exported)
		"energy":return int(state.atp_made)
		"recycle":return int(state.recycled)
	return 0
func count_mol(kind: String, inside := false) -> int:
	var n=0
	for m in mols:
		if m.type==kind and not m.dead and (not inside or m.inside):n+=1
	return n
func count_active_proteins(product: String) -> int:
	var n=0
	for m in mols:
		if m.type=="protein" and not m.dead and m.get("product","")==product and m.get("stage","")=="installed":n+=1
	return n
func toolbox_item_name(kind: String) -> String:
	var names={"glutport":"GLUT","aaport":"AA Port","motor":"Motor Protein","nakport":"Na⁺/K⁺ Pump","ca2port":"Ca²⁺ Channel","rxport":"Receptor","aquaport":"Aquaporin","erchaperone":"ER Chaperone"}
	return str(names.get(kind,kind.capitalize()))
func award_toolbox_component(kind: String,at: Vector2) -> void:
	toolbox[kind]=int(toolbox.get(kind,0))+1
	var name=toolbox_item_name(kind)
	pop(at+Vector2(0,-22),"%s READY" % name.to_upper(),Color("#315A37"))
	say("+1 %s to toolbox. Choose where to place it." % name)
	update_ui();queue_redraw()
func say(s: String) -> void:
	toast_text=s;toast_time=3.5;toast_label.text=s
func pop(p: Vector2,message: String,color := GOLD) -> void:
	pops.append({"p":p,"text":message,"color":color,"age":0.0})
func spend(n: float) -> bool:
	if state.atp<n:
		say("Not enough ATP. Feed glucose and O₂ to the mitochondrion.")
		return false
	state.atp-=n;state.adp+=n
	return true
func burn_mito() -> void:
	for o in orgs:
		if o.type!="mitochondrion":continue
		var glu: Dictionary={}
		var ox: Array=[]
		for m in mols:
			if m.dead or not m.inside:continue
			if m.type=="glucose" and m.p.distance_to(o.p)<56 and glu.is_empty():glu=m
			if m.type=="o2" and m.p.distance_to(o.p)<100.0:ox.append(m)
		if not glu.is_empty() and ox.size()>=2 and state.adp>=6:
			glu.dead=true;ox[0].dead=true;ox[1].dead=true
			record_resource_consumption("glucose")
			record_resource_consumption("o2",2.0)
			state.adp-=6
			var gain=int(round(6.0*float(ups.get("mito",1.0))))
			if state.alert>0:gain*=2
			state.atp+=gain;state.atp_made+=gain
			tutorial_event("atp_made")
			for i in 2:add_mol("co2",o.p+Vector2(randf_range(-12,12),randf_range(-12,12)),true)
			pop(o.p+Vector2(0,-30),"+%d ATP" % gain,Color("#7ee87e"))
			say("Mitochondrion: glucose + 2 O₂ + 6 ADP → %d ATP + 2 CO₂" % gain)

func _process(dt: float) -> void:
	if paused:
		queue_redraw()
		return
	dt=minf(dt,0.05)
	elapsed+=dt
	for item in pops:item.age+=dt
	pops=pops.filter(func(item):return float(item.age)<1.2)
	state.alert=maxf(0.0,float(state.alert)-dt)
	toast_time=maxf(0.0,toast_time-dt)
	if toast_time<=0:toast_label.text=""
	process_blood_flow(dt)
	process_molecules(dt)
	burn_mito()
	process_er_proteins(dt)
	process_smooth_er(dt)
	for dot in relay_dots:
		var delta: Vector2=dot.target-dot.p
		if delta.length()<20:dot.done=true
		else:dot.p+=delta.normalized()*minf(delta.length(),220.0*dt)
	relay_dots=relay_dots.filter(func(dot):return not dot.get("done",false))
	update_rails(dt)
	process_level_events(dt)
	for i in range(mols.size()-1,-1,-1):
		if mols[i].dead:mols.remove_at(i)
	update_goals()
	if continuous_mode:update_continuous_progress(dt)
	elif not campaign:check_win()
	update_ui()
	var parked=0
	for m in mols:
		if not m.dead and m.type=="glucose" and m.get("parked",false):parked+=1
	park_label.visible=parked>0
	if parked>0:park_label.text="Parked glucose: waiting O₂ %d/2, ADP %d/6" % [mini(2,count_mol("o2",true)),int(state.adp)]
	queue_redraw()

func advance_capillary(m: Dictionary,dt: float) -> void:
	match str(m.get("cap_state","")):
		"incoming_under":
			m.cap_delay=float(m.get("cap_delay",0.0))-dt
			if m.cap_delay>0:return
			m.cap_progress=minf(.5,float(m.cap_progress)+dt*.22)
			m.p=capillary_point(float(m.cap_progress))
			if m.cap_progress>=.5:
				m.cap_state="incoming_eject";m.cap_time=0.0;m.cap_origin=m.p;m.cap_target=capillary_eject_target(m)
		"incoming_eject":
			m.cap_time=minf(.7,float(m.cap_time)+dt)
			var t=float(m.cap_time)/.7
			var outward=(Vector2(m.cap_target)-Vector2(m.cap_origin)).normalized()
			m.p=Vector2(m.cap_origin).lerp(Vector2(m.cap_target),1.0-pow(1.0-t,2))
			if t>=1.0:
				if m.type in ["ca","na","water"]:
					m.cap_state="ion_seek"
				else:
					m.erase("cap_state");m.erase("cap_delay");m.erase("cap_origin");m.erase("cap_progress");m.erase("cap_time");m.erase("cap_target")
					m.cap_arrived=true
					m.v=outward*70.0+Vector2(randf_range(-12,12),randf_range(-12,12))
		"ion_seek":
			var target=port_pos(0.0)
			if m.type=="ca":
				for port in ports:
					if port.type=="ca":target=port.p;break
			m.p=Vector2(m.p).move_toward(target,150.0*dt)
			if m.p.distance_to(target)<5.0:
				m.inside=true;m.p=cam_center+(target-cam_center)*.82;m.v=Vector2.ZERO
				m.erase("cap_state");m.erase("cap_delay");m.erase("cap_origin");m.erase("cap_progress");m.erase("cap_time");m.erase("cap_target")
		"co2_seek":
			var destination=co2_exchange_edge() if m.type=="co2" else capillary_point(.5)
			var delta=destination-Vector2(m.p)
			if delta.length()<(12.0 if m.type=="co2" else 30.0):
				if m.type=="co2":
					m.cap_state="co2_wait";m.co2_wait_elapsed=0.0;m.co2_wait_limit=randf_range(8.0,15.0);m.p=destination
				else:
					m.cap_state="co2_suck";m.cap_time=0.0;m.cap_origin=m.p
				m.v=Vector2.ZERO
				return
			var seek_speed=145.0*(maxf(.1,blood_flow_multiplier) if m.type=="co2" else 1.0)
			m.v=Vector2(m.v).lerp(delta.normalized()*seek_speed,minf(1.0,dt*1.8))
			m.v+=Vector2(randf_range(-7,7),randf_range(-7,7))*sqrt(dt*60.0)
			m.p+=Vector2(m.v)*dt
			var viewport_size=get_viewport_rect().size
			m.p.x=clampf(m.p.x,22,viewport_size.x-22)
			m.p.y=clampf(m.p.y,108,viewport_size.y-22)
		"co2_wait":
			m.co2_wait_elapsed=float(m.get("co2_wait_elapsed",0.0))+dt
			var edge=co2_exchange_edge()
			var tangent=(capillary_point(.52)-capillary_point(.48)).normalized()
			m.p=edge+tangent*sin(float(m.co2_wait_elapsed)*2.0)*5.0
			if float(m.co2_wait_elapsed)>=float(m.get("co2_wait_limit",12.0)):
				m.cap_state="co2_plasma_absorb";m.cap_time=0.0;m.cap_origin=Vector2(m.p)
		"co2_rbc_capture":
			var carrier: Dictionary=m.get("rbc_carrier",{})
			if carrier.is_empty() or carrier.dead:
				m.cap_state="co2_wait";m.co2_wait_elapsed=0.0;m.co2_wait_limit=randf_range(8.0,15.0)
				m.p=co2_exchange_edge()
				return
			m.cap_time=minf(RBC_CO2_CAPTURE_SECONDS,float(m.get("cap_time",0.0))+dt)
			var t=float(m.cap_time)/RBC_CO2_CAPTURE_SECONDS
			m.p=Vector2(m.cap_origin).lerp(capillary_point(float(carrier.progress)),t*t*(3.0-2.0*t))
			if t>=1.0:
				m.dead=true
				carrier.co2_load=mini(2,int(carrier.co2_load)+1)
				carrier.co2_target={}
		"co2_plasma_absorb":
			m.cap_time=minf(.45,float(m.get("cap_time",0.0))+dt*maxf(.1,blood_flow_multiplier))
			var t=float(m.cap_time)/.45
			m.p=Vector2(m.cap_origin).lerp(capillary_point(.5),t*t*(3.0-2.0*t))
			if t>=1.0:m.cap_state="co2_descend";m.cap_time=0.0;m.cap_progress=.5
		"co2_suck":
			m.cap_time=minf(.35,float(m.cap_time)+dt)
			var t=float(m.cap_time)/.35
			m.p=Vector2(m.cap_origin).lerp(capillary_point(.5),t*t*(3.0-2.0*t))
			if t>=1.0:m.cap_state="co2_descend";m.cap_time=0.0;m.cap_progress=.5
		"co2_descend":
			m.cap_time=minf(.25,float(m.cap_time)+dt)
			m.p=capillary_point(.5)
			if m.cap_time>=.25:m.cap_state="co2_return"
		"co2_return":
			m.cap_progress=minf(1.0,float(m.cap_progress)+dt*.22*(maxf(.1,blood_flow_multiplier) if m.type=="co2" else 1.0))
			m.p=capillary_point(float(m.cap_progress))
			if m.cap_progress>=1.0:m.dead=true

func resolve_molecule_collisions() -> void:
	var screen=get_viewport_rect().size
	for pass_index in 3:
		for i in mols.size():
			var a: Dictionary=mols[i]
			if a.dead or a.get("bound",false) or not str(a.get("cap_state","")).is_empty() or not str(a.get("capture_state","")).is_empty():continue
			for j in range(i+1,mols.size()):
				var b: Dictionary=mols[j]
				if b.dead or b.get("bound",false) or b.inside!=a.inside or not str(b.get("cap_state","")).is_empty() or not str(b.get("capture_state","")).is_empty():continue
				var gap=Vector2(b.p)-Vector2(a.p)
				var hit=molecule_contact(a,b,gap)
				if hit.is_empty():continue
				var normal: Vector2=hit.normal
				var a_share=0.0 if a==dragging else 1.0
				var b_share=0.0 if b==dragging else 1.0
				var total=a_share+b_share
				if total<=0.0:continue
				a_share/=total;b_share/=total
				var separation=float(hit.overlap)+1.0
				if a_share>0.0:
					var target_a=Vector2(a.p)-normal*separation*a_share
					target_a=Vector2(clampf(target_a.x,22,screen.x-22),clampf(target_a.y,108,screen.y-22))
					a.p=free_motion_limit(a,target_a)
					if a.get("parked",false):a.parked=false
				if b_share>0.0:
					var target_b=Vector2(b.p)+normal*separation*b_share
					target_b=Vector2(clampf(target_b.x,22,screen.x-22),clampf(target_b.y,108,screen.y-22))
					b.p=free_motion_limit(b,target_b)
					if b.get("parked",false):b.parked=false
				var closing=(Vector2(a.v)-Vector2(b.v)).dot(normal)
				if closing>0.0:
					var impulse=normal*closing*1.25
					if a_share>0.0:a.v=Vector2(a.v)-impulse*a_share
					if b_share>0.0:b.v=Vector2(b.v)+impulse*b_share

func process_molecules(dt: float) -> void:
	var frame=dt*60.0
	for port in ports:
		if port.type in ["glut","aa"]:port.transport_cd=maxf(0.0,float(port.get("transport_cd",0.0))-dt)
	for m in mols:
		if m.dead or m==dragging or m.get("bound",false):continue
		if not str(m.get("capture_state","")).is_empty():
			advance_port_transit(m,dt)
			continue
		if not str(m.get("cap_state","")).is_empty():
			advance_capillary(m,dt)
			continue
		if m.type=="co2" and not m.inside:
			m.cap_state="co2_seek"
			advance_capillary(m,dt)
			continue
		if m.get("parked",false):continue
		if not m.inside and m.type in ["glucose","aa"] and attract_to_port(m,dt):continue
		var drift_target=Vector2(m.p)+Vector2(m.v)*dt
		var drift_position=capillary_motion_limit(m,drift_target)
		if drift_position.distance_squared_to(drift_target)>.01:m.v=-Vector2(m.v)*.5
		m.p=drift_position
		var drift=6.0 if m.type=="co2" else 4.5
		m.v+=Vector2(randf_range(-drift,drift),randf_range(-drift,drift))*sqrt(frame)
		if not m.inside:
			if m.type=="o2":m.v+=(cam_center-m.p)*(.03*frame*float(ups.get("o2",1.0)))
			if m.type=="k":
				var nearest_pump: Dictionary={}
				var pump_distance=INF
				for pump in ports:
					if pump.type!="nak":continue
					var distance=Vector2(m.p).distance_to(pump.p)
					if distance<pump_distance:nearest_pump=pump;pump_distance=distance
				if not nearest_pump.is_empty():m.v+=(Vector2(nearest_pump.p)-Vector2(m.p))*(.025*frame)
			m.v*=pow(.985,frame)
			if m.type=="waste" and not in_cell(m.p):
				var wdir=(m.p-cam_center).normalized()
				m.p=cam_center+Vector2(wdir.x*radius.x*.94,wdir.y*radius.y*.94)
				m.inside=true;m.v*=.5
			elif m.type=="o2" and in_cell(m.p):
				m.inside=true
				tutorial_event("oxygen_entered")
			elif m.type!="o2" and in_cell(m.p):
				var out_dir=(m.p-cam_center).normalized()
				m.p=cam_center+Vector2(out_dir.x*radius.x*1.07,out_dir.y*radius.y*1.07)
				m.v*=.5
		else:
			if m.type=="o2":
				var mitochondrion=nearest_org("mitochondrion",m.p)
				if not mitochondrion.is_empty():m.v+=(Vector2(mitochondrion.p)-Vector2(m.p))*(.015*frame)
			if m.type=="vrna":
				var rib=org("ribosome")
				if not rib.is_empty():m.v+=(rib.p-m.p)*(.05*frame)
			if m.type=="na":
				for pump in ports:
					if pump.type=="nak":m.v+=(Vector2(pump.p)-Vector2(m.p))*(.012*frame)
			if m.type=="co2":m.v+=(capillary_point(.5)-m.p)*(.004*frame)
			if not in_cell(m.p):
				if m.type=="co2":
					m.inside=false;m.v*=.4
				else:
					var in_dir=(m.p-cam_center).normalized()
					m.p=cam_center+Vector2(in_dir.x*radius.x*.94,in_dir.y*radius.y*.94)
					m.v*=-.5
			m.v*=pow(.97,frame)
		var size=get_viewport_rect().size
		m.p.x=clampf(m.p.x,22,size.x-22)
		m.p.y=clampf(m.p.y,108,size.y-22)
	resolve_molecule_collisions()

func osmotic_drive() -> float:
	var inside_ions=0
	var outside_ions=0
	for molecule in mols:
		if molecule.dead or molecule.type not in ["na","k"] or not str(molecule.get("cap_state","")).is_empty():continue
		if molecule.inside:inside_ions+=1
		else:outside_ions+=1
	return float(inside_ions-outside_ions)+float(state.get("osmotic_challenge",0.0))
func process_osmosis(dt: float) -> void:
	var drive=osmotic_drive()
	if continuous_mode:state.osmotic_challenge=maxf(0.0,float(state.get("osmotic_challenge",0.0))-dt*.15)
	var permeability=1.0
	for port in ports:
		if port.type=="aqua" and not port_damaged(port):permeability+=1.0
	for angle in cracks:permeability+=.5*float(crack_state(angle).severity)
	for water in mols:
		if water.dead or water.type!="water" or not str(water.get("cap_state","")).is_empty():continue
		var should_enter=drive>.25 and not water.inside
		var should_leave=drive<-.25 and water.inside
		if not should_enter and not should_leave:continue
		var angle=atan2((water.p.y-cam_center.y)/radius.y,(water.p.x-cam_center.x)/radius.x)
		var membrane=port_pos(angle)
		water.p=Vector2(water.p).move_toward(membrane,dt*(32.0+18.0*permeability))
		if Vector2(water.p).distance_to(membrane)>7.0:continue
		water.inside=should_enter
		water.p=cam_center+(membrane-cam_center)*(.91 if should_enter else 1.09)
		water.v=Vector2.ZERO
		if should_leave:state.pumped=int(state.pumped)+1
		tutorial_event("water_crossed")
	state.swell=clampf(float(state.swell)+dt*(drive*.0018+float(count_mol("water",true))*.0005-.003),0.0,.3)
	if drive<=0.0 and float(state.swell)<.12:state.osmotic_stable_time=float(state.osmotic_stable_time)+dt
	else:state.osmotic_stable_time=0.0
	if state.swell>=.25:show_failure("The cell burst from osmotic pressure.")
func process_na_k_pumps(dt: float) -> void:
	for pump in ports:
		if pump.type!="nak":continue
		pump.pump_cd=maxf(0.0,float(pump.get("pump_cd",0.0))-dt)
		if port_damaged(pump) or pump.pump_cd>0.0 or state.atp<1.0:continue
		var sodium: Array[Dictionary]=[]
		var potassium: Array[Dictionary]=[]
		for molecule in mols:
			if molecule.dead or not str(molecule.get("cap_state","")).is_empty():continue
			var distance=Vector2(molecule.p).distance_to(pump.p)
			if molecule.type=="na" and molecule.inside and distance<100.0:sodium.append(molecule)
			elif molecule.type=="k" and not molecule.inside and distance<120.0:potassium.append(molecule)
		if sodium.size()<3 or potassium.size()<2:continue
		if not spend(1.0):continue
		var outward=(Vector2(pump.p)-cam_center).normalized()
		for i in 3:
			sodium[i].inside=false
			sodium[i].p=capillary_clear_point(Vector2(pump.p)+outward*34.0+Vector2(-outward.y,outward.x)*float(i-1)*15.0,8.0,false)
			sodium[i].v=outward*55.0
		for i in 2:
			potassium[i].inside=true
			potassium[i].p=Vector2(pump.p)-outward*34.0+Vector2(-outward.y,outward.x)*float(i)*15.0
			potassium[i].v=-outward*25.0
		pump.pump_cd=2.0
		tutorial_event("ion_exchange")
		pop(pump.p+Vector2(0,-20),"3 Na⁺ OUT · 2 K⁺ IN",Color("#e8a05a"))

func process_level_events(dt: float) -> void:
	advance_body_condition(dt)
	if mode in ["signal","chaos"] or (continuous_mode and active_mechanics.has("combined")):
		if not state.burst_active:
			state.burst_cd-=dt
			if state.burst_cd<=0:
				state.burst_active=true;state.burst_timer=6.0;state.burst_wave+=1
				state.burst_waste_cd=0.5
				say("Threat burst %d: a wave of damage spills in!" % state.burst_wave)
		else:
			state.burst_timer-=dt;state.burst_waste_cd-=dt
			if state.burst_waste_cd<=0:
				state.burst_waste_cd=.5
				typed_waste_tick(1.2)
			if state.burst_timer<=0:
				state.burst_active=false;state.burst_cd=9.0
				if state.waste<=0 or mode=="signal":state.bursts+=1
	if mode=="chaos" or (continuous_mode and active_mechanics.has("combined")):typed_waste_tick(dt)
	if mode in ["patch","chaos"] or (continuous_mode and active_mechanics.has("repair")):
		state.crack_cd-=dt
		if state.crack_cd<=0:
			state.crack_cd=30.0 if continuous_mode else 7.0
			spawn_crack()
	if not cracks.is_empty():process_membrane_damage(dt)
	if mode=="endo" or (continuous_mode and active_mechanics.has("endocytosis")):
		state.chunk_cd-=dt
		if state.chunk_cd<=0:
			state.chunk_cd=25.0 if continuous_mode else 9.0
			spawn_outside("chunk")
	if mode=="osmosis" or (continuous_mode and active_mechanics.has("osmosis")):process_osmosis(dt)
	if mode=="starve":
		state.survived+=dt
		state.starve_waste_cd-=dt
		if state.starve_waste_cd<=0:
			state.starve_waste_cd=60.0/float(ups.get("waste",1.0))
			add_waste(2)
	if mode in ["virus","chaos"] or (continuous_mode and active_mechanics.has("virus")):process_virus(dt)
	if (mode=="ca2" or (continuous_mode and active_mechanics.has("calcium"))) and count_mol("hormone")<1:spawn_outside("hormone")
	if state.ca_timer>0:
		state.ca_timer-=dt;state.ca_spawn+=dt
		if state.ca_spawn>=.25:
			state.ca_spawn=0
			for p in ports:
				if p.type=="ca" and not port_damaged(p):
					spawn_capillary_resource("ca")
					break
	elif count_mol("ca")>0:
		for m in mols:
			if m.type=="ca" and not m.dead and state.atp>=1:
				spend(1);m.dead=true
				break
	if level in [11,12] or (continuous_mode and active_mechanics.has("homeostasis")):
		state.na_cd-=dt
		if state.na_cd<=0:
			state.na_cd=22.0 if level==12 and not continuous_mode else 18.0 if continuous_mode else 10.0
			for i in 3:spawn_capillary_resource("na",i*.12)
			for i in 2:spawn_capillary_resource("k",i*.12)
	process_na_k_pumps(dt)
	if count_mol("vrna")+count_mol("capsomer")>=10:show_failure("Too many viral parts assembled.")
	if state.atp<=0:show_failure("The cell ran out of ATP.")
	if not continuous_mode or opening_complete and not guide_active:pack_timer+=dt
	if pack_timer>=50 and not overlay.visible and (not continuous_mode or not guide_active):
		pack_timer=0;show_pack()

func typed_waste_tick(dt: float) -> void:
	state.spill_timer+=dt*float(ups.get("waste",1.0))/(1.0+float(count_active_proteins("antioxidant"))*.35)
	if state.spill_timer>=9.0:
		state.spill_timer=0.0
		add_waste(1,true)

func spawn_crack() -> void:
	if cracks.size()>=(3 if continuous_mode else 5):return
	for i in 12:
		var a=randf()*TAU
		var clear=true
		for old in cracks:
			if absf(wrapf(a-old,-PI,PI))<.5:clear=false;break
		if clear:
			cracks.append(a)
			crack_state(a)
			return

func process_virus(dt: float) -> void:
	state.virus_cd-=dt;state.rep_cd-=dt/(1.0+float(ups.get("dna_repair",0))*.3)
	if state.rep_cd<=0:
		state.rep_cd=52.0 if mode=="chaos" else 26.0
		var live=count_mol("vrna",true)
		if live>0 and live<6:
			for m in mols:
				if m.type=="vrna" and not m.dead:
					add_mol("vrna",m.p+Vector2(20,14),true)
					break
		elif state.killed<LEVELS[level-1].amount:
			# The HTML's objective otherwise becomes impossible after the last RNA is digested.
			add_mol("vrna",cam_center+Vector2(randf_range(-radius.x*.4,radius.x*.4),randf_range(-radius.y*.4,radius.y*.4)),true)
	if state.virus_cd<=0 and count_mol("vrna",true)>0:
		state.virus_cd=22.0 if mode=="chaos" else 11.0
		state.virus_hits+=1
		var amino: Dictionary={}
		for m in mols:
			if m.type=="aa" and m.inside and not m.dead:amino=m;break
		if not amino.is_empty():
			amino.dead=true
			record_resource_consumption("aa")
			if state.atp>=2:
				spend(2)
				var rib=org("ribosome")
				add_mol("capsomer",rib.p+Vector2(40,30) if not rib.is_empty() else cam_center,true)
		if state.virus_hits%2==0:add_waste(1)

func update_goals() -> void:
	var changed=false
	for g in goals:
		if g.get("done",false):continue
		if goal_value(g.kind)-g.base>=g.amount:
			g.done=true;goal_done_count+=1;changed=true
	if not changed:return
	if campaign:
		var all_done=true
		for g in goals:
			if not g.get("done",false):all_done=false
		if all_done:
			campaign_chain+=1
			var next: Array[Dictionary]=[]
			next.append({"kind":"protein","amount":2+int(floor(campaign_chain*1.5)),"base":state.exported,"done":false,"next_issued":false})
			next.append({"kind":"energy","amount":30+campaign_chain*12,"base":state.atp_made,"done":false,"next_issued":false})
			if campaign_chain>=2:next.append({"kind":"recycle","amount":1+int(floor(campaign_chain*.8)),"base":state.recycled,"done":false,"next_issued":false})
			goals=next
			say("Campaign chain %d — demand rises!" % campaign_chain)
	else:
		var fresh: Array[Dictionary]=[]
		var bump=1+int(floor(.35*goal_done_count))
		for g in goals:
			if not g.done or g.next_issued:continue
			g.next_issued=true
			var amount=int(g.amount)+bump*(8 if g.kind=="energy" else 1)
			fresh.append({"kind":g.kind,"amount":amount,"base":goal_value(g.kind),"done":false,"next_issued":false})
		goals.append_array(fresh)
		var done_cards=0
		for g in goals:
			if g.done:done_cards+=1
		if done_cards>2:
			for g in goals:
				if g.done:goals.erase(g);break
	build_goal_cards()

func check_win() -> void:
	var win=false
	match str(LEVELS[level-1].goal):
		"atp":win=state.atp>=40
		"made":win=state.made>=1
		"exported":win=state.exported>=LEVELS[level-1].amount
		"cleanup":win=state.waste<=0 and state.exported>=1
		"bursts":win=state.bursts>=3
		"patched":win=state.patched>=5
		"qc":win=state.exported>=3 and state.misfold<=0
		"engulfed":win=state.engulfed>=3
		"chaos":win=state.patched>=3 and state.killed>=4 and state.waste<=0
		"killed":win=state.killed>=8
		"osmotic_stable":win=float(state.osmotic_stable_time)>=8.0
		"survived":win=state.survived>=90
		"waves":win=state.waves>=5
	if win and not overlay.visible:
		if not beaten.has(level):beaten.append(level)
		max_unlocked=maxi(max_unlocked,mini(level+1,15))
		var cfg=ConfigFile.new();cfg.set_value("progress","max",max_unlocked);cfg.set_value("progress","beaten",beaten);cfg.save("user://inside_life_progress.cfg")
		show_message("Objective complete",LEVELS[level-1].objective,["Continue","Play Campaign"])

func toolbox_gui_input(event: InputEvent,kind: String) -> void:
	if kind=="microtubule":return
	if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and event.pressed:
		toolbox_drag_kind=kind
		toolbox_drag_start=get_viewport().get_mouse_position()
		toolbox_drag_pos=toolbox_drag_start
		update_placement_preview()
func port_tool(kind: String) -> bool:
	return kind in ["glutport","aaport","nakport","ca2port","rxport","aquaport"]
func update_placement_preview() -> void:
	if not is_instance_valid(placement_preview):return
	var kind=toolbox_drag_kind if not toolbox_drag_kind.is_empty() else placing
	if kind.is_empty() or kind=="microtubule" or paused or overlay.visible:
		placement_preview.visible=false
		return
	var point=toolbox_drag_pos if not toolbox_drag_kind.is_empty() else get_viewport().get_mouse_position()
	if port_tool(kind):point=port_pos(atan2(point.y-cam_center.y,point.x-cam_center.x))
	placement_preview.kind=kind
	placement_preview.position=point-placement_preview.size*.5
	placement_preview.visible=true
	placement_preview.queue_redraw()
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if not toolbox_drag_kind.is_empty():toolbox_drag_pos=event.position
		if not toolbox_drag_kind.is_empty() or not placing.is_empty():
			update_placement_preview()
			queue_redraw()
	elif not toolbox_drag_kind.is_empty() and event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and not event.pressed:
		var kind=toolbox_drag_kind
		toolbox_drag_kind=""
		if event.position.distance_to(toolbox_drag_start)>16 and event.position.y>96:
			placing=kind
			if kind=="microtubule":say("Microtubule selected: click output, then receiver.")
			else:place_at(event.position)
			get_viewport().set_input_as_handled()
		update_placement_preview()
		queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode in [KEY_ESCAPE,KEY_SPACE]:
			if not placing.is_empty():placing="";rail_start={};say("Placement cancelled.");update_placement_preview();update_ui();queue_redraw()
			elif not overlay.visible:toggle_pause()
	if overlay.visible:return
	if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_RIGHT and event.pressed:
		if placing=="microtubule":placing="";rail_start={};say("Rail connect mode cancelled.");update_ui();queue_redraw();return
		show_context(event.position);return
	if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT:
		var p=event.position
		if event.pressed:
			if p.y<96:return
			if not placing.is_empty():
				place_at(p);return
			if event.double_click:
				var resource=pick_mol(p,true)
				if not resource.is_empty():
					dragging={};molecule_drag_moved=false
					show_inspect(resource,true)
					return
				var carrier=pick_blood_carrier(p)
				if not carrier.is_empty():show_inspect(carrier,true);return
			var rib_hit=nearest_org("ribosome",p,21)
			if not rib_hit.is_empty():
				ribosome_drag=rib_hit;ribosome_press=p;ribosome_moved=false;drag_offset=Vector2(rib_hit.p)-p
				return
			var m=pick_mol(p)
			if not m.is_empty():
				if m.type=="vesicle" and m.get("gene","")=="s_ins":tutorial_event("vesicle_transport")
				dragging=m;drag_offset=m.p-p;molecule_drag_press=p;molecule_drag_moved=false;return
			var motor_hit=pick_motor_cargo(p)
			if not motor_hit.is_empty():
				var mt: Dictionary=motor_hit.motor
				var cargo: Dictionary=mt.cargo.duplicate(true)
				cargo.dead=false;cargo.p=rail_pos(motor_hit.rail,float(mt.p));cargo.v=Vector2.ZERO
				mols.append(cargo);mt.cargo={};mt.state="return";dragging=cargo;drag_offset=cargo.p-p;molecule_drag_press=p;molecule_drag_moved=true
				return
			var o=pick_org(p)
			if not o.is_empty():
				if o.type=="nucleus":show_genes()
				elif o.type=="ribosome":
					ribosome_drag=o;ribosome_press=p;ribosome_moved=false;drag_offset=Vector2(o.p)-p
				else:show_inspect(o)
				return
			var port=pick_port(p)
			if not port.is_empty():show_inspect(port);return
		elif not ribosome_drag.is_empty():
			if ribosome_moved:
				var nearest=nearest_org("er",Vector2(ribosome_drag.p),65)
				if not nearest.is_empty() and GENES.get(str(ribosome_drag.get("gene","")),{}).get("needs_er",false):attach_ribosome_to_er(ribosome_drag,nearest)
				elif ribosome_drag.get("state","")=="awaiting_er":say("Ribosome is free. Move it onto an ER section to translate this mRNA.")
			else:show_inspect(ribosome_drag)
			ribosome_drag={};ribosome_moved=false;queue_redraw()
		elif not dragging.is_empty():
			if molecule_drag_moved:drop_mol(dragging,dragging.p)
			dragging={};molecule_drag_moved=false
	if event is InputEventMouseMotion and not ribosome_drag.is_empty():
		if not ribosome_moved and event.position.distance_to(ribosome_press)>8.0:
			ribosome_moved=true
			detach_ribosome(ribosome_drag)
		if ribosome_moved:
			var target: Vector2=event.position+drag_offset
			var rel=Vector2((target.x-cam_center.x)/radius.x,(target.y-cam_center.y)/radius.y)
			if rel.length()>.84:rel=rel.normalized()*.84
			ribosome_drag.p=cam_center+Vector2(rel.x*radius.x,rel.y*radius.y)
			var template: Dictionary=ribosome_drag.get("template",{})
			if not template.is_empty():template.p=mrna_slot_pos(ribosome_drag)
			queue_redraw()
	if event is InputEventMouseMotion and not dragging.is_empty():
		if not molecule_drag_moved:
			if event.position.distance_to(molecule_drag_press)<5.0:return
			molecule_drag_moved=true
		var target: Vector2=event.position+drag_offset
		target=free_motion_limit(dragging,target)
		dragging.p=push_molecules_while_dragging(dragging,target);dragging.v=Vector2.ZERO
		queue_redraw()

func pick_motor_cargo(p: Vector2) -> Dictionary:
	for r in rails:
		for motor in r.motors:
			if motor.cargo.is_empty():continue
			if p.distance_to(rail_pos(r,float(motor.p)))<16:return {"rail":r,"motor":motor}
	return {}

func show_context(p: Vector2) -> void:
	context_org={};context_rail=-1;context_motor=-1
	for i in rails.size():
		var r=rails[i]
		for j in r.motors.size():
			if p.distance_to(rail_pos(r,float(r.motors[j].p)))<14:
				context_rail=i;context_motor=j;break
		if context_rail>=0:break
		if rail_distance(r,p)<18:context_rail=i;break
	if context_rail<0:
		context_org=pick_org(p)
		if context_org.is_empty() or context_org.type=="nucleus":return
	context_menu.clear()
	var remove_label="Remove and refund"
	if context_rail>=0:
		if context_motor<0:remove_label="Remove rail; refund added motors"
		elif bool(rails[context_rail].motors[context_motor].get("starter",false)):remove_label="Remove starter motor"
	context_menu.add_item(remove_label,1)
	context_menu.add_item("Keep",2)
	context_menu.position=Vector2i(p)
	context_menu.popup()

func refund_rail(r: Dictionary) -> void:
	toolbox["microtubule"]=int(toolbox.get("microtubule",0))+1
	for motor in r.motors:
		if not bool(motor.get("starter",false)):
			toolbox["motor"]=int(toolbox.get("motor",0))+1
		if not motor.cargo.is_empty():
			var cargo: Dictionary=motor.cargo
			cargo.dead=false;cargo.p=rail_pos(r,float(motor.p));cargo.v=Vector2.ZERO;mols.append(cargo)

func context_action(id: int) -> void:
	if id!=1:return
	if context_rail>=0 and context_rail<rails.size():
		var r=rails[context_rail]
		if context_motor>=0 and context_motor<r.motors.size():
			var motor=r.motors[context_motor]
			if not motor.cargo.is_empty():
				var cargo: Dictionary=motor.cargo
				cargo.dead=false;cargo.p=rail_pos(r,float(motor.p));cargo.v=Vector2.ZERO;mols.append(cargo)
			r.motors.remove_at(context_motor)
			if bool(motor.get("starter",false)):
				say("Starter motor removed.")
			else:
				toolbox["motor"]=int(toolbox.get("motor",0))+1
				say("Motor protein returned to toolbox.")
		else:
			refund_rail(r);rails.remove_at(context_rail)
			say("Microtubule and added motors returned to toolbox.")
	elif not context_org.is_empty():
		var kind=str(context_org.type)
		if kind=="ribosome":
			var template: Dictionary=context_org.get("template",{})
			if not template.is_empty():
				template.bound=false;template.p=context_org.p
			detach_ribosome(context_org)
		if kind=="er":
			for rib in orgs:
				if rib.type=="ribosome" and rib.get("bound_er",{})==context_org:detach_ribosome(rib)
			for protein in mols:
				if protein.type=="protein" and protein.get("stage","")=="in_er" and protein.get("bound_er",{})==context_org:
					protein.bound=false;protein.bound_er={};protein.stage="misfolded";protein.misfold=true;protein.p=Vector2(context_org.p)+Vector2(35,12);state.misfold+=1
		orgs.erase(context_org)
		toolbox[kind]=int(toolbox.get(kind,0))+1
		for i in range(rails.size()-1,-1,-1):
			if rails[i].out==context_org or rails[i].rec==context_org:
				refund_rail(rails[i]);rails.remove_at(i)
		say("%s returned to toolbox." % kind.capitalize())
	context_org={};context_rail=-1;context_motor=-1
	update_ui();queue_redraw()

func pick_mol(p: Vector2,include_capillary := false) -> Dictionary:
	var best: Dictionary={};var distance=1e9
	for m in mols:
		if m.dead or (m.get("bound",false) and not include_capillary):continue
		if not include_capillary and not str(m.get("capture_state","")).is_empty():continue
		if not include_capillary and not str(m.get("cap_state","")).is_empty():continue
		if include_capillary and m.get("cap_state","")=="incoming_under" and float(m.get("cap_delay",0.0))>0.0:continue
		var d=p.distance_to(m.p)
		if GAS_HITBOX.has(str(m.type)):
			var half: Vector2=GAS_HITBOX[str(m.type)]
			var gap=(p-Vector2(m.p)).abs()
			if gap.x<=half.x+3.0 and gap.y<=half.y+3.0 and d<distance:best=m;distance=d
		elif m.type=="mrna":
			var gap=(p-Vector2(m.p)).abs()
			if gap.x<=8.0 and gap.y<=16.0 and d<distance:best=m;distance=d
		elif d<float(RADII.get(m.type,8))+11 and d<distance:best=m;distance=d
	return best
func pick_blood_carrier(p: Vector2) -> Dictionary:
	var best: Dictionary={}
	var distance=INF
	for carrier in blood_carriers:
		if float(carrier.delay)>0.0:continue
		var d=p.distance_to(capillary_point(float(carrier.progress)))
		var reach=18.0 if carrier.type=="rbc" else 14.0
		if d<reach and d<distance:best=carrier;distance=d
	return best
func pick_org(p: Vector2) -> Dictionary:
	for o in orgs:
		if o.type=="ribosome" and p.distance_to(o.p)<24:return o
	var best: Dictionary={}
	var distance=46.0
	for o in orgs:
		var d=p.distance_to(o.p)
		if d<distance:best=o;distance=d
	return best
func pick_port(p: Vector2) -> Dictionary:
	for port in ports:
		if p.distance_to(port.p)<16:return port
	return {}

func er_ribosome_count(er: Dictionary) -> int:
	var count=0
	for rib in orgs:
		if rib.type=="ribosome" and rib.get("state","")=="er_bound" and rib.get("bound_er",{})==er:count+=1
	return count

func attach_ribosome_to_er(rib: Dictionary,er: Dictionary) -> bool:
	var key=str(rib.get("gene",""))
	if not GENES.has(key) or not GENES[key].needs_er:
		say("Load an ER-targeted mRNA before attaching this ribosome.")
		return false
	if er.is_empty() or er.type!="er":return false
	var occupied=0
	for other in orgs:
		if other!=rib and other.type=="ribosome" and other.get("state","")=="er_bound" and other.get("bound_er",{})==er:occupied+=1
	var attachment_slots=[Vector2(-34,-26),Vector2(0,-32),Vector2(34,-26),Vector2(-16,-39),Vector2(16,-39)]
	rib.attach_offset=attachment_slots[occupied%attachment_slots.size()]+Vector2(0,-8*int(occupied/attachment_slots.size()))
	rib.bound_er=er
	rib.state="er_bound"
	rib.p=Vector2(er.p)+Vector2(rib.attach_offset)
	var template: Dictionary=rib.get("template",{})
	if not template.is_empty():template.p=mrna_slot_pos(rib)
	say("Ribosome attached to this ER section. It is now rough ER.")
	if rib.get("gene","")=="s_ins":tutorial_event("ribosome_attached")
	return true

func detach_ribosome(rib: Dictionary) -> void:
	rib.bound_er={}
	rib.state="awaiting_er" if GENES.get(str(rib.get("gene","")),{}).get("needs_er",false) else "free"

func load_ribosome_template(rib: Dictionary,mrna: Dictionary) -> bool:
	var key=str(mrna.get("gene",""))
	if not GENES.has(key) or int(mrna.get("translations",0))<=0:
		say("This mRNA has no usable protein instructions.")
		return false
	var gene: Dictionary=GENES[key]
	var old: Dictionary=rib.get("template",{})
	if not old.is_empty() and old!=mrna:
		old.bound=false
		old.p=Vector2(rib.p)+Vector2(-32,-18)
	rib.template=mrna
	rib.gene=key
	rib.slots.clear()
	if gene.ribosome=="er_bound":
		var attached: Dictionary=rib.get("bound_er",{})
		if attached.is_empty() or not orgs.has(attached):
			rib.bound_er={}
			rib.state="awaiting_er"
		else:rib.state="er_bound"
	else:detach_ribosome(rib)
	mrna.bound=true
	mrna.p=mrna_slot_pos(rib)
	mrna.v=Vector2.ZERO
	if key=="s_ins":tutorial_event("insulin_loaded")
	if gene.needs_er and rib.state!="er_bound":say("%s mRNA loaded. Drag this ribosome onto an ER section to make rough ER." % gene.name)
	else:say("%s mRNA loaded: %d translations left." % [gene.name,int(mrna.translations)])
	return true

func translate_on_ribosome(rib: Dictionary) -> void:
	var template: Dictionary=rib.get("template",{})
	var key=str(rib.get("gene",""))
	if template.is_empty() or template.dead or not GENES.has(key):
		say("No template loaded. Bring mRNA from the nucleus first.")
		return
	var gene: Dictionary=GENES[key]
	var attached: Dictionary=rib.get("bound_er",{})
	if gene.needs_er and (rib.get("state","")!="er_bound" or attached.is_empty() or not orgs.has(attached)):
		say("Requires rough ER. Drag this ribosome onto an ER section first.")
		return
	if rib.slots.size()<3:return
	if not spend(maxi(0,2-int(ups.get("ribCost",0)))):return
	rib.slots.clear()
	state.made+=1
	if key=="s_ins":tutorial_event("insulin_synthesized")
	var position=Vector2(attached.p)+Vector2(34,12) if gene.needs_er else Vector2(rib.p)+Vector2(55,10)
	var stage="in_er" if gene.needs_er else "nascent"
	var protein=add_mol("protein",position,true,{"gene":key,"stage":stage,"destination":gene.destination,"product":gene.product,"ribosome_state":gene.ribosome,"raw":true,"folded":false,"misfold":false,"bound":gene.needs_er,"bound_er":attached if gene.needs_er else {},"fold_time":0.0})
	template.translations=int(template.translations)-1
	if template.translations<=0:
		template.dead=true
		rib.template={};rib.gene="";detach_ribosome(rib)
		say("%s made. Its mRNA finished four translations and degraded." % gene.name)
	else:
		template.p=mrna_slot_pos(rib)
		say("%s made. mRNA has %d translations left." % [gene.name,int(template.translations)])
	if gene.get("ready_at","")=="translation":finish_protein_delivery(protein,{"type":"translation","p":position})
	elif not gene.needs_er:pop(position+Vector2(0,-34),"+1 %s" % gene.name)

func er_fold_failure_chance(er: Dictionary) -> float:
	if continuous_mode and not active_mechanics.has("quality"):return 0.0
	var chance=.12 if mode=="qc" or (continuous_mode and active_mechanics.has("quality")) else (.04 if level>=4 else 0.0)
	return chance/(1.0+float(er.get("chaperones",0))*.8)

func fold_protein_in_er(protein: Dictionary,er: Dictionary) -> bool:
	var key=str(protein.get("gene",""))
	if not GENES.has(key) or not GENES[key].needs_er:
		say("This protein uses a free ribosome and does not enter the ER.")
		return false
	if protein.get("stage","")!="in_er" or protein.get("bound_er",{})!=er:return false
	if not spend(1):return false
	protein.bound=false
	protein.bound_er={}
	if randf()<er_fold_failure_chance(er):
		protein.stage="misfolded";protein.misfold=true;protein.raw=false
		state.misfold+=1
		protein.p=Vector2(er.p)+Vector2(44,20)
		pop(er.p+Vector2(0,-28),"MISFOLDED",Color("#e04a4a"))
		say("Rough ER rejected a misfolded %s. Recycle it." % GENES[key].name)
		return true
	protein.stage="folded";protein.raw=false;protein.folded=true
	if key=="s_ins":tutorial_event("insulin_folded")
	protein.source_er=er
	protein.p=Vector2(er.p)+Vector2(46,20)
	pop(er.p+Vector2(0,-28),"FOLDED",Color("#7ee89b"))
	if not GENES[key].needs_golgi:finish_protein_delivery(protein,er)
	else:say("Rough ER folded %s. Deliver it to the Golgi." % GENES[key].name)
	return true

func process_er_proteins(dt: float) -> void:
	for protein in mols:
		if protein.dead or protein.type!="protein" or protein.get("stage","")!="in_er":continue
		var er: Dictionary=protein.get("bound_er",{})
		if er.is_empty() or not orgs.has(er):continue
		protein.p=Vector2(er.p)+Vector2(34,12)
		protein.fold_time=float(protein.get("fold_time",0.0))+dt
		if protein.fold_time>=1.0 and state.atp>=1:fold_protein_in_er(protein,er)

func process_smooth_er(dt: float) -> void:
	for er in orgs:
		if er.type!="er" or er_ribosome_count(er)>0:continue
		er.lipid_timer=float(er.get("lipid_timer",0.0))+dt
		var production_time=5.0/(1.0+float(er.get("segments",0))*.3)
		if er.lipid_timer<production_time or state.atp<1 or count_mol("lipid",true)>=5:continue
		var precursor: Dictionary={}
		for molecule in mols:
			if molecule.type=="glucose" and molecule.inside and not molecule.dead and not molecule.get("parked",false):
				precursor=molecule;break
		if precursor.is_empty():continue
		er.lipid_timer=0.0
		precursor.dead=true
		record_resource_consumption("glucose")
		spend(1)
		add_mol("lipid",Vector2(er.p)+Vector2(45,16),true,{"source_er":er})
		pop(er.p+Vector2(0,-30),"LIPID MADE",Color("#c8a2e8"))
		say("Smooth ER used glucose-derived material and ATP to make a lipid.")

func package_protein_in_golgi(protein: Dictionary,golgi: Dictionary) -> bool:
	var key=str(protein.get("gene",""))
	if not GENES.has(key) or not GENES[key].needs_golgi:
		say("This protein does not use the Golgi.")
		return false
	if protein.get("stage","")!="folded":
		say("Golgi needs a properly folded protein from rough ER.")
		return false
	var packaging_lipid: Dictionary={}
	if (active_mechanics.has("repair") if continuous_mode else level>=7) and GENES[key].get("ready_at","")!="golgi":
		for molecule in mols:
			if molecule.type=="lipid" and molecule.inside and not molecule.dead:
				packaging_lipid=molecule;break
		if packaging_lipid.is_empty():
			say("Golgi needs a lipid from smooth ER to form this vesicle.")
			return false
	if not spend(1):return false
	if not packaging_lipid.is_empty():packaging_lipid.dead=true
	var gene: Dictionary=GENES[key]
	if gene.get("ready_at","")=="golgi":return finish_protein_delivery(protein,golgi)
	protein.dead=true;protein.stage="golgi_processed"
	if key=="s_ins":tutorial_event("insulin_packaged")
	add_mol("vesicle",Vector2(golgi.p)+Vector2(-42,-10),true,{"gene":key,"destination":gene.destination,"cargo":gene.product,"stage":"vesicle"})
	pop(golgi.p+Vector2(0,-28),"%s vesicle" % gene.name)
	say("Golgi packaged %s for %s." % [gene.name,gene.destination])
	return true

func finish_protein_delivery(cargo: Dictionary,target: Dictionary) -> bool:
	var key=str(cargo.get("gene",""))
	if not GENES.has(key):return false
	if cargo.get("misfold",false):
		say("This protein misfolded and cannot perform its destination job.")
		return false
	var gene: Dictionary=GENES[key]
	var destination=str(gene.destination)
	var target_type=str(target.get("type",""))
	if gene.has("toolbox_item") and target_type==str(gene.get("ready_at","")):
		if target_type=="membrane" and cargo.type!="vesicle":return false
		if target_type=="golgi" and (cargo.type!="protein" or cargo.get("stage","")!="folded"):return false
		if target_type=="er" and (cargo.type!="protein" or cargo.get("stage","")!="folded"):return false
		if target_type=="translation" and cargo.type!="protein":return false
		cargo.dead=true;cargo.stage="ready"
		award_toolbox_component(str(gene.toolbox_item),Vector2(target.p))
		return true
	if destination=="outside" and target_type=="membrane" and cargo.type=="vesicle":
		cargo.dead=true;cargo.stage="exported";state.exported+=1
		if key=="s_ins":tutorial_event("insulin_exported")
		var p: Vector2=target.p
		add_mol("exported_protein",p,false,{"gene":key,"folded":true,"cap_state":"co2_seek","v":Vector2.ZERO})
		pop(p+Vector2(0,-14),"%s EXPORTED" % str(gene.product).to_upper(),Color("#7ee89b"))
		say("%s exported through the membrane." % gene.name)
		return true
	if destination=="lysosome" and target_type=="lysosome" and cargo.type=="vesicle":
		cargo.dead=true;cargo.stage="installed"
		var enzyme_class=str(gene.get("enzyme_class","protein"))
		var enzyme_counts: Dictionary=target.get("enzyme_counts",{})
		enzyme_counts[enzyme_class]=int(enzyme_counts.get(enzyme_class,0))+1
		target.enzyme_counts=enzyme_counts
		target.enzymes=int(target.get("enzymes",0))+1
		pop(target.p+Vector2(0,-28),"PROTEASE INSTALLED",Color("#7ee89b"))
		say("Protein-digesting enzyme installed in this lysosome.")
		return true
	if destination=="cytoplasm" and target_type=="cytoplasm" and cargo.type=="protein":
		if cargo.get("stage","")=="installed":return false
		cargo.stage="installed";cargo.raw=false
		pop(cargo.p+Vector2(0,-22),"ACTIVE %s" % gene.name,Color("#7ee89b"))
		say("%s remains active where you placed it in the cytoplasm." % gene.name)
		return true
	if destination=="crack" and target_type=="crack" and cargo.type=="protein":
		if apply_crack_repair(float(target.angle),"protein",target.p):
			cargo.dead=true;cargo.stage="installed"
			return true
		return false
	if destination=="nucleus" and target_type=="nucleus" and cargo.type=="protein":
		cargo.dead=true;cargo.stage="installed";ups.dna_repair=int(ups.get("dna_repair",0))+1
		pop(target.p+Vector2(0,-35),"DNA REPAIR",Color("#7ee89b"))
		say("DNA repair protein imported into the nucleus.")
		return true
	return false

func drop_mol(m: Dictionary,p: Vector2) -> void:
	m.p=p;m.v=Vector2.ZERO
	var kind=str(m.type)
	var r=edge_ratio(p)
	var nuc=nearest_org("nucleus",p,56)
	if kind=="protein" and not nuc.is_empty() and GENES.has(str(m.get("gene",""))) and GENES[m.gene].destination=="nucleus":
		finish_protein_delivery(m,nuc)
		return
	if not nuc.is_empty():show_genes();return
	if kind in ["o2","co2"]:m.inside=in_cell(p);return
	if kind=="glucose" and not m.inside:
		for port in ports:
			if port.type=="glut" and p.distance_to(port.p)<30:
				if port_damaged(port):say("This GLUT port is blocked by membrane damage.");return
				m.p=port_dock_point(port,kind)
				if bind_molecule_to_port(m,port):say("GLUT transporter caught glucose.")
				else:say("GLUT transporter is finishing another molecule.")
				return
		if absf(r-1)<.12:say("Glucose must use a yellow GLUT port.")
		return
	if kind=="aa" and not m.inside:
		for port in ports:
			if port.type=="aa" and p.distance_to(port.p)<30:
				if port_damaged(port):say("This AA port is blocked by membrane damage.");return
				m.p=port_dock_point(port,kind)
				if bind_molecule_to_port(m,port):say("AA transporter caught an amino acid.")
				else:say("AA transporter is finishing another molecule.")
				return
		if absf(r-1)<.12:say("Amino acids must use a pink channel port.")
		return
	if kind=="hormone" and not m.inside:
		for port in ports:
			if port.type=="rx" and p.distance_to(port.p)<30:
				if port_damaged(port):say("This receptor is blocked by membrane damage.");return
				m.dead=true;state.alert=20.0;state.ca_timer=3.0;state.waves+=1;state.signals_relayed+=1
				tutorial_event("signal_received")
				tutorial_event("calcium_spark")
				var nucleus=org("nucleus")
				if not nucleus.is_empty():relay_dots.append({"p":port.p,"target":nucleus.p,"done":false})
				pop(port.p+Vector2(0,-30),"Ca²⁺ SPARK",Color("#ffe066"))
				say("Signal relayed! Alert mode for 20 seconds; calcium spark triggered.");return
		return
	if kind=="chunk" and not m.inside and absf(r-1)<.3:
		m.dead=true;add_mol("endoves",cam_center+(p-cam_center)*.8,true);tutorial_event("chunk_engulfed");pop(p+Vector2(0,-14),"ENGULFED",Color("#d8b86a"));say("Endocytosis: chunk engulfed. Bring the vesicle to a lysosome.");return
	if kind=="water" and absf(r-1)<.25:
		say("Water crosses passively when the solute gradient favors it. Aquaporins speed that flow.");return
	if kind=="vesicle" and m.inside:
		var vesicle_gene=str(m.get("gene",""))
		if not GENES.has(vesicle_gene):say("This vesicle has no protein cargo instructions.");return
		var destination=str(GENES[vesicle_gene].destination)
		if absf(r-1)<.14:
			if destination in ["outside","membrane"]:
				if spend(2):finish_protein_delivery(m,{"type":"membrane","p":p})
			else:say("This vesicle is destined for a lysosome, not the membrane.")
			return
		var destination_ly=nearest_org("lysosome",p,48)
		if not destination_ly.is_empty():
			if destination=="lysosome":
				if spend(2):finish_protein_delivery(m,destination_ly)
			else:say("This vesicle belongs at the cell membrane.")
			return
	if kind in ["lipid","lipoves"] and m.inside and absf(r-1)<.25:
		var angle=atan2((p.y-cam_center.y)/radius.y,(p.x-cam_center.x)/radius.x)
		for a in cracks:
			if absf(wrapf(angle-a,-PI,PI))<.35:
				if apply_crack_repair(a,"lipid",p):m.dead=true
				return
		if kind=="lipid" and int(state.get("membrane_growth",0))<5:
			m.dead=true;state.membrane_growth=int(state.membrane_growth)+1
			radius*=1.015
			for port in ports:port.p=port_pos(port.a)
			for rail in rails:rebuild_rail_path(rail)
			pop(p+Vector2(0,-14),"MEMBRANE EXPANDED",Color("#c8a2e8"))
			say("Lipid expanded the cell membrane.")
			return
	if kind=="protein" and GENES.has(str(m.get("gene",""))):
		var protein_gene: Dictionary=GENES[m.gene]
		if protein_gene.destination=="crack" and absf(r-1)<.25:
			var angle=atan2((p.y-cam_center.y)/radius.y,(p.x-cam_center.x)/radius.x)
			for a in cracks:
				if absf(wrapf(angle-a,-PI,PI))<.35:
					finish_protein_delivery(m,{"type":"crack","angle":a,"p":p})
					return
		if m.get("misfold",false):
			for other in mols:
				if other.type=="protein" and other.get("product","")=="proteasome" and other.get("stage","")=="installed" and p.distance_to(other.p)<38:
					m.dead=true;state.misfold=maxi(0,int(state.misfold)-1);say("Proteasome degraded the damaged protein.");return
	var mito=nearest_org("mitochondrion",p,90)
	if kind=="glucose" and m.inside and not mito.is_empty():
		m.p=mito.p+Vector2(32,24);m.v=Vector2.ZERO;m.parked=true
		burn_mito()
		if not m.dead:say("Glucose parked at mitochondrion; needs 2 O₂ and 6 ADP.")
		return
	var rib=nearest_org("ribosome",p,44)
	if not rib.is_empty() and m.inside:
		if kind=="mrna":load_ribosome_template(rib,m);return
		if kind=="aa":
			if rib.get("template",{}).is_empty() or not GENES.has(str(rib.get("gene",""))):
				m.p=Vector2(rib.p)+Vector2(0,34)
				say("No template loaded. Bring mRNA from the nucleus first.")
				return
			if GENES[rib.gene].needs_er and rib.get("state","")!="er_bound":
				m.p=Vector2(rib.p)+Vector2(0,34)
				say("Attach this ribosome to an ER section before feeding it amino acids.")
				return
			if rib.slots.size()>=2 and state.atp<maxi(0,2-int(ups.get("ribCost",0))):
				m.p=Vector2(rib.p)+Vector2(0,34)
				say("The ribosome needs ATP before it can complete this protein.")
				return
			m.dead=true;rib.slots.append(1)
			if rib.get("gene","")=="s_ins":tutorial_event("aa_supplied")
			record_resource_consumption("aa")
			if rib.slots.size()>=3:translate_on_ribosome(rib)
			else:say("Ribosome amino acids: %d/3." % rib.slots.size())
			return
	var er=nearest_org("er",p,48)
	if not er.is_empty() and m.inside:
		if kind=="lipid" and (active_mechanics.has("repair") if continuous_mode else level>=7):
			m.dead=true;er.segments=int(er.get("segments",0))+1
			pop(er.p+Vector2(0,-30),"ER EXPANDED",Color("#c8a2e8"))
			say("Lipid expanded this ER section; smooth ER here produces lipids faster.")
			return
		if kind=="protein":
			say("ER-targeted proteins enter rough ER during translation; free proteins stay in the cytoplasm.")
			return
	var gol=nearest_org("golgi",p,48)
	if not gol.is_empty() and kind=="protein":
		package_protein_in_golgi(m,gol);return
	var ly=nearest_org("lysosome",p,48)
	if not ly.is_empty() and m.inside:
		if kind=="waste":
			if ly.has("enzyme") and ly.enzyme!=m.get("sub","protein"):
				say("Wrong enzyme. Match the waste color to its lysosome.");return
			var enzyme_bonus=int(ly.get("enzyme_counts",{}).get(str(m.get("sub","protein")),0))
			if spend(maxf(0.0,1.0-.5*float(enzyme_bonus))):
				m.dead=true;state.waste-=1;state.recycled+=1
				tutorial_event("waste_recycled")
				if ly.has("enzyme"):tutorial_event("typed_waste_recycled")
				var product="aa"
				if mode not in ["enz","chaos"]:
					if m.get("sub","protein")=="sugar":product="glucose"
					elif m.get("sub","protein")=="lipid":product="lipid"
				add_mol(product,ly.p+Vector2(30,0),true)
				say("Lysosome digested waste and recycled %s." % product)
			return
		if kind in ["vrna","capsomer"] and spend(1):
			m.dead=true;state.killed+=1;tutorial_event("virus_destroyed");say("Viral part destroyed.");return
		if kind=="protein" and m.get("misfold",false) and spend(maxf(0.0,1.0-.5*float(ly.get("enzyme_counts",{}).get("protein",0)))):
			m.dead=true;state.misfold-=1;tutorial_event("misfold_recycled");say("Misfolded chain destroyed.");return
		if kind=="endoves" and spend(1):
			m.dead=true;state.engulfed+=1
			tutorial_event("chunk_digested")
			for i in 3:add_mol("glucose",ly.p+Vector2(randf_range(-20,20),randf_range(-20,20)),true)
			for i in 2:add_mol("aa",ly.p+Vector2(randf_range(-20,20),randf_range(-20,20)),true)
			say("Nutrient chunk digested: +3 glucose, +2 AAs.");return
	if kind=="protein" and GENES.has(str(m.get("gene",""))) and GENES[m.gene].destination=="cytoplasm":
		finish_protein_delivery(m,{"type":"cytoplasm"})
		return
	if m.inside and not in_cell(p):m.p=cam_center+(p-cam_center)*.9

func rail_radius(o: Dictionary) -> float:
	match str(o.type):
		"nucleus":return 42
		"mitochondrion":return 36
		"er":return 44
		"golgi":return 30
		"lysosome":return 22
		"ribosome":return 18
	return 9

func rail_source_edge(source: Dictionary,toward: Vector2) -> Vector2:
	var center: Vector2=source.p
	var direction=(toward-center).normalized()
	if direction.length_squared()<.001:direction=Vector2.RIGHT
	var reach=rail_radius(source)
	var ellipse=Vector2.ZERO
	var rotation=0.0
	match str(source.type):
		"mitochondrion":ellipse=Vector2(36,22);rotation=.4
		"er":ellipse=Vector2(44,24);rotation=.6
		"golgi":ellipse=Vector2(30,22);rotation=.15
	if ellipse!=Vector2.ZERO:
		var local=direction.rotated(-rotation)
		reach=1.0/sqrt(pow(local.x/ellipse.x,2)+pow(local.y/ellipse.y,2))
	return center+direction*(reach+(1.0 if source.type=="golgi" else 6.0))

func rebuild_rail_path(r: Dictionary) -> void:
	var start: Vector2=rail_source_edge(r.out,Vector2(r.rec.p))
	var finish: Vector2=r.rec.p
	var points: Array[Vector2]=[start]
	var cursor=start
	for guard in 24:
		var nearest: Dictionary={}
		var near_t=2.0
		var segment=finish-cursor
		var length=maxf(segment.length(),1)
		for o in orgs:
			if o==r.out or o==r.rec:continue
			if cursor.distance_to(o.p)<rail_radius(o)+10 or finish.distance_to(o.p)<rail_radius(o)+10:continue
			var t=(o.p-cursor).dot(segment)/(length*length)
			if t<=.03 or t>=.97 or t>=near_t:continue
			if o.p.distance_to(cursor+segment*t)<rail_radius(o)+14:
				nearest=o;near_t=t
		if nearest.is_empty():break
		var normal=Vector2(-segment.y,segment.x)/length
		var side=-1.0 if normal.dot(nearest.p-cursor)>=0 else 1.0
		var offset=rail_radius(nearest)+30.0
		points.append(cursor+segment*maxf(.02,near_t-offset/length)+normal*offset*side)
		points.append(cursor+segment*minf(.98,near_t+offset/length)+normal*offset*side)
		cursor=points[-1]
	points.append(finish)
	for iteration in 2:
		var smooth: Array[Vector2]=[points[0]]
		for i in points.size()-1:
			smooth.append(points[i].lerp(points[i+1],.25))
			smooth.append(points[i].lerp(points[i+1],.75))
		smooth.append(points[-1])
		points=smooth
	for pass_no in 3:
		for i in range(1,points.size()-1):
			var p=points[i]
			for o in orgs:
				if o==r.out or o==r.rec:continue
				var delta=p-o.p
				var safe=rail_radius(o)+14
				if delta.length()<safe:p=o.p+delta.normalized()*safe if delta.length()>0.01 else o.p+Vector2(safe,0)
			if edge_ratio(p)>1.04:
				var radial=Vector2((p.x-cam_center.x)/radius.x,(p.y-cam_center.y)/radius.y).normalized()
				p=cam_center+Vector2(radial.x*radius.x*.98,radial.y*radius.y*.98)
			points[i]=p
	points[0]=start;points[-1]=finish
	r.waypoints=points
	var total=0.0
	for i in points.size()-1:total+=points[i].distance_to(points[i+1])
	r.length=maxf(total,1.0)

func rail_pos(r: Dictionary,t: float) -> Vector2:
	var points: Array=r.waypoints
	var remaining=clampf(t,0,1)*float(r.length)
	for i in points.size()-1:
		var seg: Vector2=points[i+1]-points[i]
		var seg_len=seg.length()
		if remaining<=seg_len or i==points.size()-2:
			return points[i]+seg*(remaining/maxf(seg_len,1))
		remaining-=seg_len
	return points[-1]

func rail_distance(r: Dictionary,p: Vector2) -> float:
	var best=INF
	var points: Array=r.waypoints
	for i in points.size()-1:
		best=minf(best,p.distance_to(Geometry2D.get_closest_point_to_segment(p,points[i],points[i+1])))
	return best

func make_rail(out: Dictionary,rec: Dictionary) -> Dictionary:
	var r={"out":out,"rec":rec,"motors":[{"p":0.0,"state":"idle","cargo":{},"stalled":false,"starter":true}],"waypoints":[],"length":1.0}
	rebuild_rail_path(r)
	rails.append(r)
	if out.get("type","")=="golgi":tutorial_event("rail_created")
	return r

func rail_pickup(r: Dictionary,motor: Dictionary) -> void:
	var source: Dictionary=r.out
	if source.type in ["ribosome","er","golgi"] and float(source.get("out_cd",0.0))>0:return
	var desired: Array[String]=[]
	match str(source.type):
		"ribosome":desired=["protein"]
		"er":desired=["protein"]
		"golgi":desired=["vesicle"]
		"aa":desired=["aa"]
		"glut":desired=["glucose","o2"]
	if desired.is_empty():return
	for m in mols:
		if m.dead or m==dragging or m.get("bound",false) or not m.inside or not desired.has(str(m.type)):continue
		if r.rec.type=="mitochondrion" and m.type=="o2":continue
		if m.p.distance_to(source.p)>(95 if source.type in ["aa","glut"] else 60):continue
		if source.type=="ribosome" and (m.get("stage","")!="nascent" or GENES.get(m.get("gene",""),{}).get("needs_er",false)):continue
		if source.type=="er" and (m.get("stage","")!="folded" or m.get("source_er",{})!=source or not GENES.get(m.get("gene",""),{}).get("needs_golgi",false)):continue
		m.dead=true
		motor.cargo=m.duplicate(true)
		motor.cargo.dead=false
		motor.state="carry"
		motor.p=0.0
		if source.type in ["ribosome","er","golgi"]:source.out_cd=1.5
		break

func rail_deliver(r: Dictionary,motor: Dictionary) -> void:
	var cargo: Dictionary=motor.cargo
	cargo.dead=false;cargo.inside=true;cargo.p=r.rec.p;cargo.v=Vector2.ZERO
	mols.append(cargo)
	motor.cargo={};motor.state="return"
	drop_mol(cargo,r.rec.p)

func update_rails(dt: float) -> void:
	for o in orgs:
		if float(o.get("out_cd",0.0))>0:o.out_cd=maxf(0.0,float(o.out_cd)-dt)
	for r in rails:
		if not r.has("waypoints") or r.waypoints.size()<2:rebuild_rail_path(r)
		for motor in r.motors:
			if motor.state=="idle":rail_pickup(r,motor)
			elif motor.state=="carry":
				var step=dt*40.0*float(ups.get("ves",1.0))/float(r.length)
				var cost=step*.5
				if state.atp>=cost:
					spend(cost)
					motor.p=minf(1.0,float(motor.p)+step)
					motor.stalled=false
					if motor.p>=1.0:rail_deliver(r,motor)
				elif not motor.stalled:
					motor.stalled=true;say("Motor stalled: recharge ATP at the mitochondrion.")
			elif motor.state=="return":
				motor.p=maxf(0.0,float(motor.p)-dt*55.0/float(r.length))
				if motor.p<=0:
					motor.state="idle";motor.stalled=false

func select_tool(kind: String) -> void:
	if kind=="microtubule":
		if placing=="microtubule":
			placing="";rail_start={};say("Rail connect mode cancelled.")
		elif int(toolbox.get("microtubule",0))>0:
			placing="microtubule";rail_start={}
			say("Connect mode: click the OUTPUT organelle or port, then the RECEIVER or membrane edge.")
		else:say("No microtubules left in the toolbox.")
	else:
		placing=kind;rail_start={};say("Click to place %s." % toolbox_item_name(kind))
	update_placement_preview()
	update_ui();queue_redraw()
func place_at(p: Vector2) -> void:
	var completed_rail=placing=="microtubule"
	if placing=="microtubule":
		if rail_start.is_empty():
			rail_start=pick_org(p)
			if rail_start.is_empty():rail_start=pick_port(p)
			if rail_start.is_empty():say("Pick an organelle or a PORT as the rail's OUTPUT end.")
			else:say("Now click a DIFFERENT organelle, port, or the membrane edge to connect.")
			queue_redraw()
			return
		var target=pick_org(p)
		if target.is_empty():target=pick_port(p)
		if not target.is_empty() and target==rail_start:target={}
		if target.is_empty() and edge_ratio(p)>.85 and edge_ratio(p)<1.15:
			target={"type":"membrane","p":port_pos(atan2(p.y-cam_center.y,p.x-cam_center.x))}
		if target.is_empty():say("Connect to a DIFFERENT organelle or the membrane edge.");return
		make_rail(rail_start,target)
		rail_start={};say("Microtubule rail connected with a starter motor. Add more motors for extra capacity.")
	elif placing=="motor":
		var closest: Dictionary={}
		var distance=40.0
		for r in rails:
			var d=rail_distance(r,p)
			if d<distance:distance=d;closest=r
		if closest.is_empty():say("Drop the motor on a microtubule rail.");return
		closest.motors.append({"p":0.0,"state":"idle","cargo":{},"stalled":false,"starter":false})
		tutorial_event("motor_placed")
	elif placing=="erchaperone":
		var target_er=nearest_org("er",p,54)
		if target_er.is_empty():say("Place this chaperone on the ER section you want to improve.");return
		target_er.chaperones=int(target_er.get("chaperones",0))+1
		pop(target_er.p+Vector2(0,-28),"CHAPERONE INSTALLED",Color("#315A37"))
	elif placing in ["glutport","aaport","nakport","ca2port","rxport","aquaport"]:
		if absf(edge_ratio(p)-1.0)>.18:
			say("Cancelled - release on the outlined membrane ring to place a port.")
			placing="";update_placement_preview();queue_redraw()
			return
		var port_types={"glutport":"glut","aaport":"aa","nakport":"nak","ca2port":"ca","rxport":"rx","aquaport":"aqua"}
		var placed_kind=placing
		add_port(str(port_types[placing]),atan2(p.y-cam_center.y,p.x-cam_center.x))
		if placed_kind=="nakport":tutorial_event("pump_placed")
		if placed_kind=="aquaport":tutorial_event("aquaporin_placed")
	elif in_cell(p):orgs.append({"type":placing,"p":p,"home_p":p,"slots":[],"gene":"","template":{},"state":"free"})
	else:say("Place organelles inside the cell.");return
	toolbox[placing]=int(toolbox.get(placing,0))-1
	if toolbox[placing]<=0:toolbox.erase(placing)
	var placed_name=toolbox_item_name(placing)
	placing=""
	update_placement_preview()
	if not completed_rail:say("%s placed." % placed_name)
	update_ui()

func toggle_pause() -> void:
	paused=not paused
	if is_instance_valid(inspect_panel):inspect_panel.visible=false
	update_placement_preview()
	update_ui();queue_redraw()
func set_overlay_size(size: Vector2) -> void:
	overlay.custom_minimum_size=size
	overlay.offset_left=-size.x*.5
	overlay.offset_right=size.x*.5
	overlay.offset_top=-size.y*.5
	overlay.offset_bottom=size.y*.5
func show_message(heading: String,body: String,buttons: Array[String]) -> void:
	paused=true;overlay.visible=true;set_overlay_size(Vector2(560,240))
	update_placement_preview()
	set_overlay_look(false)
	for c in overlay_body.get_children():c.queue_free()
	var h=Label.new();h.text=heading;h.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;h.add_theme_color_override("font_color",GOLD);h.add_theme_font_size_override("font_size",22);overlay_body.add_child(h)
	var b=Label.new();b.text=body;b.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;b.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;b.custom_minimum_size=Vector2(500,55);overlay_body.add_child(b)
	for name in buttons:
		var button=Button.new();button.text=name;button.pressed.connect(overlay_action.bind(name));overlay_body.add_child(button)
func overlay_action(name: String) -> void:
	match name:
		"Continue":start_level(mini(level+1,15))
		"Try again":
			if continuous_mode:start_continuous()
			else:start_level(level)
		"Play Campaign":
			close_overlay();paused=false;campaign=true;campaign_chain=1
			goals=[{"kind":"protein","amount":3,"base":state.exported,"done":false,"next_issued":false},{"kind":"energy","amount":42,"base":state.atp_made,"done":false,"next_issued":false}]
			build_goal_cards()
			say("Campaign started: complete the output goals to raise demand.")
		"Close":close_overlay();paused=false

		_:
			if name.begins_with("Gene Class: "):
				show_gene_group(name.trim_prefix("Gene Class: "))
			elif name.begins_with("Gene: "):
				transcribe_gene(name.trim_prefix("Gene: "))
			elif pack_rolls.has(name):
				for effect in pack_rolls[name]:apply_pack_effect(effect)
				pack_rolls.clear();close_overlay();update_ui()
			elif name.begins_with("Level "):start_level(int(name.trim_prefix("Level ")))
func close_overlay() -> void:
	if is_instance_valid(overlay):overlay.visible=false
	update_placement_preview()
	if is_instance_valid(inspect_panel):inspect_panel.visible=false
	pack_menu_open=false
	if is_instance_valid(overlay_body):overlay_body.add_theme_constant_override("separation",10)
	if is_instance_valid(overlay_margin):
		for edge in ["left","right"]:overlay_margin.add_theme_constant_override("margin_"+edge,28)
		for edge in ["top","bottom"]:overlay_margin.add_theme_constant_override("margin_"+edge,22)
	paused=false
func show_failure(message: String) -> void:
	if overlay.visible:return
	show_message("Cell death",message,["Try again"])
func show_inspect(item: Dictionary,is_resource := false) -> void:
	inspect_panel.visible=true
	if is_resource:
		var names={"glucose":"Glucose","o2":"O₂","co2":"CO₂","aa":"Amino Acid","hormone":"Adrenaline","water":"Water","na":"Sodium Ion","k":"Potassium Ion","ca":"Calcium Ion","mrna":"mRNA","protein":"Protein","exported_protein":"Exported Protein","vesicle":"Transport Vesicle","waste":"Waste","lipid":"Lipid","lipoves":"Lipid Vesicle","chunk":"Nutrient Chunk","endoves":"Endocytic Vesicle","vrna":"Viral RNA","capsomer":"Viral Capsomer","rbc":"Red Blood Cell","plasma":"Plasma Packet"}
		var details={"glucose":"Cell fuel. Bring it through a GLUT port, then to a mitochondrion with O₂ to make ATP.","o2":"Oxygen diffuses through the cell wall. Mitochondria use it with glucose to make ATP.","co2":"Carbon dioxide is produced during respiration. It leaves through the cell wall and exits through the capillary.","aa":"Amino acids enter through an AA port. A ribosome uses three to build one protein.","hormone":"Adrenaline docks at a receptor on the cell wall to trigger alert mode.","water":"Water crosses the membrane passively toward the side with more solute. Aquaporins speed it without ATP.","na":"Each Na⁺/K⁺ pump cycle moves three intracellular Na⁺ out and two extracellular K⁺ in using one ATP.","k":"Potassium enters through Na⁺/K⁺ pumps, two ions per ATP-fueled cycle.","ca":"Calcium enters during a receptor-triggered spark and is pumped back out.","mrna":"An instruction transcribed by the nucleus. Load it into a ribosome to choose which protein is made.","protein":"A translated protein. Its gene and processing stage determine where it goes.","exported_protein":"A finished secreted protein traveling to the capillary exit.","vesicle":"Golgi-packaged cargo. Deliver it to its destination to finish processing.","waste":"Damaged material. Deliver it to a matching lysosome to recycle it.","lipid":"Smooth ER makes this from glucose and ATP. Use it for vesicles, repair, or growth.","lipoves":"A lipid carrier for membrane repair.","chunk":"A large nutrient particle that must be engulfed before digestion.","endoves":"An engulfed nutrient carrier. Deliver it to a lysosome.","vrna":"Viral RNA can hijack a ribosome. Destroy it in a lysosome.","capsomer":"A viral protein component. Destroy it in a lysosome.","rbc":"Carries O₂ through the capillary, releases it near the cell, and can collect CO₂ before flowing away.","plasma":"Carries dissolved glucose and amino acids. It may release either, both, or neither near the cell."}
		var kind=str(item.type)
		inspect_heading.text=str(names.get(kind,kind.capitalize()))
		inspect_description.text=str(details.get(kind,"A molecule in the cell environment."))
		inspect_description.text+="\nLocation: %s" % ("inside capillary" if kind in ["rbc","plasma"] else ("inside cell" if item.inside else "outside cell"))
		if kind=="rbc":inspect_description.text+="\nO₂ remaining: %d / %d · CO₂ collected: %d" % [int(item.oxygenation),int(item.payload.o2),int(item.co2_load)]
		if kind=="plasma":inspect_description.text+="\nCargo: %d glucose, %d amino acids" % [int(item.payload.get("glucose",0)),int(item.payload.get("aa",0))]
		var gene_key=str(item.get("gene",""))
		if GENES.has(gene_key):inspect_description.text+="\nGene: %s" % str(GENES[gene_key].name)
		if item.has("stage"):inspect_description.text+="\nStage: %s" % str(item.stage).replace("_"," ")
		if kind=="mrna":inspect_description.text+="\nTranslations remaining: %d" % int(item.get("translations",0))
		if kind=="waste":inspect_description.text+="\nType: %s" % str(item.get("sub","protein"))
		if item.get("misfold",false):inspect_description.text+="\nMisfolded: recycle in a lysosome."
		queue_redraw()
		return
	inspect_heading.text=str(item.type).capitalize()
	var descriptions={
		"nucleus":"Holds the DNA library. Drop a molecule here to choose a gene and transcribe mRNA (2 ATP).",
		"mitochondrion":"Recharges ADP to ATP. Bring glucose here with 2 oxygen molecules inside the cell and 6 ADP available.",
		"ribosome":"Load mRNA, then feed 3 amino acids. For ER-targeted mRNA, drag this ribosome onto an ER section before translation; drag it away to detach.",
		"er":"Attached ribosomes make this section rough: it folds ER-targeted proteins. Without ribosomes it makes lipids from intracellular glucose and ATP.",
		"golgi":"Processes ER-folded cargo and packages destination-specific vesicles.",
		"lysosome":"Digests waste, damaged protein and viral parts, recycling useful material.",
		"glut":"Yellow GLUT transporter: gently captures nearby glucose, then carries it across without directly spending ATP.",
		"aa":"Pink amino acid transporter: captures nearby AAs and carries them across the membrane.",
		"rx":"Green receptor: adrenaline docks here and relays a stress signal to the nucleus.",
		"ca":"Calcium channel: opens briefly after a receptor signal and releases a calcium spark.",
		"nak":"Na⁺/K⁺ pump: spends 1 ATP to move 3 Na⁺ out and 2 K⁺ in.",
		"aqua":"Aquaporin: increases passive water permeability without using ATP."}
	inspect_description.text=descriptions.get(item.type,"")
	if item.has("enzyme"):inspect_description.text+="\nFixed enzyme: "+str(item.enzyme).to_upper()
	if item.type=="lysosome":inspect_description.text+="\nInstalled proteases: %d" % int(item.get("enzyme_counts",{}).get("protein",0))
	if item.type=="ribosome":
		var template: Dictionary=item.get("template",{})
		inspect_description.text+="\nState: "+str(item.get("state","free")).replace("_"," ")
		inspect_description.text+="\nTemplate: "+(str(GENES.get(item.get("gene",""),{}).get("name","none")))
		if not template.is_empty():inspect_description.text+=" · %d translations left" % int(template.get("translations",0))
	if item.type=="er":
		inspect_description.text+="\nState: %s · Attached ribosomes: %d" % ["rough" if er_ribosome_count(item)>0 else "smooth",er_ribosome_count(item)]
		inspect_description.text+="\nLocal chaperones: %d · Extra ER segments: %d" % [int(item.get("chaperones",0)),int(item.get("segments",0))]
	if item.type in ["glut","aa"]:
		inspect_description.text+="\nCapture range: %d px · Pull: %d" % [roundi(port_capture_radius(item)),roundi(port_pull_strength(item))]
		inspect_description.text+="\nTransport cooldown: %.1f s" % port_transport_cooldown(item)
	if item.has("a") and port_damaged(item):inspect_description.text+="\nBLOCKED: repair the nearby membrane tear."
	queue_redraw()
func close_inspect() -> void:
	inspect_panel.visible=false;queue_redraw()
func set_overlay_look(pale: bool) -> void:
	var style=StyleBoxFlat.new()
	style.bg_color=Color("#fffdf6") if pale else Color("#0c1424")
	style.border_color=Color("#a89468") if pale else Color("#3a4a68")
	style.set_border_width_all(2 if pale else 1)
	style.set_corner_radius_all(12 if pale else 16)
	overlay.add_theme_stylebox_override("panel",style)

func gene_unlocked(key: String) -> bool:
	if not GENES.has(key):return false
	if continuous_mode:
		if key=="c_repair":return active_mechanics.has("repair")
		match str(GENES[key].group):
			"Beginning":return true
			"Protein Processing":return active_mechanics.has("quality")
			"Homeostasis":return active_mechanics.has("homeostasis")
			"Stress / Advanced":return active_mechanics.has("combined")
		return false
	if key=="c_repair":return max_unlocked>=7
	return max_unlocked>=int(GENE_UNLOCK_LEVELS.get(str(GENES[key].group),99))

func show_genes() -> void:
	paused=true;overlay.visible=true;set_overlay_size(Vector2(460,560))
	set_overlay_look(true)
	for c in overlay_body.get_children():c.queue_free()
	var title=Label.new();title.text="🧬 Transcribe a gene";title.add_theme_color_override("font_color",Color("#2e1f14"));title.add_theme_font_size_override("font_size",19);overlay_body.add_child(title)
	var available=0
	for key in GENES:
		if gene_unlocked(str(key)):available+=1
	var note=Label.new();note.text="%d genes unlocked · %d ATP per mRNA · %d translations" % [available,TRANSCRIPTION_COST,MRNA_TRANSLATIONS];note.add_theme_color_override("font_color",Color("#8a7a5c"));note.add_theme_font_size_override("font_size",11);overlay_body.add_child(note)
	var scroll=ScrollContainer.new();scroll.custom_minimum_size=Vector2(410,440);overlay_body.add_child(scroll)
	var list=VBoxContainer.new();list.size_flags_horizontal=Control.SIZE_EXPAND_FILL;scroll.add_child(list)
	for group in GENE_GROUPS:
		if continuous_mode and not active_mechanics.has({"Protein Processing":"quality","Homeostasis":"homeostasis","Stress / Advanced":"repair"}.get(group,"")) and group!="Beginning":continue
		if not continuous_mode and max_unlocked<(7 if group=="Stress / Advanced" else int(GENE_UNLOCK_LEVELS.get(group,99))):continue
		var group_label=Label.new();group_label.text=group.to_upper();group_label.add_theme_color_override("font_color",Color("#8a7a5c"));group_label.add_theme_font_size_override("font_size",12);list.add_child(group_label)
		for key in GENES:
			if GENES[key].group!=group or not gene_unlocked(str(key)):continue
			var gene=GENES[key]
			var button=Button.new();button.custom_minimum_size=Vector2(390,56)
			button.text="%s · %s ribosome\n%s" % [gene.name,str(gene.ribosome).replace("_"," "),gene.desc]
			button.alignment=HORIZONTAL_ALIGNMENT_LEFT
			var style=StyleBoxFlat.new();style.bg_color=Color("#f7f1e3");style.border_color=Color("#a89468");style.set_border_width_all(1);style.border_width_left=4;style.border_color=Color("#7ac87a") if gene.needs_er else Color("#8ab8e8");style.set_corner_radius_all(8)
			button.add_theme_stylebox_override("normal",style)
			button.add_theme_color_override("font_color",Color("#2e1f14"))
			button.pressed.connect(transcribe_gene.bind(str(key)))
			list.add_child(button)
	var cancel=Button.new();cancel.text="Cancel";cancel.pressed.connect(close_overlay);overlay_body.add_child(cancel)

func show_gene_group(group: String) -> void:
	var choices: Array[String]=[]
	for key in GENES:
		if GENES[key].group==group:choices.append("Gene: "+str(key)+" — "+str(GENES[key].name))
	choices.append("Close")
	show_message(group+" genes","Choose a gene. Its mRNA carries the build instruction to a ribosome.",choices)
func transcribe_gene(selection: String) -> void:
	var key=selection.split(" ")[0]
	if GENES.has(key) and not gene_unlocked(key):
		say("This gene has not been unlocked yet.")
		return
	if GENES.has(key) and spend(TRANSCRIPTION_COST):
		var nuc=org("nucleus")
		if not nuc.is_empty():add_mol("mrna",nuc.p+Vector2(40,30),true,{"gene":key,"translations":MRNA_TRANSLATIONS})
		if key=="s_ins":tutorial_event("insulin_transcribed")
		say("%s mRNA transcribed (%d proteins). Bring it to a ribosome." % [GENES[key].name,MRNA_TRANSLATIONS])
	close_overlay()
func show_levels() -> void:
	if continuous_mode:return
	paused=true;overlay.visible=true
	set_overlay_size(Vector2(600,360))
	set_overlay_look(false)
	for c in overlay_body.get_children():c.queue_free()
	var heading=Label.new();heading.text="— Level Select —";heading.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;heading.add_theme_color_override("font_color",GOLD);heading.add_theme_font_size_override("font_size",22);overlay_body.add_child(heading)
	var grid=GridContainer.new();grid.columns=4;overlay_body.add_child(grid)
	for i in 15:
		var n=i+1
		var button=Button.new();button.custom_minimum_size=Vector2(120,48)
		button.text="%d — %s" % [n,"Beaten" if beaten.has(n) else ("Play" if n==max_unlocked else "Open")]
		button.disabled=n>max_unlocked
		button.pressed.connect(start_level.bind(n));grid.add_child(button)
	var close=Button.new();close.text="Close";close.pressed.connect(close_overlay);overlay_body.add_child(close)

func show_pack() -> void:
	var pools={
		"Piece Pack":["ribosome","golgi","lysosome","mitochondrion","er","microtubule","glutport","motor"],
		"Upgrade Pack":["mito","glut","glut_range","glut_pull","aa_range","aa_pull","aa_rate","ribCost","ves","golgi_up","motor","waste","o2"],
		"Energy Pack":["mitochondrion","mito","o2","glut"],
		"Cleanup Pack":["lysosome","waste","golgi_up"],
		"Growth Pack":["ribosome","golgi","lysosome","mitochondrion","er","aaport","ves","motor"],
		"Science Pack":["ribCost","golgi_up","glut","glut_range","aa_rate","o2","waste"],
		"Nutrient Pack":["nut_glucose","nut_aa","nut_o2","glut","aa_pull"],
		"Wildcard Pack":["ribosome","golgi","lysosome","mitochondrion","er","mito","ves","motor","ribCost","waste"]}
	var names=pools.keys();names.shuffle();pack_rolls.clear()
	paused=true;overlay.visible=true;pack_menu_open=true
	for i in 3:
		var name=str(names[i])
		var options: Array=pools[name].duplicate();options.shuffle()
		var effects=options.slice(0,randi_range(2,3));pack_rolls[name]=effects
	pack_rolls["_order"]=names.slice(0,3)
	render_pack_menu()

func pack_spacer(height: float) -> void:
	var spacer=Control.new();spacer.custom_minimum_size.y=height;spacer.mouse_filter=Control.MOUSE_FILTER_IGNORE;overlay_body.add_child(spacer)

func make_pack_card(index: int,name: String,width: float,height: float,scale_factor: float) -> Button:
	var card=Button.new();card.custom_minimum_size=Vector2(width,height)
	var style=StyleBoxFlat.new();style.bg_color=Color("#111a2c");style.border_color=Color("#2a3a55");style.set_border_width_all(2);style.set_corner_radius_all(22)
	card.add_theme_stylebox_override("normal",style)
	var hover=style.duplicate();hover.border_color=GOLD;hover.bg_color=Color("#18243b");card.add_theme_stylebox_override("hover",hover)
	var pressed=style.duplicate();pressed.border_color=GOLD;pressed.bg_color=Color("#24314a");card.add_theme_stylebox_override("pressed",pressed)
	var margin=MarginContainer.new();card.add_child(margin);margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);margin.mouse_filter=Control.MOUSE_FILTER_IGNORE
	margin.add_theme_constant_override("margin_left",roundi(36*scale_factor));margin.add_theme_constant_override("margin_right",roundi(24*scale_factor));margin.add_theme_constant_override("margin_top",roundi(24*scale_factor));margin.add_theme_constant_override("margin_bottom",roundi(16*scale_factor))
	var content=VBoxContainer.new();content.mouse_filter=Control.MOUSE_FILTER_IGNORE;content.add_theme_constant_override("separation",roundi(12*scale_factor));margin.add_child(content)
	var title=Label.new();title.text="pack %d" % index;title.add_theme_color_override("font_color",GOLD);title.add_theme_font_override("font",bold_font);title.add_theme_font_size_override("font_size",roundi(30*scale_factor));title.mouse_filter=Control.MOUSE_FILTER_IGNORE;content.add_child(title)
	for effect in pack_rolls[name]:
		var label=Label.new();label.text="•  "+pack_effect_name(str(effect));label.add_theme_color_override("font_color",TEXT);label.add_theme_font_size_override("font_size",roundi(24*scale_factor));label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;label.mouse_filter=Control.MOUSE_FILTER_IGNORE;content.add_child(label)
	card.pressed.connect(overlay_action.bind(name))
	return card

func render_pack_menu() -> void:
	if not pack_rolls.has("_order"):return
	var viewport_size=get_viewport_rect().size
	var scale_factor=minf(viewport_size.x/1138.0,viewport_size.y/754.0)*0.5
	set_overlay_size((viewport_size-Vector2(20,20))*0.5)
	for edge in ["left","right"]:overlay_margin.add_theme_constant_override("margin_"+edge,14)
	for edge in ["top","bottom"]:overlay_margin.add_theme_constant_override("margin_"+edge,11)
	var panel_style=StyleBoxFlat.new();panel_style.bg_color=Color("#0c1424");panel_style.border_color=Color("#3a4a68");panel_style.set_border_width_all(1);panel_style.set_corner_radius_all(roundi(30*scale_factor));overlay.add_theme_stylebox_override("panel",panel_style)
	for child in overlay_body.get_children():child.queue_free()
	overlay_body.add_theme_constant_override("separation",0)
	pack_spacer(34*scale_factor)
	var heading=Label.new();heading.text="Cell growth — choose a pack";heading.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;heading.vertical_alignment=VERTICAL_ALIGNMENT_CENTER;heading.custom_minimum_size.y=64*scale_factor;heading.add_theme_color_override("font_color",GOLD);heading.add_theme_font_override("font",bold_font);heading.add_theme_font_size_override("font_size",roundi(40*scale_factor));heading.mouse_filter=Control.MOUSE_FILTER_IGNORE;overlay_body.add_child(heading)
	pack_spacer(20*scale_factor)
	var order: Array=pack_rolls["_order"]
	var upper=HBoxContainer.new();upper.alignment=BoxContainer.ALIGNMENT_CENTER;upper.add_theme_constant_override("separation",roundi(28*scale_factor));overlay_body.add_child(upper)
	for i in 2:upper.add_child(make_pack_card(i+1,str(order[i]),400*scale_factor,242*scale_factor,scale_factor))
	pack_spacer(28*scale_factor)
	var lower=HBoxContainer.new();lower.alignment=BoxContainer.ALIGNMENT_CENTER;overlay_body.add_child(lower)
	lower.add_child(make_pack_card(3,str(order[2]),400*scale_factor,200*scale_factor,scale_factor))
	pack_spacer(26*scale_factor)
	var footer=Label.new();footer.text="Pick ONE pack — you receive everything rolled into it.";footer.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;footer.add_theme_color_override("font_color",Color("#9ab0cc"));footer.add_theme_font_size_override("font_size",roundi(23*scale_factor));footer.mouse_filter=Control.MOUSE_FILTER_IGNORE;overlay_body.add_child(footer)

func pack_effect_name(effect: String) -> String:
	var names={"mito":"Mito ATP yield +50%","glut":"GLUT throughput +30%","glut_range":"GLUT range +25%","glut_pull":"GLUT pull +30%","aa_range":"AA port range +25%","aa_pull":"AA port pull +30%","aa_rate":"AA port throughput +25%","ribCost":"Ribosome cost -1 ATP","ves":"Vesicle speed +40%","golgi_up":"Golgi fold speed +30%","waste":"Waste spawn -30%","o2":"O₂ attraction +50%","nut_glucose":"+8 glucose via plasma","nut_aa":"+8 amino acids via plasma","nut_o2":"+6 O₂ via red blood cells","microtubule":"Microtubule ×1","glutport":"GLUT port ×1","aaport":"AA port ×1","nakport":"Na⁺/K⁺ pump ×1","ca2port":"Ca²⁺ channel ×1","rxport":"Receptor ×1","erchaperone":"ER chaperone ×1","motor":"Motor protein ×1"}
	return str(names.get(effect,effect.capitalize()+" ×1"))

func apply_pack_effect(effect: String) -> void:
	if effect in ["ribosome","golgi","lysosome","mitochondrion","er","microtubule","glutport","aaport","nakport","ca2port","rxport","erchaperone","motor"]:
		toolbox[effect]=int(toolbox.get(effect,0))+1
	elif effect=="nut_glucose":
		for i in 2:spawn_blood_carrier("plasma",{"glucose":4},i*.55)
	elif effect=="nut_aa":
		for i in 2:spawn_blood_carrier("plasma",{"aa":4},i*.55)
	elif effect=="nut_o2":
		for i in 2:spawn_blood_carrier("rbc",{"o2":3},i*.55)
	elif effect=="ribCost":ups.ribCost=int(ups.get("ribCost",0))+1
	elif effect=="waste":ups.waste=float(ups.get("waste",1.0))*.7
	elif effect=="mito":ups.mito=float(ups.get("mito",1.0))*1.5
	elif effect=="glut":ups.glut=float(ups.get("glut",1.0))*1.3
	elif effect in ["glut_range","aa_range"]:ups[effect]=minf(1.8,float(ups.get(effect,1.0))*1.25)
	elif effect in ["glut_pull","aa_pull"]:ups[effect]=float(ups.get(effect,1.0))*1.3
	elif effect=="aa_rate":ups.aa_rate=float(ups.get("aa_rate",1.0))*1.25
	elif effect=="ves":ups.ves=float(ups.get("ves",1.0))*1.4
	elif effect=="golgi_up":ups.golgi=float(ups.get("golgi",1.0))*1.3
	elif effect=="o2":ups.o2=float(ups.get("o2",1.0))*1.5

func draw_text(p: Vector2,s: String,color := TEXT,size := 12) -> void:
	draw_string(font,p,s,HORIZONTAL_ALIGNMENT_CENTER,-1,size,color)
func poly_ellipse(c: Vector2,r: Vector2,color: Color,filled := true,width := 1.0,rotation := 0.0) -> void:
	var pts=PackedVector2Array()
	for i in 65:
		var a=float(i)/64.0*TAU
		pts.append(c+Vector2(r.x*cos(a),r.y*sin(a)).rotated(rotation))
	if filled:draw_colored_polygon(pts,color)
	else:draw_polyline(pts,color,width,true)
func quadratic_curve(a: Vector2,control: Vector2,b: Vector2,color: Color,width: float) -> void:
	var points=PackedVector2Array()
	for i in 13:
		var t=float(i)/12.0
		points.append(a*pow(1.0-t,2)+control*2.0*(1.0-t)*t+b*t*t)
	draw_polyline(points,color,width,true)
func circle(p: Vector2,r: float,c: Color) -> void:
	draw_circle(p,r,c)
func outline(p: Vector2,r: float,c: Color,w := 2.0) -> void:
	draw_arc(p,r,0,TAU,48,c,w,true)
func draw_dashed_ellipse(radii: Vector2,color: Color,width: float) -> void:
	for i in 96:
		if i%4==3:continue
		var a=TAU*float(i)/96.0
		var b=TAU*float(i+1)/96.0
		var from=cam_center+Vector2(cos(a)*radii.x,sin(a)*radii.y)
		var to=cam_center+Vector2(cos(b)*radii.x,sin(b)*radii.y)
		draw_line(from,to,color,width,true)
func draw_port_placement_band(phase: float,color: Color) -> void:
	var v=get_viewport_rect().size
	var inner=radius*.88-Vector2.ONE*phase*8.0
	var outer=radius*1.12+Vector2.ONE*phase*8.0
	var far=Vector2.ONE*maxf(v.x,v.y)*2.0
	var shade=Color(.03,.04,.07,.55)
	poly_ellipse(cam_center,inner,shade)
	for i in 96:
		var a=TAU*float(i)/96.0
		var b=TAU*float(i+1)/96.0
		var near_a=cam_center+Vector2(cos(a)*outer.x,sin(a)*outer.y)
		var near_b=cam_center+Vector2(cos(b)*outer.x,sin(b)*outer.y)
		var far_a=cam_center+Vector2(cos(a)*far.x,sin(a)*far.y)
		var far_b=cam_center+Vector2(cos(b)*far.x,sin(b)*far.y)
		draw_colored_polygon(PackedVector2Array([near_a,far_a,far_b,near_b]),shade)
	draw_dashed_ellipse(inner,color,2.5)
	draw_dashed_ellipse(outer,color,2.5)
func draw_build_hints(kind: String) -> void:
	var phase=(sin(elapsed*3.33)+1.0)*.5
	var green=Color(0.47,0.86,0.55,.45+.5*phase)
	if kind=="motor" and not rails.is_empty():
		for rail in rails:
			var path=PackedVector2Array()
			for point in rail.waypoints:path.append(point)
			if path.size()>1:draw_polyline(path,green,4.0,true)
		return
	if kind=="erchaperone":
		for er in orgs:
			if er.type=="er":outline(er.p,53,green,3)
		return
	if port_tool(kind):
		draw_port_placement_band(phase,green)
		return
	var viewport_size=get_viewport_rect().size
	draw_rect(Rect2(Vector2(0,96),Vector2(viewport_size.x,viewport_size.y-96)),Color(.03,.04,.07,.50))
	var side=34.0+phase*10.0
	var gx=cam_center.x-radius.x+50
	while gx<=cam_center.x+radius.x-50:
		var gy=cam_center.y-radius.y+50
		while gy<=cam_center.y+radius.y-50:
			var position=Vector2(gx,gy)
			var scaled=Vector2((gx-cam_center.x)/(radius.x-40),(gy-cam_center.y)/(radius.y-40))
			var clear=scaled.length()<=1
			for organelle in orgs:
				if position.distance_to(organelle.p)<52:clear=false;break
			if clear:
				draw_rect(Rect2(position-Vector2.ONE*side*.5,Vector2.ONE*side),Color(.08,.14,.15,.28))
				draw_rect(Rect2(position-Vector2.ONE*side*.5,Vector2.ONE*side),green,false,2.5)
			gy+=90
		gx+=90
func draw_dashed_box(center: Vector2,half_width: float,color: Color,width: float) -> void:
	var corners=[center+Vector2(-half_width,-half_width),center+Vector2(half_width,-half_width),center+Vector2(half_width,half_width),center+Vector2(-half_width,half_width)]
	for edge in 4:
		var a: Vector2=corners[edge]
		var b: Vector2=corners[(edge+1)%4]
		var length=a.distance_to(b)
		var direction=(b-a)/length
		var cursor=0.0
		while cursor<length:
			draw_line(a+direction*cursor,a+direction*minf(cursor+7.0,length),color,width,true)
			cursor+=11.0
func draw_rail_connect_hints() -> void:
	var hint_color=Color("#616161")
	for o in orgs:
		var selected=not rail_start.is_empty() and rail_start==o
		draw_dashed_box(o.p,42.0,hint_color,3.0 if selected else 2.0)
	for port in ports:
		var selected=not rail_start.is_empty() and rail_start==port
		draw_dashed_box(port.p,14.0,hint_color,3.0 if selected else 2.0)
func draw_capillary_layer(texture: Texture2D) -> void:
	if not texture:return
	var rect=capillary_rect()
	draw_texture_rect(texture,rect,false)
func draw_blood_carrier(carrier: Dictionary) -> void:
	if float(carrier.delay)>0.0:return
	var p=capillary_point(float(carrier.progress))
	var red=carrier.type=="rbc"
	var texture=blood_cell_texture if red else plasma_packet_texture
	if not texture:return
	var side=32.0 if red else 23.0
	var tint=Color.WHITE
	if red:
		var load=maxi(1,int(carrier.payload.o2))
		var depleted=clampf((float(carrier.released_o2)/float(load))*.78+float(carrier.co2_load)*.11,0.0,1.0)
		tint=Color("#fff0e8").lerp(Color("#682a40"),depleted)
	draw_texture_rect(texture,Rect2(p-Vector2.ONE*side*.5,Vector2.ONE*side),false,tint)
func guide_focus_position(focus: String) -> Vector2:
	if focus=="crack" and not cracks.is_empty():return port_pos(cracks[-1])
	if focus=="rail" and not rails.is_empty():return rail_pos(rails[-1],.5)
	if focus=="membrane":
		var capillary_center=capillary_point(.5)
		return port_pos(atan2((capillary_center.y-cam_center.y)/radius.y,(capillary_center.x-cam_center.x)/radius.x))
	var chosen_port: Dictionary={}
	var port_distance=INF
	var entry=capillary_eject_target({"type":"glucose","p":capillary_point(.5)})
	for port in ports:
		if port.type!=focus:continue
		var distance=Vector2(port.p).distance_to(entry)
		if distance<port_distance:chosen_port=port;port_distance=distance
	if not chosen_port.is_empty():return chosen_port.p
	var molecule_kind={"viral":"vrna"}.get(focus,focus)
	for molecule in mols:
		if molecule.dead or molecule.type!=molecule_kind:continue
		if focus=="waste" and guide_source=="enzymes" and not molecule.get("typed",false):continue
		if focus=="mrna" and molecule.get("gene","")!="s_ins":continue
		if focus=="vesicle" and molecule.get("gene","")!="s_ins":continue
		return molecule.p
	var target=org(focus)
	if not target.is_empty():return target.p
	return cam_center

func draw_guide_overlay() -> void:
	if not continuous_mode or not guide_active or guide_index>=guide_steps.size():return
	var step: Dictionary=guide_steps[guide_index]
	var screen=get_viewport_rect().size
	var center=guide_focus_position(str(step.focus))
	var side=118.0 if step.focus in ["er","mitochondrion","nucleus","golgi","ribosome","lysosome"] else 78.0
	var focus_rect=Rect2(center-Vector2.ONE*side*.5,Vector2.ONE*side)
	focus_rect.position.x=clampf(focus_rect.position.x,8.0,screen.x-side-8.0)
	focus_rect.position.y=clampf(focus_rect.position.y,84.0,screen.y-side-8.0)
	var shade=Color(0.02,0.035,0.07,.72)
	draw_rect(Rect2(Vector2(0,76),Vector2(screen.x,maxf(0.0,focus_rect.position.y-76))),shade)
	draw_rect(Rect2(Vector2(0,focus_rect.end.y),Vector2(screen.x,maxf(0.0,screen.y-focus_rect.end.y))),shade)
	draw_rect(Rect2(Vector2(0,focus_rect.position.y),Vector2(maxf(0.0,focus_rect.position.x),side)),shade)
	draw_rect(Rect2(Vector2(focus_rect.end.x,focus_rect.position.y),Vector2(maxf(0.0,screen.x-focus_rect.end.x),side)),shade)
	var pulse=2.5+1.5*sin(elapsed*5.0)
	draw_rect(focus_rect.grow(3),Color("#ffd166"),false,pulse)
	var card_width=minf(400.0,screen.x-24.0)
	var card_x=focus_rect.end.x+18.0 if focus_rect.end.x+card_width+22.0<screen.x else focus_rect.position.x-card_width-18.0
	card_x=clampf(card_x,12.0,screen.x-card_width-12.0)
	var card_y=clampf(focus_rect.position.y,108.0,screen.y-128.0)
	var card=Rect2(Vector2(card_x,card_y),Vector2(card_width,112))
	draw_rect(card,Color("#0c1424"))
	draw_rect(card,Color("#ffd166"),false,2.0)
	draw_string(bold_font,card.position+Vector2(14,27),str(step.title),HORIZONTAL_ALIGNMENT_LEFT,card_width-28,18,GOLD)
	draw_string(font,card.position+Vector2(14,54),str(step.explain),HORIZONTAL_ALIGNMENT_LEFT,card_width-28,14,Color("#d0dced"))
	draw_string(bold_font,card.position+Vector2(14,83),str(step.action),HORIZONTAL_ALIGNMENT_LEFT,card_width-28,14,Color("#ffffff"))
func _draw() -> void:
	var v=get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO,v),BG)
	var visible_swell=float(state.swell) if mode=="osmosis" or continuous_mode and active_mechanics.has("osmosis") or not cracks.is_empty() else 0.0
	poly_ellipse(cam_center,radius*Vector2.ONE*(1.0+visible_swell),CELL_INNER)
	poly_ellipse(cam_center,radius,CELL_WALL,false,5)
	for a in cracks:
		var p=port_pos(a)
		var damage=crack_state(a)
		var severe=int(damage.severity)>=2
		var tint=Color("#b82d38") if severe else Color("#e05a5a")
		var width=5.0 if severe else 3.0
		draw_line(p+Vector2(-12 if severe else -7,-13 if severe else -10),p+Vector2(2,0),tint,width,true)
		draw_line(p+Vector2(2,0),p+Vector2(13 if severe else 8,12 if severe else 9),tint,width,true)
		if bool(damage.material):circle(p+Vector2(-8,7),4,Color("#c8a2e8"))
		if bool(damage.protein):circle(p+Vector2(8,-7),4,Color("#7ee89b"))
		if severe:draw_text(p+Vector2(-19,-20),"RUPTURE",tint,9)
	for r in rails:
		var pts=PackedVector2Array()
		for point in r.waypoints:pts.append(point)
		if r.out.type=="golgi" and pts.size()>0:draw_line(Vector2(r.out.p),pts[0],Color("#39c2f5"),3.5,true)
		if pts.size()>1:draw_polyline(pts,Color("#39c2f5"),3.5,true)
		circle(r.waypoints[0],5,Color("#6a9ae8"));circle(r.rec.p,5,Color("#7ee89b"))
		for motor in r.motors:
			var mp=rail_pos(r,float(motor.p))
			circle(mp,6,GOLD)
			if not motor.cargo.is_empty():circle(mp+Vector2(0,-11),5,Color(COLORS.get(motor.cargo.type,"#ffffff")))
	for port in ports:
		var color=Color("#ffd76a") if port.type=="glut" else Color("#e06a8a")
		if port.type=="rx":color=Color("#7ee89b")
		if port.type=="ca":color=Color("#ffe066")
		if port.type=="nak":color=Color("#e8a05a")
		if port.type=="aqua":color=Color("#7ec8e8")
		if port_damaged(port):color=color.darkened(.65)
		circle(port.p,9,color);outline(port.p,9,Color(1,1,1,.5),1.5)
		if port_damaged(port):draw_line(Vector2(port.p)+Vector2(-10,-10),Vector2(port.p)+Vector2(10,10),Color("#b82d38"),3,true)
		var letter="G" if port.type=="glut" else "A"
		if port.type=="rx":letter="R"
		if port.type=="ca":letter="Ca"
		if port.type=="nak":letter="Na"
		if port.type=="aqua":letter="H₂O"
		draw_text(port.p+Vector2(0,4),letter,Color("#342315"),10)
	for o in orgs:
		if o.type!="ribosome":draw_organelle(o)
	for o in orgs:
		if o.type=="ribosome":draw_organelle(o)
	if not ribosome_drag.is_empty() and ribosome_moved and GENES.get(str(ribosome_drag.get("gene","")),{}).get("needs_er",false):
		for er in orgs:
			if er.type=="er":outline(er.p,54,Color("#a0ee8a"),3)
	if placing=="microtubule":draw_rail_connect_hints()
	for dot in relay_dots:
		circle(dot.p,4,Color("#7ee89b"))
		outline(dot.p,7,Color(0.49,0.91,0.61,.28),2)
	draw_capillary_layer(capillary_bottom)
	for carrier in blood_carriers:draw_blood_carrier(carrier)
	for m in mols:
		if m.dead or (m.type=="mrna" and m.get("bound",false)):continue
		var cap_state=str(m.get("cap_state",""))
		if cap_state in ["incoming_eject","ion_seek","co2_seek","co2_wait","co2_rbc_capture","co2_plasma_absorb","co2_suck"]:continue
		if cap_state=="incoming_under" and float(m.get("cap_delay",0.0))>0:continue
		if cap_state=="co2_descend":draw_molecule(m,float(m.cap_time)/.25)
		else:draw_molecule(m)
	draw_capillary_layer(capillary_top)
	for m in mols:
		if m.dead or (m.type=="mrna" and m.get("bound",false)):continue
		var cap_state=str(m.get("cap_state",""))
		if cap_state in ["incoming_eject","ion_seek","co2_seek","co2_wait","co2_plasma_absorb","co2_suck"]:draw_molecule(m)
		elif cap_state=="co2_rbc_capture":draw_molecule(m,1.0-.65*clampf(float(m.cap_time)/RBC_CO2_CAPTURE_SECONDS,0.0,1.0))
		elif cap_state=="co2_descend":draw_molecule(m,1.0-float(m.cap_time)/.25)
	for item in pops:
		var alpha=1.0-float(item.age)/1.2
		var color: Color=item.color
		color.a=alpha
		draw_text(item.p+Vector2(0,-30.0*float(item.age)/1.2),str(item.text),color,13)
	var hint_kind=toolbox_drag_kind if not toolbox_drag_kind.is_empty() else placing
	if not hint_kind.is_empty() and hint_kind!="microtubule":draw_build_hints(hint_kind)
	if state.atp<8:
		draw_rect(Rect2(Vector2(0,96),Vector2(v.x,v.y-96)),Color(0.8,.12,.12,.08+.04*sin(elapsed*6)))
	draw_guide_overlay()
	if paused:
		draw_rect(Rect2(Vector2(0,76),Vector2(v.x,v.y-76)),Color(.02,.03,.055,.45))
		if not overlay.visible:
			var message="PAUSED — click Pause to resume"
			var text_size=font.get_string_size(message,HORIZONTAL_ALIGNMENT_LEFT,-1,28)
			var baseline=Vector2((v.x-text_size.x)*.5,(76.0+v.y)*.5+(font.get_ascent(28)-font.get_descent(28))*.5)
			draw_string(font,baseline,message,HORIZONTAL_ALIGNMENT_LEFT,-1,28,GOLD)

func draw_organelle(o: Dictionary) -> void:
	var p: Vector2=o.p
	match str(o.type):
		"nucleus":
			circle(p,42,Color("#2a3a5e"));outline(p,42,Color("#5a7ab0"))
			circle(p,14,Color("#5a7ab0"))
			if state.alert>0:outline(p,31,Color("#7ee89b"),3)
		"mitochondrion":
			poly_ellipse(p,Vector2(36,22),Color("#7a3a3e"),true,1.0,.4);poly_ellipse(p,Vector2(36,22),Color("#c86a6a"),false,2,.4)
			for i in 3:
				var y=(i-1)*8-8
				quadratic_curve(p+Vector2(-16,y),p+Vector2(0,y+11),p+Vector2(16,y),Color("#c86a6a",.7),2)
		"ribosome":
			var template: Dictionary=o.get("template",{})
			var slot_center=mrna_slot_pos(o)
			var slot_rect=Rect2(slot_center-MRNA_SLOT_SIZE*.5,MRNA_SLOT_SIZE)
			draw_rect(slot_rect,Color("#172943"))
			draw_rect(slot_rect,GOLD if not template.is_empty() else Color("#9a8abe"),false,1.5)
			if not template.is_empty() and not template.dead:draw_mrna_sprite(slot_center,int(template.get("translations",1)))
			var slots=int(o.slots.size())
			for i in 3:
				var q=p+Vector2((i-1)*11,(i%2)*7)
				circle(q,7,Color("#e06a8a") if i<slots else Color("#6a5a8e"))
				outline(q,7,GOLD if i<slots else (Color("#7ac87a") if o.get("state","")=="er_bound" else Color("#9a8abe")),1.5)
			if template.is_empty():draw_text(p+Vector2(0,29),"NO mRNA",Color("#5A4030"),9)
		"er":
			poly_ellipse(p,Vector2(44,24),Color("#3a5e3e"),true,1.0,.6);poly_ellipse(p,Vector2(44,24),Color("#7ac87a"),false,2,.6)
			for i in 5:
				var j=i-2
				quadratic_curve(p+Vector2(-30+j*4,j*7-4),p+Vector2(j*2,j*7+8),p+Vector2(30+j*4,j*7-4),Color("#7ac87a",.5),1)
			var rough=false
			if er_ribosome_count(o)>0:
				rough=true
				for dot in 4:circle(p+Vector2(-28+dot*17,-23),3.5,GOLD)
			draw_text(p+Vector2(0,43),"ROUGH ER" if rough else "SMOOTH ER",Color("#315A37"),9)
		"golgi":
			for i in 4:
				var q=p+Vector2(0,i*7-10)
				poly_ellipse(q,Vector2(30-i*4,9),Color("#5e4a2e"),true,1.0,.15);poly_ellipse(q,Vector2(30-i*4,9),Color("#d8b86a"),false,1.5,.15)
		"lysosome":
			var edge=Color("#c87a5a")
			if o.has("enzyme"):
				edge=Color("#e06a6a") if o.enzyme=="protein" else (Color("#6ab0e0") if o.enzyme=="sugar" else Color("#e0c26a"))
			circle(p,22,Color("#4e2e2e"));outline(p,22,edge,3 if o.has("enzyme") else 2)
			draw_text(p+Vector2(0,4),"pH 5" if not o.has("enzyme") else str(o.enzyme).substr(0,4).to_upper(),edge,10)
func draw_mrna_sprite(p: Vector2,uses: int,alpha := 1.0) -> void:
	var tex=mrna_texture(uses)
	if tex:draw_texture_rect(tex,Rect2(p-Vector2.ONE*MRNA_DRAW_SIDE*.5,Vector2.ONE*MRNA_DRAW_SIDE),false,Color(1,1,1,alpha))
func draw_molecule(m: Dictionary,alpha := 1.0) -> void:
	if alpha<=0:return
	var p: Vector2=m.p
	var kind=str(m.type)
	var rad=float(RADII.get(kind,8))
	var tex: Texture2D=mrna_texture(int(m.get("translations",4))) if kind=="mrna" else textures.get(kind)
	if kind=="waste" and m.get("sub","")!="":
		var name="Waste1" if m.sub=="protein" else ("Waste2" if m.sub=="sugar" else "Waste3")
		tex=textures.get(name.to_lower())
	if tex:
		var side=MRNA_DRAW_SIDE if kind=="mrna" else maxf(rad*(5.8 if kind=="waste" else 6.6),38 if kind=="waste" else 34)
		draw_texture_rect(tex,Rect2(p-Vector2.ONE*side*.5,Vector2.ONE*side),false,Color(1,1,1,alpha))
	else:
		var fill=Color(COLORS.get(kind,"#ffffff"));fill.a*=alpha
		circle(p,rad,fill)
		if kind in ["protein","exported_protein"]:outline(p,rad,Color("#e04a4a") if m.get("misfold",false) else (GOLD if m.get("folded",false) else Color.WHITE),2)
		if kind=="endoves":outline(p,rad,Color("#a8863e"),1.5)
	if float(m.get("capture_hint",0.0))>0.0 or not str(m.get("capture_state","")).is_empty():
		var hint_color=Color("#ffd76a") if kind=="glucose" else Color("#e06a8a")
		hint_color.a=.38*alpha
		outline(p,rad+5.0+sin(elapsed*10.0)*1.3,hint_color,1.5)
	if kind=="waste" and mode in ["enz","chaos"]:
		var c=Color("#e06a6a") if m.get("sub","protein")=="protein" else (Color("#6ab0e0") if m.sub=="sugar" else Color("#e0c26a"))
		outline(p,rad+2,c,2)
	if kind=="protein" and m.get("misfold",false):outline(p,rad+4,Color("#e04a4a"),3)
	if kind=="protein" and m.get("stage","")=="installed":outline(p,rad+4,Color("#7ee89b"),2)
	if kind in ["mrna","protein","vesicle"] and GENES.has(str(m.get("gene",""))) and not (kind=="protein" and m.get("stage","")=="in_er"):
		var label=str(GENES[m.gene].name)
		if label.length()>12:label=label.substr(0,11)+"…"
		if kind=="mrna":label+=" ×%d" % int(m.get("translations",0))
		var tint=Color("#4F372B");tint.a=alpha
		draw_text(p+Vector2(0,-rad-12),label,tint,9)
		if kind=="protein" and m.get("stage","")=="installed":draw_text(p+Vector2(0,rad+15),"ACTIVE",Color("#315A37"),8)
