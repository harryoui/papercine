#!/bin/bash

movie_dir="/Users/harryallen/Movies" # Where your movies are stored
working_dir="/Users/harryallen/scripts/wallpaper" # Where the script is stored

charging_status=$(pmset -g ps | head -1 | cut -d\' -f2)
if [ "${charging_status}" = "Battery Power" ]; then
	echo "Battery is not charging"
	exit 0
fi

function calc_resolution() {
	# Find the ideal image resolution based on screen's aspect ratio
	# Param: $1 = Wallpaper Image Path

	sys_resolution="$(system_profiler SPDisplaysDataType | grep -oE 'Resolution.*Retina' | grep -oE '[0-9]{4}')"

	sys_width="$(echo "$sys_resolution" | head -1)" # 2560
	sys_height="$(echo "$sys_resolution" | tail -1)" # 1600

	img_resolution="$(file $1 | grep -oE 'data,.*?,' | grep -oE '[0-9]{3,4}')"

	img_width="$(echo "$img_resolution" | head -1)"
	img_height="$(echo "$img_resolution" | tail -1)"

	max_width="$(awk -v img_h=$img_height -v sys_h=$sys_height -v sys_l=$sys_width 'BEGIN{print int(img_h*(sys_l/sys_h))}')"
	max_height="$(awk -v img_l=$img_width -v sys_h=$sys_height -v sys_l=$sys_width 'BEGIN{print int(img_l*(sys_h/sys_l))}')"

	final_resolution=$(echo -e "0\n0")
	if [[ $max_width -le $img_width ]]
	then
		echo Picked max_width for crop
		final_resolution=$(echo -e "${max_width}\n${img_height}")
	else
		echo Picked max_height for crop
		final_resolution=$(echo -e "${img_width}\n${max_height}")
	fi

	final_width=$(echo "$final_resolution" | head -1)
	final_height=$(echo "$final_resolution" | tail -1)
}

if [ ! -f "$1" ]; then
	# A file wasn't given
	# Find statement only gets files of cur dir (not recursive)
	# Edit below line to include more filetypes within search
	movie=$(find ${movie_dir} -maxdepth 1 -not -type d -name '*.mp4' -or -name '*.mkv' | sort -R | tail -n1)
else
	# A file was given
	movie=$1
fi

echo $movie

suf="${movie##*.}"
if [ "$suf" != "mp4" ] && [ "$suf" != "mkv" ] && [ "$suf" != "avi" ] && [ "$suf" != "mov" ]  && [ "$suf" != "gif" ] && [ "$suf" != "flv" ];then
	echo "Input needs to be a video"
	exit 1
fi

timestamp=$(date +%s) # Seconds timestamp for unique filename

basic_location=${working_dir}/wallpaper-${timestamp} # # e.g. wallpaper-1582614269 (no extension)
location=${basic_location}.png
duration=$(ffmpeg -i "$movie" 2>&1 | grep Duration | awk '{print $2}' | tr -d ,)
seconds=$(echo "$duration" | awk -F: '{ print ($1 * 3600) + ($2 * 60) + $3 }')
seconds=${seconds%.*}

echo Movie duration: $duration

if [ "$seconds" -le 0 ];then
	echo "Sommat's broke"
	exit 1
fi
randpoint=$((1 + RANDOM % $seconds))

echo Chosen timestamp: $randpoint

rm ${working_dir}/wallpaper-*.png 2>/dev/null # Remove old wallpaper files

echo Generating movie snapshot
ffmpeg -ss "$randpoint" -i "$movie" -vframes 1 "$location" -y > /dev/null 2>&1

echo Calculating perfect crop
calc_resolution $location

echo Cropping...
ffmpeg -i ${location} -vf "crop=${final_width}:${final_height}" ${basic_location}-aspect.png > /dev/null 2>&1

echo Scaling...
ffmpeg -i ${basic_location}-aspect.png -vf scale=${sys_width}:${sys_height} ${basic_location}-super.png > /dev/null 2>&1

anno_txt_movie=$(echo ${movie%.*} | awk -F "/" '{print $NF}')
anno_txt_hour=$(awk "BEGIN{print int($randpoint/60/60)}")
anno_txt_min=$(awk "BEGIN{print int($randpoint/60/60%1*60)}")
anno_txt_sec=$(awk "BEGIN{print int($randpoint/60%1*60)}")
anno_txt=$(echo -e "$anno_txt_movie\n$anno_txt_hour\:$anno_txt_min\:$anno_txt_sec")

fontsize=11
txt_height=44

echo Annotating...

ffmpeg -i ${basic_location}-super.png -vf "drawtext=text='${anno_txt}':fontcolor=white:fontsize=${fontsize}:x=0:y=${txt_height}" ${basic_location}-annotated.png > /dev/null 2>&1

echo ${sys_width}x${sys_height} \> ${img_width}x${img_height} \> ${max_width}\|${max_height} \> ${final_width}x${final_height} \> ${sys_width}x${sys_height}
wallpaper set ${basic_location}-annotated.png --screen all

echo Success
exit 0
