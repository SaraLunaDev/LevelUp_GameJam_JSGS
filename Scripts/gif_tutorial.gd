extends Control

@onready var anim = $AnimatedSprite2D

func _ready():
	anim.play("BasicAnim")
