==============================================================================

1. DEFINE THE MAIN SYSTEM CLOCK

==============================================================================

The Stratix III / Cyclone IV boards have a physical 50 MHz crystal oscillator.

Period = 1 / Frequency

Period = 1 / 50,000,000 Hz = 0.00000002 seconds = 20.0 nanoseconds

We tell Quartus to expect a clock pulse exactly every 20.0 ns on the input pin.

create_clock -name clk_50mhz -period 20.0 [get_ports {clk_50mhz}]

==============================================================================

2. DERIVE CLOCK UNCERTAINTY

==============================================================================

No crystal oscillator is perfect. The 'derive_clock_uncertainty' command tells

Quartus to automatically calculate real-world physical jitter, noise, and

temperature variations so it builds in a safety margin for your logic.

derive_clock_uncertainty

==============================================================================

3. UNCONSTRAINED I/O (Optional but good practice)

==============================================================================

We tell TimeQuest not to worry about how fast the LEDs update, because

human eyes can't see nanosecond delays anyway.

set_false_path -from * -to [get_ports {user_led[*]}]
