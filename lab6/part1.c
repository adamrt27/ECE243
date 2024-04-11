int main(void)
{
	volatile int *LEDR_ptr = 0xFF200000;
	volatile int *KEY_ptr = 0xFF200050;
	int edge_cap;
	while (1) { // infinite loop
		edge_cap = *(KEY_ptr + 3); // dereference SW_ptr - equiv to ldwio above
		if (edge_cap & 1) {
			*LEDR_ptr = 0xFFFF; // dereference LED_ptr - equiv to stwio
			*(KEY_ptr + 3) = 1; // reset edge capture
		}
		else if (edge_cap & 2) {
			*LEDR_ptr = 0; // dereference LED_ptr - equiv to stwio
			*(KEY_ptr + 3) = 2; // reset edge capture
		}
	}
}