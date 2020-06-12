#/bin/sh
  
IFS=$'\n'

for fn in $(find /path/to/your/files -name *.mkv -type f)
do
        newtitle=$(basename $fn .mkv)
        oldtitle=$(mkvinfo $fn | grep "+ Titel:" | sed 's/| + Titel: \(.*\)$/\1/g')
        if [ "$oldtitle" != "$newtitle" ]; then
                echo "Old title: $oldtitle"
                echo "New title: $newtitle"
                mkvpropedit "$fn" --edit info --set "title=$newtitle"
        fi
done
