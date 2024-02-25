extends Node3D

signal Weapon_Changed
signal Update_Ammo
signal Update_Weapon_Stack(stack)

@export var player : CharacterBody3D
@onready var animator = %AnimationPlayer
@onready var weapon_hud = %WeaponHud

var weapon_current : ItemData = null # получает данные из класса Player equiped_inv_item
var weapon_equiped = false
var Scoped = false
@export var state_machine : StateMachine

func _ready():
	pass

func _physics_process(_delta):
	if weapon_current:
		if weapon_current.item_type == weapon_current.ItemType.weapon:
			if state_machine.is_current_state("Sprint") == false:
				if Input.is_action_pressed("right_click"):
					if !Scoped:
						if weapon_current.item_type == weapon_current.ItemType.weapon:
							Assault_Rifle_Scope()
							%Reticle.hide()
				if Input.is_action_just_released("right_click"):
					if Scoped:
						Assault_Rifle_Scope()
						%Reticle.show()
			elif state_machine.is_current_state("Sprint"):
				if Scoped:
					Assault_Rifle_Scope()

func _unhandled_input(_event):
	if weapon_current:
		if weapon_current.item_type == weapon_current.ItemType.weapon:
			if(Input.is_action_just_pressed("reload")):
				reload()

			if(Input.is_action_just_pressed("fire")):
				if !Scoped:
					shoot()
					#--- переделать (пример)
					weapon_current.ammo_current -= 1
					Update_Ammo.emit([weapon_current.ammo_current, weapon_current.ammo_reserve])
					#--- 

func initialize_weapon(weapon : InSlotData): # получает данные о слоте из которого создалось оружие ранее и вызывается после того, как оружие создано
	if weapon != null:
		weapon_current = weapon.item
		weapon_hud.show()
		animator.play(weapon_current.anim_activate) # если вызвана анимация и в то же время быстро переключен слот, то анимка немного багается, не критично, позже исправлю
		Weapon_Changed.emit(weapon_current.weapon_name)
		Update_Ammo.emit([weapon_current.ammo_current, weapon_current.ammo_reserve])

func exit(weapon : InSlotData):
	if weapon != null:
		weapon_current = weapon.item
		if weapon_current: # если вызвана анимация и в то же время быстро переключен слот, то анимка немного багается, не критично, позже исправлю
			#animator.play_backwards(weapon_current.anim_activate)
			weapon_hud.hide()
			weapon_current = null

func shoot():
	animator.play(weapon_current.anim_shoot)

func reload():
	animator.play(weapon_current.anim_reload)

func Assault_Rifle_Scope():
	if !Scoped:
		animator.play(player.equiped_inv_item.item.anim_scope)
	else:
		animator.play_backwards(player.equiped_inv_item.item.anim_scope)
	Scoped = !Scoped
