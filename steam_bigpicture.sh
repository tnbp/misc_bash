#!/bin/sh

xrandr -s 1920x1080

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

PACTL_DEFAULT_CARD=$(pactl list short cards | grep alsa_card.pci-0000_08_00.4 | sed 's/^\([0-9]\+\).*$/\1/g')
pactl set-card-profile "$PACTL_DEFAULT_CARD" output:analog-stereo

xrandr -s 3840x2160
