package main

import "core:math"
import "core:math/linalg"
import "core:math/rand"
import "core:time"

import rl "vendor:raylib"

main::proc() {
	gs := Game_State {
		window_size = {1280, 720},
		player1 = {width = 30, height = 80},
		player2 = {width = 30, height = 80},
		paddle_speed = 10,
		ball = {width = 30, height = 30},
		ball_speed = 10,
		difficulty = 2,
		ai_reaction = 2
	}
	reset(&gs)

	using gs

	rl.InitWindow(i32(window_size.x), i32(window_size.y), "Pong")
	rl.SetTargetFPS(60)

	for !rl.WindowShouldClose() {
		// player block movement by input
		if rl.IsKeyDown(.UP) {
			player1.y -= paddle_speed
		}
		if rl.IsKeyDown(.DOWN) {
			player1.y += paddle_speed
		}
		// limit player y axis movements inside window boundaries
		player1.y = linalg.clamp(player1.y, 0, window_size.y - player1.height)

		// player2 movement based on difficulty setting
		if gs.ai_reaction <= 0 {
			differential := player2.y + player2.height/2 - ball.y + ball.height/2
			if differential < 0 {
				player2.y += paddle_speed
			} else {
				player2.y -= paddle_speed
			}
			gs.ai_reaction = gs.difficulty
		} else {
			gs.ai_reaction -= 1
		}

		// ball direction calculations
		next_ball_rect := ball
		next_ball_rect.x += ball_speed * ball_direction.x
		next_ball_rect.y += ball_speed * ball_direction.y

		// flip direction when it reaches window edges
		if next_ball_rect.y >= window_size.y - ball.height || next_ball_rect.y <= 0 {
			ball_direction.y *= -1
		}

		// reset game state when ball is out of window bounds
		if next_ball_rect.x >= window_size.x - ball.width {
			reset(&gs)
		}	
		if next_ball_rect.x < 0 {
			reset(&gs)
		}

		ball_direction = ball_direction_calculate(ball, player1) or_else ball_direction

		ball_direction = ball_direction_calculate(ball, player2) or_else ball_direction

		ball.x += ball_speed * ball_direction.x
		ball.y += ball_speed * ball_direction.y

		rl.BeginDrawing()

		rl.ClearBackground(rl.BLACK) // clear before drawing new positions

		rl.DrawRectangleRec(player1, rl.GREEN)
		rl.DrawRectangleRec(player2, rl.RED)
		rl.DrawRectangleRec(ball, rl.WHITE)

		rl.EndDrawing()
	}
}

ball_direction_calculate::proc(ball: rl.Rectangle, paddle: rl.Rectangle) -> (rl.Vector2, bool) {
	if rl.CheckCollisionRecs(ball, paddle) {
		ball_center := rl.Vector2{ball.x + ball.width/2, ball.y + ball.height/2}
		paddle_center := rl.Vector2{paddle.x + paddle.width/2, paddle.y + paddle.height/2}
		return linalg.normalize0(ball_center - paddle_center), true
	}
	return {}, false
}

reset::proc(using gs: ^Game_State) {
	angle := rand.float32_range(-45, 46)
	// coin toss to calculate ball direction
	if rand.int_max(100)%2 == 0 {
		angle += 180
	}
	r := math.to_radians(angle)

	ball_direction.x = math.cos(r)
	ball_direction.y = math.sin(r)

	ball.x = window_size.x/2 - ball.width/2
	ball.y = window_size.y/2 - ball.height/2

	paddle_margin: f32 = 50

	player1.x = window_size.x - (player1.width + paddle_margin)
	player1.y = window_size.y/2 - player1.height/2

	player2.x = paddle_margin
	player2.y = window_size.y/2 - player2.height/2
}

Game_State::struct {
	window_size: rl.Vector2,

	player1: rl.Rectangle,
	player2: rl.Rectangle,

	paddle_speed: f32,

	ball: rl.Rectangle,
	ball_speed: f32,
	ball_direction: rl.Vector2,

	difficulty: i32,
	ai_reaction: i32
}

