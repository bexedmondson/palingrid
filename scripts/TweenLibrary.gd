extends Node

func popup_in(tween : Tween, popup):
	if tween != null and tween.is_valid():
		tween.kill()
	tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(popup, "scale", Vector2(1,1), 0.2).from(Vector2.ZERO)
	return tween

func popup_out(tween : Tween, popup):
	if tween != null and tween.is_valid():
		tween.kill()
	tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(popup, "scale", Vector2.ZERO, 0.15)
	return tween
