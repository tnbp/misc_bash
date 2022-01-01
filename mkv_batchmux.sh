#!/bin/bash

F1_PATH="/path/to/first/set/of/videos"
F1_PATTERN="Super Cool Series 5x*.mkv"
F2_PATH="/path/to/second/set/of/videos"
F2_PATTERN="Cool Series But Spanish 5x*.mkv"

OUTPUT_DIR="/path/to/output/dir/without/trailing/slash"

F1_FILES=$(find "$F1_PATH" -name "$F1_PATTERN")
F2_FILES=$(find "$F2_PATH" -name "$F2_PATTERN")

IFS=$'\n'

for FILE in $F1_FILES
do
	FILENAME=${FILE##*/}
	EPISODE_NO=$(echo "$FILENAME" | sed "s/[^0-9x]\+//g") # needs adjusting
	echo -n "Muxing episode: $EPISODE_NO | F1: $FILE | "
	for F2_FILE in $F2_FILES
	do
		F2_FILENAME=${F2_FILE##*/}
		F2_EPISODE_NO=$(echo "$F2_FILENAME" | sed "s/[^0-9x]\+//g") # needs more adjusting
		if [[ "$F2_EPISODE_NO" == "$EPISODE_NO" ]]; then
			F2_FOUND="$F2_FILE"
			break
		fi
	done
	if [ -n "$F2_FOUND" ]; then
		echo -n " F2: $F2_FOUND"
		# please alter according to your deepest, darkest desires
		mkvmerge -o "$OUTPUT_DIR/$FILENAME" --default-track 0:1 --default-track 1:0 --default-track 3:0 -d \!3 --track-name 0:"" --track-name 1:"" --track-name 2:"" "$FILE" -D --default-track 1:1 --language 1:ger --track-name 1:"" "$F2_FOUND"
	else
		echo -n " UNMATCHED!!!"
	fi
	F2_FOUND=""
done
