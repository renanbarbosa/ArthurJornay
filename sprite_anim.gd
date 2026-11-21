extends RefCounted
## Uma animação em folha de sprites de uma linha só (gerada por tools/gif_to_sheet.py).

var texture: Texture2D = null
var frame_count := 1
var frame_time := 0.12
## Ponto dos pés dentro de cada quadro: é o ponto que fica no chão.
var feet := Vector2.ZERO
## true se, na imagem original, o personagem está virado para a esquerda.
var faces_left := false


func _init(path: String, frames: int, seconds_per_frame: float, feet_point: Vector2, source_faces_left := false) -> void:
	frame_count = frames
	frame_time = seconds_per_frame
	feet = feet_point
	faces_left = source_faces_left
	if ResourceLoader.exists(path):
		texture = load(path)


func is_loaded() -> bool:
	return texture != null


func duration() -> float:
	return frame_count * frame_time


## Quadro para um tempo decorrido. Com loop, repete os quadros de `first` até `last`;
## sem loop, para no último.
func frame_at(time: float, loop := true, first := 0, last := -1) -> int:
	var end := frame_count - 1 if last < 0 else last
	var count := end - first + 1
	var step := int(time / frame_time)
	if loop:
		return first + step % count
	return first + mini(step, count - 1)


## Desenha um quadro com os pés em `position`. `facing` é 1 (direita) ou -1 (esquerda).
func draw(canvas: CanvasItem, frame: int, position: Vector2, scale: float, facing := 1.0, rotation := 0.0, stretch := Vector2.ONE) -> void:
	var cell := Vector2(texture.get_width() / float(frame_count), texture.get_height())
	var flip := -facing if faces_left else facing
	canvas.draw_set_transform(position, rotation, Vector2(flip, 1.0) * stretch * scale)
	canvas.draw_texture_rect_region(texture, Rect2(-feet, cell), Rect2(Vector2(frame * cell.x, 0.0), cell))
	canvas.draw_set_transform(Vector2.ZERO)
