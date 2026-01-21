# FFmpeg Audiot process Example

```bash
# asetrate=44100*1.2, aresample=44100：将采样率提高1.2倍再重采样回原速率，实现升调（关键）。
# atempo=1.1：将语速加快1.1倍。
# equalizer=f=3000:t=h:width=1000:g=5：在3000Hz频率附近做一个高频提升，让声音更“亮”。
ffmpeg -i input.m4a -af "asetrate=44100*1.2, aresample=44100, atempo=1.1, equalizer=f=3000:t=h:width=1000:g=5" -c:a aac output.m4a



# asetrate=44100*1.2	asetrate=44100*1.08	核心调整。升调系数从1.2大幅降至1.08。这是解决“尖锐”最关键的一步，让音高提升更自然。
# equalizer=...	（已移除）	关键调整。直接移除了高频提升滤镜。这个滤镜是“刺耳”感的主要来源，移除后声音会立刻变得柔和。
# atempo=1.05	将语速提升从1.1倍微降至1.05倍。更平缓的加速有助于营造“平稳”感，避免急促。
# afftdn=nf=-20	新增降噪滤镜。它能有效降低稳定的背景底噪（如电流声、呼吸声），让声音主体更突出、干净，极大提升“平稳”和“柔和”的听感。nf=-20表示将噪声基准线降至-20dB，是一个中等强度。
# vibrato=f=5:d=0.3	新增轻微颤音。一个非常轻微、缓慢的颤音（5Hz频率，0.3深度）能为声音增加一丝自然的生动感，避免过于机械。请谨慎使用，如果不需要可整体移除。
ffmpeg -i input.m4a -af "asetrate=44100*1.08, aresample=44100, atempo=1.05, afftdn=nf=-20, vibrato=f=5:d=0.3" -c:a aac output-2.m4a


# 将播放速度精确调整为原始速度的1.1倍，即加快10%
# -b:a 192k 保持较高音质 表示 192 kbps
ffmpeg -i input.m4a -af "asetrate=44100*1.08, aresample=44100, atempo=1.10, afftdn=nf=-20, vibrato=f=5:d=0.3" -c:a aac -b:a 192k output-3.m4a

```