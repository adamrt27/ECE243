#include <stdlib.h>

volatile int pixel_buffer_start; // global variable
short int Buffer1[240][512]; // 240 rows, 512 (320 + padding) columns 
short int Buffer2[240][512];

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
	volatile int * pixel_ctrl_ptr = (int *) 0xff203020; // base address
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

// x and y are middle of box
void draw_box(int x, int y, int side_len, short int col){
	for(int i = x - side_len/2; i < x + side_len/2; i ++){
		for(int j = y - side_len/2; j < y + side_len/2; j ++) {
			if (i < 0)
				continue;
			else if (i > 319)
				continue;
			if (j < 0)
				continue;
			if (j > 239)
				continue;
			plot_pixel(i, j, col);
		}
	}
}


int main(void) {
	
	volatile int * pixel_ctrl_ptr = (int *)0xFF203020;
	
	int num_boxes = 8;
	int col = 0xf81f;
	
	
	/* set front pixel buffer to Buffer 1 */
	*(pixel_ctrl_ptr + 1) = (int) &Buffer1; // first store the address in the back buffer
	/* now, swap the front/back buffers, to set the front buffer location */ 
	wait_for_vsync();
	/* initialize a pointer to the pixel buffer, used by drawing functions */ 
	pixel_buffer_start = *pixel_ctrl_ptr;
	clear_screen(); // pixel_buffer_start points to the pixel buffer
	
	/* set back pixel buffer to Buffer 2 */
	*(pixel_ctrl_ptr + 1) = (int) &Buffer2;
	pixel_buffer_start = *(pixel_ctrl_ptr + 1); // we draw on the back buffer 
	clear_screen(); // pixel_buffer_start points to the pixel buffer

	// create array to hold location of boxes, where box[i][0] is x_location
	int box_pos[num_boxes][2];
	// dx and dy
	int box_dir[num_boxes][2];
	// color of each box
	int colors[5] = { 0xffff, 0xf800, 0x07e0, 0x001f, 0xf81f};
	int box_color[num_boxes];
	// initialize each box randomly
	for (int i = 0; i < num_boxes; i ++){
		box_pos[i][0] = rand() % 320;
		box_pos[i][1] = rand() % 240;
	}
	// initialize each box_dir randomly
	for (int i = 0; i < num_boxes; i ++){
		box_dir[i][0] = ((rand() % 2) * 2) - 1;
		box_dir[i][1] = ((rand() % 2) * 2) - 1;
	}
	// initialize box_color randomly
	for (int i = 0; i < num_boxes; i ++){
		box_color[i] = colors[rand() % 5];
	}
		
	while (1) {
        /* Erase any boxes and lines that were drawn in the last iteration */
		clear_screen();
		
        // get dy and dx for each box and update position
		for (int i = 0; i < num_boxes; i ++){
			
			// update position, but check that its within the range
			box_pos[i][0] += box_dir[i][0];
			if (box_pos[i][0] < 0) {
				box_pos[i][0] = 0;
				box_dir[i][0] *= -1;
			} else if (box_pos[i][0] > 319) {
				box_pos[i][0] = 319;
				box_dir[i][0] *= -1;
			}
			box_pos[i][1] += box_dir[i][1];
			if (box_pos[i][1] < 0) {
				box_pos[i][1] = 0;
				box_dir[i][1] *= -1;
			} else if (box_pos[i][1] > 239) {
				box_pos[i][1] = 239;
				box_dir[i][1] *= -1;
			}
		}
		
		// draw each box and lines
		for (int i = 0; i < num_boxes; i ++){
			draw_box(box_pos[i][0],box_pos[i][1], 10, box_color[i]);
			if (i < num_boxes - 1)
				draw_line(box_pos[i][0],box_pos[i][1],box_pos[i + 1][0],box_pos[i + 1][1], box_color[i]);
		}
				
		wait_for_vsync(); // swap front and back buffers on VGA vertical sync
		pixel_buffer_start = *(pixel_ctrl_ptr + 1); // new back buffer 
	}
}

