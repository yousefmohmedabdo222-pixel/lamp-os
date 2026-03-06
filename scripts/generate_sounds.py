#!/usr/bin/env python3
"""Generate small sine-wave WAV files for system sounds (simple, no external deps)
Usage: python3 generate_sounds.py outdir
"""
import sys
import wave
import math
import struct
import os

OUT = sys.argv[1] if len(sys.argv) > 1 else "./initrd/opt/sounds"

os.makedirs(OUT, exist_ok=True)


def write_tones(path, tones, samp_rate=44100, amp=16000):
    """Generate a sequence of sine tones and write them to `path`."""
    with wave.open(path, 'w') as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)
        wf.setframerate(samp_rate)
        for freq, duration in tones:
            n = int(duration * samp_rate)
            for i in range(n):
                t = float(i) / samp_rate
                v = int(amp * math.sin(2 * math.pi * freq * t))
                wf.writeframes(struct.pack('<h', v))

# premium edition definitions
sound_map = {
    'boot.wav': [(1000, 0.2), (1200, 0.2), (1500, 0.3)],
    'login.wav': [(800, 0.1), (1200, 0.2)],
    'success.wav': [(1000, 0.1), (1500, 0.2)],
    'error.wav': [(400, 0.15), (300, 0.15)],
    'shutdown.wav': [(1500, 0.2), (1200, 0.2), (1000, 0.3)],
}

for name, tones in sound_map.items():
    dest = os.path.join(OUT, name)
    write_tones(dest, tones)

print('Sounds generated in', OUT)
