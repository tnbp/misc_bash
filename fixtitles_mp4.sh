#/bin/sh

IFS=$'\n'

for fn in $(find /net/external/Serien/ -name *.mp4 -type f)
do
        newtitle=$(basename $fn .mp4)
        oldtitle=$(exiftool "$fn" | grep Title | sed 's/^Title\s*: \(.*\)$/\1/g')
        if [ "$oldtitle" != "$newtitle" ]; then
                echo "Old title: $oldtitle"
                echo "New title: $newtitle"
                exiftool "$fn" -Title="$newtitle"
        fi
done
