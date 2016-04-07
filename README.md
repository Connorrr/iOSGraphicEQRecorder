# iOSGraphicEQRecorder
This application takes the iPhone mic input and performs a realtime FFT.  The Graphic EQ is displayed in a StackView subclass and the audio is saved as a WAV file.

# Features
 * CoreAudio Mic Input
 * Sampling at 44.1KHz 
 * Save as Wav File
 * Circular Buffer of size 1024 Bytes
 * Stack View FFT with variable size
 * 1 Channel / Frame. 1 Frame / Packet
 * 16 Bit PCM
 
#  "I've been looking through Core Audio repos all day.  Is there anything  in this for me?"
Welll,  have you been wading through the torturous hell fire that is Core Audio?
Are you trying to do this in Swift for some reason when 99% of the CA examples are in Obj-C?
Do you just want a schmick looking graphic equalizer that's light on resources?

This should help out a bit.  I'm still fairly new to Core Audio so if you are interested in swapping stories, send me an email (Connor.reid87@gmail.com)

# Credits
Big Thanks to Mattt Thompson (http://mattt.me) for coding the FFT function.

# Todo
* Graphic EQ UI not updating quick enough (Audio Buffers and CADisplayLink aren't in sync).  IF ANYONE CAN HELP ME FIGURE THIS ONE OUT, PLEASE GET IN TOUCH.
* General cleanup
* fix bug with button press crash

# Notes
The UI isn't really the point of this one...  So it's ugly...  Graphic EQ looks pretty cool though.
