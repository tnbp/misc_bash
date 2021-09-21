#!/bin/sh

## CHANGE THESE TO FIT YOUR SETUP ##

TARGET_RESOLUTION="1920x1080"
PULSE_DEFAULT_CARD="alsa_card.pci-0000_08_00.4"

## END USER VARIABLES ##

DISP_ORIGINAL=$(xrandr | grep -E '(^|\W)connected' -A 1 | grep -v -- --)

DISP_DEVICES=$(echo "$DISP_ORIGINAL" | grep connected | sed 's/^\(.*\)[[:blank:]]\+connected.*/\1/')
DISP_PRIMARY=$(echo "$DISP_ORIGINAL" | grep primary | sed 's/^\(.*\)[[:blank:]]\+connected primary.*/\1/')

DISP_XRANDR_CMD_APPLY="xrandr"
DISP_XRANDR_CMD_RESTORE="xrandr"

for CURRENT_DEVICE in $DISP_DEVICES
do
        CURRENT_RES_AND_POS=$(echo "$DISP_ORIGINAL" | grep "$CURRENT_DEVICE connected" | sed 's/.*connected.*[[:blank:]]\+\([0-9]\+x[0-9]\++[0-9]\++[0-9]\+\).*/\1/')
        DISP_RESOLUTION=$(echo "$CURRENT_RES_AND_POS" | sed 's/\([0-9]\+x[0-9]\+\)+.*/\1/')
        DISP_POSITION=$(echo "$CURRENT_RES_AND_POS" | sed 's/[0-9]\+x[0-9]\++\([0-9]\+\)+\([0-9]\+\)/\1x\2/')
        DISP_REFRATE=$(echo "$DISP_ORIGINAL" | grep "$CURRENT_DEVICE connected" -A1 | grep -v connected | sed 's/.*[[:blank:]]\([0-9]\+\.[0-9]\+\)\*.*/\1/')
        if [ "$CURRENT_DEVICE" == "$DISP_PRIMARY" ]; then
                DISP_XRANDR_CMD_RESTORE="$DISP_XRANDR_CMD_RESTORE --output $CURRENT_DEVICE --primary --mode $DISP_RESOLUTION --pos $DISP_POSITION --rate $DISP_REFRATE --auto"
                DISP_XRANDR_CMD_APPLY="$DISP_XRANDR_CMD_APPLY --output $CURRENT_DEVICE --primary --mode $TARGET_RESOLUTION --rate $DISP_REFRATE --auto"
        else
                DISP_XRANDR_CMD_RESTORE="$DISP_XRANDR_CMD_RESTORE --output $CURRENT_DEVICE --mode $DISP_RESOLUTION --pos $DISP_POSITION --rate $DISP_REFRATE --auto"
                DISP_XRANDR_CMD_APPLY="$DISP_XRANDR_CMD_APPLY --output $CURRENT_DEVICE --off"
        fi
done

$DISP_XRANDR_CMD_APPLY

PACTL_ALL_CARDS=$(pactl list short cards | sed 's/^\([0-9]\+\).*$/\1/g')

for card in $PACTL_ALL_CARDS
do
        pactl set-card-profile "$card" off
done

STEAM_PID=$(pidof steam | cut -d ' ' -f1)
if [[ -z $STEAM_PID ]]; then
        steam -bigpicture &
        STEAM_PID=$!
        wait $STEAM_PID
else
        steam steam://open/bigpicture &
        while [ -e /proc/$STEAM_PID ]; do sleep 5; done
fi

PACTL_DEFAULT_CARD=$(pactl list short cards | grep "$PULSE_DEFAULT_CARD" | sed 's/^\([0-9]\+\).*$/\1/g')
pactl set-card-profile "$PACTL_DEFAULT_CARD" output:analog-stereo

$DISP_XRANDR_CMD_RESTORE
