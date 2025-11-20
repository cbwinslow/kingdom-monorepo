#!/usr/bin/env bash
# Media Processing Functions

# Convert image format
img_convert() {
    convert "$1" "$2"
}

# Resize image
img_resize() {
    convert "$1" -resize "$2" "$3"
}

# Rotate image
img_rotate() {
    convert "$1" -rotate "$2" "$3"
}

# Image to grayscale
img_gray() {
    convert "$1" -colorspace Gray "$2"
}

# Image quality
img_quality() {
    convert "$1" -quality "$2" "$3"
}

# Batch convert images
img_batch_convert() {
    for img in *."$1"; do
        convert "$img" "${img%.*}.$2"
    done
}

# Create thumbnail
img_thumb() {
    convert "$1" -thumbnail "$2" "thumb_$1"
}

# Add watermark
img_watermark() {
    convert "$1" -pointsize 50 -fill white -gravity southeast -annotate +10+10 "$3" "$2"
}

# Compress image
img_compress() {
    convert "$1" -strip -quality 85 "$2"
}

# Get image dimensions
img_size() {
    identify -format "%wx%h" "$1"
}

# Get image info
img_info() {
    identify -verbose "$1"
}

# Video to GIF
vid_to_gif() {
    ffmpeg -i "$1" -vf "fps=10,scale=320:-1:flags=lanczos" -c:v gif "$2"
}

# Extract audio from video
vid_extract_audio() {
    ffmpeg -i "$1" -vn -acodec copy "${1%.*}.aac"
}

# Video to MP4
vid_to_mp4() {
    ffmpeg -i "$1" -codec:v libx264 -codec:a aac "${1%.*}.mp4"
}

# Compress video
vid_compress() {
    ffmpeg -i "$1" -vcodec libx264 -crf 28 "compressed_$1"
}

# Video info
vid_info() {
    ffprobe -v quiet -print_format json -show_format -show_streams "$1"
}

# Get video duration
vid_duration() {
    ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$1"
}

# Trim video
vid_trim() {
    ffmpeg -i "$1" -ss "$2" -t "$3" -c copy "trimmed_$1"
}

# Merge videos
vid_merge() {
    ffmpeg -f concat -safe 0 -i <(for f in "$@"; do echo "file '$PWD/$f'"; done) -c copy output.mp4
}

# Add subtitles to video
vid_subtitle() {
    ffmpeg -i "$1" -vf subtitles="$2" "subtitled_$1"
}

# Convert audio format
audio_convert() {
    ffmpeg -i "$1" "${1%.*}.$2"
}

# Normalize audio
audio_normalize() {
    ffmpeg -i "$1" -filter:a loudnorm "normalized_$1"
}

# Adjust audio volume
audio_volume() {
    ffmpeg -i "$1" -filter:a "volume=$2" "volume_$1"
}

# Audio to mono
audio_mono() {
    ffmpeg -i "$1" -ac 1 "mono_$1"
}

# Extract audio snippet
audio_snippet() {
    ffmpeg -i "$1" -ss "$2" -t "$3" "snippet_$1"
}

# Merge audio files
audio_merge() {
    ffmpeg -i "concat:$1|$2" -acodec copy merged.mp3
}

# Remove audio from video
vid_remove_audio() {
    ffmpeg -i "$1" -c copy -an "nosound_$1"
}

# Add audio to video
vid_add_audio() {
    ffmpeg -i "$1" -i "$2" -c:v copy -c:a aac "audio_added_$1"
}

# Screenshot from video
vid_screenshot() {
    ffmpeg -i "$1" -ss "$2" -vframes 1 "screenshot_$1.png"
}

# Create slideshow from images
img_slideshow() {
    ffmpeg -framerate 1 -pattern_type glob -i '*.jpg' -c:v libx264 slideshow.mp4
}

# Video to frames
vid_to_frames() {
    ffmpeg -i "$1" "frame_%04d.png"
}

