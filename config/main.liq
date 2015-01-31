#!/usr/bin/env liquidsoap

set("log.file", true)
set("log.stdout", true)
set("log.level", 5)
set("server.telnet", true)
set("server.telnet.port", 5000)
set("log.file.path", "/tmp/broadcast.log")
set("audio.converter.samplerate.libsamplerate.quality","best")
set("buffering.path","/tmp")
set("decoding.buffer_length",10.)

clock = mksafe(audio_to_stereo(playlist(reload=60, "/playlists/singles/", mode="random")))
jingles = mksafe(audio_to_stereo(playlist(reload=60, "/playlists/jingles", mode="random")))
songs = mksafe(audio_to_stereo(playlist(reload=60, "/playlists/songs", mode="random")))

live = input.harbor("m1ch3l.live", id="m1ch3l.live", port=5001, password="LIVE_PASSWORD", user="source")
live = audio_to_stereo(live)
#live = strip_blank(live, length=10., threshold=-50.)

def custofade(previous, next)
  #source.skip(next)
  add([fade.initial(duration=2., type="exp", next), previous])
end

input = random(weights=[5,2], [jingles, songs])
input = add([input, switch([({0m0s}, clock)])])
input = add([input, amplify(5., override="replay_gain", live)])
#input = fallback(track_sensitive=true,
#                 transitions=[custofade],
#                 [ input ])
input = fallback(track_sensitive=false, [input])
input = mksafe(input)

output.icecast(host="HARBOR_HOST",
               port=HARBOR_PORT,
               password="HARBOR_PASSWORD",
               %mp3(bitrate=128),
               mount="m1ch3l.main",
               input)
