#!/usr/bin/env zsh
# ion-screenshot.zsh : Mark Tran <mark@nirv.net>

# Take a screenshot of each workspace. Requires ImageMagick and mod_ionflux-3.

DATE=$(date '+%Y%m%d')
SCREENSHOT_DIR="$HOME/Media/pictures/screenshots"

mkdir -p $SCREENSHOT_DIR/$DATE
sleep 5
beep

WORKSPACE_COUNT=$(ionflux -e "return ioncore.find_screen_id(0):mx_count()")
for ((i=1; i<=$WORKSPACE_COUNT; i++)); do
    workspace_index=$(ionflux -e "return ioncore.find_screen_id(0):get_index(\
                                  ioncore.find_screen_id(0):mx_current())+1")

    sleep 1
    import -window root -silent $SCREENSHOT_DIR/$DATE/$workspace_index.png
    ionflux -e "ioncore.find_screen_id(0):switch_next()" > /dev/null
done

beep
