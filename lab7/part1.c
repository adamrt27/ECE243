int pixel_buffer_start; // global variable

int main(void) {
	
	volatile int * pixel_ctrl_ptr = (int *)0xFF203020;
	/* Read location of the pixel buffer from the pixel buffer controller */ 
	pixel_buffer_start = *pixel_ctrl_ptr;
	
	clear_screen();
	draw_line(0, 0, 150, 150, 0x001F); // this line is blue 
	draw_line(150, 150, 319, 0, 0x07E0); // this line is green 
	draw_line(0, 239, 319, 239, 0xF800); // this line is red 
	draw_line(319, 0, 0, 239, 0xF81F); // this line is a pink color
}

// code not shown for clear_screen() and draw_line() subroutines
void plot_pixel(int x, int y, short int line_color) {
	volatile short int *one_pixel_address;
	one_pixel_address = pixel_buffer_start + (y << 10) + (x << 1); 
	*one_pixel_address = line_color;
}

void draw_line(int x0, int y0, int x1, int y1, short int line_color) {
	int dx = abs(x0 - x1);
	int dy = abs(y0 - y1);
	
	int is_steep = dy > dx;
	
	if (is_steep) {
		swap(&x0, &y0);
		swap(&x1, &y1);
	}
	if (x0 > x1) {
		swap(&x0, &x1);
		swap(&y0, &y1);
	}
	
	dx = x1 - x0;
	dy = abs(y1 - y0);
	int err = -(dx/2);
	int y = y0;
	int y_step;
	if (y0 < y1) y_step = 1;
	else y_step = -1;
	
	for (int x = x0; x < x1; x ++){
		if(is_steep) plot_pixel(y, x, line_color);
		else plot_pixel(x,y,line_color);
		err += dy;
		if (err > 0){
			y += y_step;
			err -= dx;
		}
	}	
}
	
void swap(int *a, int *b){
	int temp = *a;
	*a = *b;
	*b = temp;
}

int abs(int x){
	if (x < 0)
		return -1 * x;
	else return x;
}

void clear_screen() {
	for (int y = 0; y < 239; y ++){
		draw_line(0,y,319,y, 0);
	}
}