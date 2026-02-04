#!/usr/bin/env python3
"""Generate small sine-wave WAV files for system sounds (simple, no external deps)
Usage: python3 generate_sounds.py outdir
"""
import sys
import wave
import math
import struct

OUT = sys.argv[1] if len(sys.argv) > 1 else "./initrd/opt/sounds"

import os
os.makedirs(OUT, exist_ok=True)

def write_tone(path, freq=440, duration=0.2, samp_rate=44100, amp=16000):
    n = int(duration * samp_rate)
    with wave.open(path, 'w') as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)
        wf.setframerate(samp_rate)
        for i in range(n):
            t = float(i) / samp_rate
            v = int(amp * math.sin(2 * math.pi * freq * t))
            wf.writeframes(struct.pack('<h', v))

write_tone(os.path.join(OUT, 'start.wav'), freq=660, duration=0.18)
write_tone(os.path.join(OUT, 'click.wav'), freq=880, duration=0.08)
write_tone(os.path.join(OUT, 'success.wav'), freq=880, duration=0.18)
print('Sounds generated in', OUT)