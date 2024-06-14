import tkinter as tk
import random

CANVAS_WIDTH = 500
CANVAS_HEIGHT = 600

PADDLE_Y = CANVAS_HEIGHT - 30
PADDLE_WIDTH = 80
PADDLE_HEIGHT = 15
BALL_RADIUS = 10
DELAY = 0.014

BRICK_GAP = 5
BRICK_WIDTH = (CANVAS_WIDTH - BRICK_GAP*9) / 10
BRICK_HEIGHT = 10

BRICK_POSITION_X = 0
BRICK_POSITION_Y = 60

BALL_DIAMETER = 20
INITIAL_VELOCITY = 5

FONT_SIZE = 24


class BrickBreaker(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("Brick Breaker")
        self.canvas = tk.Canvas(self, width=CANVAS_WIDTH, height=CANVAS_HEIGHT)
        self.canvas.pack()
        
        # Center the window on the screen
        self.center_window()

        # Initialize game variables
        self.shapes_removed = 0
        self.lives = 3
        self.x_velocity = INITIAL_VELOCITY
        self.y_velocity = INITIAL_VELOCITY

        # Create ball and paddle
        self.ball_x = random.randint(150, 350)
        self.ball_y = 300
        self.ball = self.canvas.create_oval(
            self.ball_x, self.ball_y,
            self.ball_x + BALL_DIAMETER,
            self.ball_y + BALL_DIAMETER,
            fill='blue'
        )

        self.paddle = self.canvas.create_rectangle(
            0,
            PADDLE_Y,
            PADDLE_WIDTH,
            PADDLE_Y + PADDLE_HEIGHT,
            fill="black"
        )

        # Create bricks
        self.create_bricks()

        # Bind paddle movement to mouse motion
        self.bind("<Motion>", self.move_paddle)

        # Start game loop
        self.game_loop()

    def center_window(self):
        # Calculate the position to center the window
        screen_width = self.winfo_screenwidth()
        screen_height = self.winfo_screenheight()

        window_width = CANVAS_WIDTH
        window_height = CANVAS_HEIGHT

        x = (screen_width // 2) - (window_width // 2)
        y = (screen_height // 2) - (window_height // 2)

        self.geometry(f"{window_width}x{window_height}+{x}+{y}")

    def create_bricks(self):
        local_y = BRICK_POSITION_Y
        lst_of_color = ["red", "orange", "yellow", "green", "cyan"]

        for i in range(10):
            self.create_bricks_layer(BRICK_POSITION_X, local_y, 10, lst_of_color[i // 2 % 5])
            local_y += BRICK_GAP + BRICK_HEIGHT

    def create_bricks_layer(self, x, y, number_of_bricks, color):
        local_x = x

        for _ in range(1, number_of_bricks + 1):
            self.place_brick(local_x, y, color)
            local_x += BRICK_WIDTH + BRICK_GAP

    def place_brick(self, place_x, place_y, color):
        self.canvas.create_rectangle(
            place_x,
            place_y,
            place_x + BRICK_WIDTH,
            place_y + BRICK_HEIGHT,
            fill=color,
            tags="brick"
        )

    def move_paddle(self, event):
        mouse_x = event.x
        self.canvas.coords(self.paddle, mouse_x - PADDLE_WIDTH / 2, PADDLE_Y, mouse_x + PADDLE_WIDTH / 2, PADDLE_Y + PADDLE_HEIGHT)

    def game_loop(self):
        ball_coords = self.canvas.coords(self.ball)
        ball_x1, ball_y1, ball_x2, ball_y2 = ball_coords

        if ball_x1 < 0 or ball_x2 >= CANVAS_WIDTH:
            self.x_velocity = -self.x_velocity
        if ball_y1 < 0:
            self.y_velocity = -self.y_velocity
        elif ball_y2 >= PADDLE_Y and ball_y2 <= PADDLE_Y + PADDLE_HEIGHT:
            if ball_x2 >= self.canvas.coords(self.paddle)[0] and ball_x1 <= self.canvas.coords(self.paddle)[2]:
                self.y_velocity = -self.y_velocity

        self.ball_x += self.x_velocity
        self.ball_y += self.y_velocity

        self.canvas.coords(self.ball, self.ball_x, self.ball_y, self.ball_x + BALL_DIAMETER, self.ball_y + BALL_DIAMETER)

        overlapping = self.canvas.find_overlapping(ball_x1, ball_y1, ball_x2, ball_y2)

        for item in overlapping:
            if "brick" in self.canvas.gettags(item):
                self.y_velocity = -self.y_velocity
                self.canvas.delete(item)
                self.shapes_removed += 1

        if self.shapes_removed == 100:
            self.canvas.create_text(250, 15, text="You Won.", fill="blue", font=("Courier", FONT_SIZE))
            return
        elif ball_y2 >= CANVAS_HEIGHT:
            self.lives -= 1
            if self.lives > 0:
                self.ball_x = random.randint(150, 350)
                self.ball_y = 300
                self.x_velocity = INITIAL_VELOCITY
                self.y_velocity = INITIAL_VELOCITY
                self.canvas.coords(self.ball, self.ball_x, self.ball_y, self.ball_x + BALL_DIAMETER, self.ball_y + BALL_DIAMETER)
            else:
                self.canvas.delete(self.ball)
                self.canvas.create_text(250, 15, text="You Lost.", fill="red", font=("Courier", FONT_SIZE))
                return

        self.after(int(DELAY * 1000), self.game_loop)


if __name__ == '__main__':
    app = BrickBreaker()
    app.mainloop()
