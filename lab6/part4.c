#define AUDIO_BASE 0xFF203040
int main(void) {

// Audio port structure
struct audio_t {
	volatile unsigned int control; // The control/status register
	volatile unsigned char rarc; // the 8 bit RARC register
	volatile unsigned char ralc; // the 8 bit RALC register
	volatile unsigned char wsrc; // the 8 bit WSRC register
	volatile unsigned char wslc; // the 8 bit WSLC register
	volatile unsigned int ldata;
	volatile unsigned int rdata;
};
	
	// output(t) = input(t) + D * output(t - N)
	
	/* we don't need to 'reserve memory' for this, it is already there
	so we just need a pointer to this structure */
	struct audio_t *const audiop = ((struct audio_t *) AUDIO_BASE);
	
	// to hold values of samples
	int left, right;
	int left_in, right_in;
	
	// to hold the value of N
	int N = 3000;
	
	// to hold valye of D
	double D = 0.5;
	
	// hold hold previous N values of input
	int del_l[N], del_r[N];
	int count = 0;
	int start = 1;
	// infinite loop checking the RARC to see if there is at least a single
	// entry in the input fifos. If there is, just copy it over to the output fifo.
	// The timing of the input fifo controls the timing of the output
	while (1) {
		if ( audiop->rarc > 0) // check RARC to see if there is data to read
		{	
			
			// load both input microphone channels - just get one sample from each
			left_in = audiop->ldata; // load the left input fifo
			right_in = audiop->rdata; // load the right input fifo
			
			if (!start){
				left = left_in + (del_l[count] * D) ;
				right = right_in + (del_r[count] * D);
			} else {
				left = left_in;
				right = right_in;
			}
			
			del_l[count] = left;
			del_r[count] = right;
			
			if(count < N){	
				count ++;
			} else {
				if(start)
					start = 0;
				count = 0;
			}
			
			
			audiop->ldata = left; // store to the left output fifo
			audiop->rdata = right; // store to the right output fifo
			
			
			// shift over arrays and add inputs to arrays
		}
		
	}
}
