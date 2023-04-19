![Raspberry NOAA Hack]

This is a quick and dirty remix of [raspberry-noaa-v2] (https://github.com/jekhokie/raspberry-noaa-v2.git), in turn based on [raspberry-noaa](https://github.com/reynico/raspberry-noaa). I had originally been using the reynico version with some success, but had to rebuild my system.

Hopefully I've put down enough breadcrumbs here so that I can build a new installation quickly if my SD card crashes again.

I restored SSTV reception from the ISS using [pd120_decoder] (https://github.com/reynico/pd120_decoder.git) - in the past I've found it to be less capable of pulling an image than some of the PC software but there's no ARISS SSTV activity at the moment to test with.

I've also tried to capture SPROUT's SSTV Sunday broadcasts, decoding using [sstv] (https://github.com/colaclanth/sstv.git) - so far nothing... but I'm not sure SPROUT still sends SSTV or if it's even active.

I'm using [RTL-SDR] (git://git.osmocom.org/rtl-sdr.git) and rtl_fm - the gnuradio option has NOT been tested at all.

I've also added the option of specifying "usb" rather than "-T" to the bias tee settings. "-T" will continue to drive bias tee via GPIO, while "usb" will enable the bias tee via the RTL-SDR V3 USB dongle option (https://github.com/rtlsdrblog/rtl-sdr-blog).


