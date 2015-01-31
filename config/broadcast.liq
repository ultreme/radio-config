#!/usr/bin/env liquidsoap

set("log.file", true)
set("log.stdout", true)
set("log.level", 4)
set("server.telnet", true)
set("server.telnet.port", 5000)
set("log.file.path", "/tmp/broadcast.log")
set("audio.converter.samplerate.libsamplerate.quality","best")
set("buffering.path","/tmp")
set("decoding.buffer_length",10.)

icecast_password="ICECAST_PASSWORD"
harbor_password="HARBOR_PASSWORD"

m1ch3l_out = output.icecast(description="Radio M1ch3l", genre="Hacking", url="http://m1ch3l.biz/")

output_balrog.icecast = m1ch3l_out(host="212.83.158.125", port=8000, password=icecast_password)
output_hobbit.icecast = m1ch3l_out(host="212.129.20.90", port=8000, password=icecast_password)

def outputs(encoder, ~mount, input)
    output_balrog.icecast(encoder, mount=mount, input)
    output_hobbit.icecast(encoder, mount=mount, input)
end

default = single("/playlists/failures/default.mp3")
harbor_input = input.harbor("m1ch3l.main", port=5001, password=harbor_password)

input = mksafe(fallback(track_sensitive=false, [ harbor_input, default ]))

outputs(%mp3(bitrate=128), mount="/m1ch3l-128.mp3", input)
