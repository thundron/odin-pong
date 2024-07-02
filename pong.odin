package main

import "core:math"
import "core:math/linalg"
import "core:math/rand"
import rl "vendor:raylib"

main::proc() {
	gs := Game_State {
		window_size = {1280, 720},
		player1 = {width = 30, height = 80},
		player1_speed = 10,
		ball = {width = 30, height = 30},
		ball_speed = 10
	}
	reset(&gs)

	using gs

	rl.InitWindow(i32(window_size.x), i32(window_size.y), "Pong")
	rl.SetTargetFPS(60)

	for !rl.WindowShouldClose() {
		// player block movement by input
		if rl.IsKeyDown(.UP) {
			player1.y -= player1_speed
		}
		if rl.IsKeyDown(.DOWN) {
			player1.y += player1_speed
		}
		// limit player y axis movements inside window boundaries
		player1.y = linalg.clamp(player1.y, 0, window_size.y - player1.height)

		// ball direction calculations
		next_ball_rect := ball
		next_ball_rect.x += ball_speed * ball_direction.x
		next_ball_rect.y += ball_speed * ball_direction.y

		// flip direction when it reaches window edges
		if next_ball_rect.y >= window_size.y - ball.height || next_ball_rect.y <= 0 {
			ball_direction.y *= -1
		}
		
		// built-in raylib collision detection
		if rl.CheckCollisionRecs(next_ball_rect, player1) {
			ball_center := rl.Vector2{
				next_ball_rect.x + ball.width/2,
				next_ball_rect.y + ball.height/2
			}
			player1_center := rl.Vector2{
				player1.x + player1.width/2,
				player1.y + player1.height/2
			}
			ball_direction = linalg.normalize0(ball_center - player1_center)
		}

		ball.x += ball_speed * ball_direction.x
		ball.y += ball_speed * ball_direction.y

		if next_ball_rect.x >= window_size.x - ball.width {
			reset(&gs)
		}
		
		if next_ball_rect.x < 0 {
			reset(&gs)
		}


		rl.BeginDrawing()

		rl.ClearBackground(rl.BLACK) // clear before drawing new positions
		
		rl.DrawRectangleRec(player1, rl.WHITE)
		rl.DrawRectangleRec(ball, rl.RED)
		
		rl.EndDrawing()
	}
}

reset::proc(using gs: ^Game_State) {
	angle := rand.float32_range(-45, 46)
	r := math.to_radians(angle)

	ball_direction.x = math.cos(r)
	ball_direction.y = math.sin(r)

	ball.x = window_size.x/2 - ball.width/2
	ball.y = window_size.y/2 - ball.height/2

	player1.x = window_size.x - 80
	player1.y = window_size.y/2 - player1.height/2
}

Game_State::struct {
	window_size: rl.Vector2,

	player1: rl.Rectangle,
	player1_speed: f32,
	
	ball: rl.Rectangle,
	ball_speed: f32,
	ball_direction: rl.Vector2
}

