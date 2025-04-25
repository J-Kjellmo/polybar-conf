#!/bin/sh

# If the argument is --toggle, toggle Dunst pause state
case "$1" in
    --toggle)
        dunstctl set-paused toggle
        ;;
    *)
        # Show the current state of Dunst: paused or active
        if [ "$(dunstctl is-paused)" = "true" ]; then
            echo "  "  # Paused icon
        else
            echo "  "  # Active icon
        fi
        ;;
esac

