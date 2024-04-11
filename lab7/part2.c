int pixel_buffer_start; // global variable


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

void wait_for_vsync()
{
	volatile int * pixel_ctrl_ptr = (int *) 0xff203030; // base address
	int status;
	*pixel_ctrl_ptr = 1; 			// start the synchronization process
									// - write 1 into front buffer address register
	status = *(pixel_ctrl_ptr + 3); // read the status register
	while ((status & 0x01) != 0) 	// polling loop waiting for S bit to go to 0
	{
		status = *(pixel_ctrl_ptr + 3);
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

void clear_screen()
{
	memset(pixel_buffer_start, 0, 0x3BE7E);
}


int main(void) {
	
	volatile int * pixel_ctrl_ptr = (int *)0xFF203020;
	/* Read location of the pixel buffer from the pixel buffer controller */ 
	pixel_buffer_start = *pixel_ctrl_ptr;
	
	int y = 1;
	int dir = 1;
	int col = 0xf81f;
		
	
	wait_for_vsync();
	clear_screen();
	draw_line(0, y, 320, y, col);
	while(1){
		wait_for_vsync();
		clear_screen();
		if (y < 239 & y > 0)
			y += dir;
		else 
			dir *= -1;
			y += dir;
		
		draw_line(0, y, 320, y, col);// this line is blue
	} 
}
