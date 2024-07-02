package main

import rl "vendor:raylib"

main::proc() {
	player1 := rl.Rectangle{100, 100, 180, 30}
	player1_speed: f32 = 10

	ball := rl.Rectangle{100, 150, 30, 30}
	ball_direction := rl.Vector2{0, -1}
	ball_speed: f32 = 10

	rl.InitWindow(1280, 720, "Pong")
	rl.SetTargetFPS(60)

	for !rl.WindowShouldClose() {
		// player block movement by input
		if rl.IsKeyDown(rl.KeyboardKey.A) {
			player1.x -= 10
		}
		if rl.IsKeyDown(rl.KeyboardKey.D) {
			player1.x += 10
		}

		// ball direction calculations
		next_ball_rect := ball
		next_ball_rect.y += ball_speed * ball_direction.y

		// flip direction when it reaches screen edges
		if next_ball_rect.y >= 720 - 30 || next_ball_rect.y <= 0 {
			ball_direction.y *= -1
		}
		ball.y += ball_speed * ball_direction.y

		rl.BeginDrawing()

		rl.ClearBackground(rl.BLACK) // clear before drawing new positions
		
		rl.DrawRectangleRec(player1, rl.WHITE)
		rl.DrawRectangleRec(ball, rl.RED)
		
		rl.EndDrawing()
	}
}
