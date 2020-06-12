#/bin/sh

IFS=$'\n'

for fn in $(find /path/to/your/files -name *.mp4 -type f)
do
        newtitle=$(basename $fn .mp4)
        oldtitle=$(AtomicParsley $fn -t | grep "nam\"" | sed 's/.*contains: \(.*\)$/\1/g')
        if [ "$oldtitle" != "$newtitle" ]; then
                echo "Old title: $oldtitle"
                echo "New title: $newtitle"
                AtomicParsley "$fn" -title "$newtitle"
        fi
done
