#define AUDIO_BASE 0xFF203040
#define SWITCH_BASE 0xFF200040

void audio_clk(){ // 8kHz clock
	int timer_start = 12500; // multiply by 100M
	
	// start timer
	volatile int* TIMER = 0xFF202020;
	
	*(TIMER) = 0;
	
	// mask lower 16 bits
	int timer_start_low = timer_start & 0xFFFF;
	// shift upper 16 bits down
	int timer_start_high = timer_start >> 16;
	// read into start registers
	*(TIMER + 2) = timer_start_low;
	*(TIMER + 3) = timer_start_high;
	
	// Turn on CONT & START
	*(TIMER + 1) = 0b0110;
	
	// poll for when TO is 0
	while (!(*(TIMER) & 0b1));
	
	// reset
	*(TIMER) = 0;
	
	return;
} 

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
	
	/* we don't need to 'reserve memory' for this, it is already there
	so we just need a pointer to this structure */
	struct audio_t *const audiop = ((struct audio_t *) AUDIO_BASE);
	
	/* we don't need to 'reserve memory' for this, it is already there
	so we just need a pointer to this structure */
	volatile int* swp = (int*)SWITCH_BASE;
	
	// to hold values of samples
	int left, right;
	
	// to hold current value of input
	int cur = 0xFFFFFF;
	// set count counts the number of samples between high and low
	int count = 0;
	// freq is the frequnecy
	int freq = 1000;
	// period is the number of cycles between high and low
	double period = 4000.0 / freq;

	
	// infinite loop
	// checks which switch is on
	// sets frequency
	// generates a new sample every 125ms (8 kHz)
	// stores into left and right
	// reads from left and right
	// repeat
	while (1) {	
		// generate 8 kHz wait
		//audio_clk();
		
		// check if WSRC and WSLC say there is empty slot in FIFO
		if((audiop->wsrc & 0xFF) > 0){
			left = cur; // load the left input fifo
			right = cur; // load the right input fifo

			audiop->ldata = left; // store to the left output fifo
			audiop->rdata = right; // store to the right output fifo

			if (count < period){
				count ++;
			}
			else{
				cur *= -1;
				count = 0;
			}
		}
		// check switches by polling
		if (*swp != freq){
			// update period
			freq = *swp;
			period = 4000.0/freq;
		}		
	}
}
