// ============================================================================
// BARE-METAL RISC-V C CODE
// ============================================================================
 
// 1. HARDWARE MAPPING (Volatile bypasses compiler optimizations)
#define DISPLAY_PORT ((volatile unsigned int*) 0x00002000)
 
// 2. BOOT SEQUENCE (Startup Code)
// Sets physical stack before hitting main()
void __attribute__((naked)) _start() {
    asm volatile("li sp, 4096");
    asm volatile("j main");
}
 
// 3. CUSTOM I/O FUNCTION
void print_out(unsigned int val) {
    *DISPLAY_PORT = val;
}
 // Function to slow down the CPU so human eyes can see the LEDs change
void human_delay() {
    // 5,000,000 loops * ~5 cycles per loop = ~25 million cycles
    // At 50MHz, this creates exactly a ~0.5 second delay
    for (volatile int wait = 0; wait < 5000000; wait++) {
        // Waste clock cycles
    }
}

// 4. MAIN PROGRAM
int main() {
    print_out(0x1111); // Status: Booting
    human_delay();
    int a = 0, b = 1, next = 0, sum = 0;
    
    print_out(a);
       human_delay();
    print_out(b);
    human_delay();
    
    sum = a + b;
    
    // Calculate Fibonacci up to 144
    for (int i = 2; i < 10; i++) {
        next = a + b;
        print_out(next);
        human_delay();
        
        sum += next;
        
        a = b;
        b = next;
        
    }
    
    print_out(sum); // Will output exactly 88 (Hex: 0x58)
    //print_out(0x9999); // Status: Halted
    
    while(1) {} // Terminal loop to prevent reading out-of-bounds memory
    
    return 0;
}
