extends RefCounted

const SPARK := preload("res://assets/kenney_particle-pack/PNG (Transparent)/star_04.png")


static func celebrate(parent: Node2D, at: Vector2) -> void:
	for i in 8:
		var spark := Sprite2D.new()
		spark.texture = SPARK
		spark.position = at
		spark.scale = Vector2.ONE * 0.24
		spark.modulate = Color("#a6f2bc")
		parent.add_child(spark)
		var outward := Vector2.RIGHT.rotated(TAU * i / 8)
		var tween := spark.create_tween().set_parallel()
		tween.tween_property(spark, "position", at + outward * 80, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(spark, "modulate:a", 0.0, 0.4)
		tween.chain().tween_callback(spark.queue_free)
