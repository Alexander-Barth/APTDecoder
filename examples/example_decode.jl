import APTDecoder
import SatelliteToolbox
using Statistics
using PyPlot
using WAV

# file name as recorde by gqrx
wavname = "gqrx_20190823_173900_137620000.wav"

# name of the satellite, as used by www.celestrak.com
satellite_name = "NOAA 15"

# satellite orbit information (TLE)
# https://en.wikipedia.org/wiki/Two-line_element_set
tles = SatelliteToolbox.read_tle("weather-20190823.txt")

# load the wav file
y,Fs,nbits,opt = wavread(wavname)

# decode to image
datatime,(channelA,channelB),data = APTDecoder.decode(y,Fs)

vmin,vmax = quantile(view(data,:),[0.01,0.99])
data[data .> vmax] .= vmax;
data[data .< vmin] .= vmin;

figure("APTDecoder")
cmap = "RdYlBu_r"
subplot(2,1,1);
imshow(reverse(reverse(data,dims=1),dims=2), aspect="auto", cmap=cmap);
title("Raw data")

starttime = APTDecoder.starttimename(wavname)

# TLEs are downloaded if omited
Alon,Alat,Adata = APTDecoder.georeference(channelA,satellite_name,datatime,starttime; tles=tles)
subplot(2,2,3)
APTDecoder.plot(Alon,Alat,Adata)
title("Channel A")

Blon,Blat,Bdata = APTDecoder.georeference(channelB,satellite_name,datatime,starttime; tles=tles)
subplot(2,2,4)
APTDecoder.plot(Blon,Blat,Bdata)
title("Channel B")

savefig("example_decode.png")