# Frames to video
frames_to_vid() {
    ffmpeg -framerate 30 -i "frame_%04d.png" -c:v libx264 output.mp4
}

# Speed up video
vid_speedup() {
    ffmpeg -i "$1" -filter:v "setpts=0.5*PTS" "fast_$1"
}

# Slow down video
vid_slowdown() {
    ffmpeg -i "$1" -filter:v "setpts=2.0*PTS" "slow_$1"
}

# Reverse video
vid_reverse() {
    ffmpeg -i "$1" -vf reverse "reverse_$1"
}

# Add fade in/out
vid_fade() {
    ffmpeg -i "$1" -vf "fade=in:0:30,fade=out:300:30" "fade_$1"
}

# Create video thumbnail
vid_thumb() {
    ffmpeg -i "$1" -ss 00:00:05 -vframes 1 "thumb_$1.jpg"
}

# Get video resolution
vid_resolution() {
    ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=s=x:p=0 "$1"
}

# Get video FPS
vid_fps() {
    ffprobe -v error -select_streams v:0 -show_entries stream=r_frame_rate -of default=noprint_wrappers=1:nokey=1 "$1"
}

# Get video bitrate
vid_bitrate() {
    ffprobe -v error -select_streams v:0 -show_entries stream=bit_rate -of default=noprint_wrappers=1:nokey=1 "$1"
}

# Get audio bitrate
audio_bitrate() {
    ffprobe -v error -select_streams a:0 -show_entries stream=bit_rate -of default=noprint_wrappers=1:nokey=1 "$1"
}

# Get audio sample rate
audio_samplerate() {
    ffprobe -v error -select_streams a:0 -show_entries stream=sample_rate -of default=noprint_wrappers=1:nokey=1 "$1"
}

# PDF operations
pdf_merge() {
    gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile=merged.pdf "$@"
}

pdf_split() {
    pdftk "$1" burst output "page_%04d.pdf"
}

pdf_compress() {
    gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/ebook -dNOPAUSE -dQUIET -dBATCH -sOutputFile="compressed_$1" "$1"
}

pdf_to_img() {
    convert -density 150 "$1" -quality 90 "${1%.pdf}.png"
}

pdf_info() {
    pdfinfo "$1"
}

pdf_pages() {
    pdfinfo "$1" | grep Pages | awk '{print $2}'
}

# OCR
img_ocr() {
    tesseract "$1" stdout
}

# QR code
qr_create() {
    qrencode -o qr.png "$1"
}

qr_read() {
    zbarimg "$1"
}

# Screenshot (macOS)
screenshot() {
    screencapture -i "screenshot_$(date +%Y%m%d_%H%M%S).png"
}

# Record screen (macOS)
screenrecord() {
    ffmpeg -f avfoundation -i "1:0" -c:v libx264 -crf 23 -preset ultrafast "recording_$(date +%Y%m%d_%H%M%S).mp4"
}

# Webcam photo
webcam_photo() {
    ffmpeg -f avfoundation -video_size 1280x720 -framerate 30 -i "0" -frames:v 1 "webcam_$(date +%Y%m%d_%H%M%S).jpg"
}

# Play audio
play_audio() {
    afplay "$1" 2>/dev/null || mpg123 "$1" 2>/dev/null || play "$1"
}

# Play video
play_video() {
    open "$1" 2>/dev/null || vlc "$1" 2>/dev/null || mpv "$1"
}

# YouTube download
yt_download() {
    youtube-dl "$1"
}

yt_audio() {
    youtube-dl -x --audio-format mp3 "$1"
}

yt_playlist() {
    youtube-dl -i -o "%(playlist_index)s-%(title)s.%(ext)s" "$1"
}

# Spotify current track (macOS)
spotify_current() {
    osascript -e 'tell application "Spotify" to get name of current track & " - " & artist of current track'
}

# iTunes current track (macOS)
itunes_current() {
    osascript -e 'tell application "Music" to get name of current track & " - " & artist of current track'
}
