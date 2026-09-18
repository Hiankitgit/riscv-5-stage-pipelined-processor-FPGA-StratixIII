import os

# Opens your raw C-code hex dump
with open("instruction.mif", "w") as f_out:
    f_out.write("WIDTH=32;\n")
    f_out.write("DEPTH=1024;\n")
    f_out.write("ADDRESS_RADIX=UNS;\n")
    f_out.write("DATA_RADIX=HEX;\n")
    f_out.write("CONTENT BEGIN\n")
    
    try:
        with open("instruction.mem", "r") as f_in:
            words = []
            # Read line by line, stripping out the toxic '@' address headers from objcopy
            for line in f_in:
                line = line.strip()
                if not line or line.startswith('@'):
                    continue
                # Split by space in case objcopy puts multiple words on one line
                words.extend(line.split())
                
            # Write the clean hex words into the MIF format
            for i, hex_val in enumerate(words):
                if i < 1024:  # Prevent overflow if the C program gets too large
                    f_out.write(f"\t{i} : {hex_val};\n")
            
            # Fill the rest of the 4KB memory with NOPs (00000013)
            if len(words) < 1024:
                f_out.write(f"\t[{len(words)}..1023] : 00000013;\n")
                
    except FileNotFoundError:
        f_out.write("\t[0..1023] : 00000013;\n")
        
    f_out.write("END;\n")

print("Success! Created instruction.mif for Quartus.")