#!/bin/sh

get_icon() {
    case $1 in
        01d) icon="" ;; # Clear sky (day) -> Should be  or 
        01n) icon="" ;; # Clear sky (night) -> Should be  or 
        02d) icon="" ;; # Few clouds (day) -> Should be 
        02n) icon="" ;; # Few clouds (night) -> Should be 
        03d) icon="" ;; # Scattered clouds (day)
        03n) icon="" ;; # Scattered clouds (night)
        04*) icon="" ;; # Broken clouds -> Should be  or 
        09d) icon="" ;; # Shower rain (day) -> Should be 
        09n) icon="" ;; # Shower rain (night) -> Should be 
        10d) icon="" ;; # Rain (day) -> Should be 
        10n) icon="" ;; # Rain (night) -> Should be 
        11d) icon="" ;; # Thunderstorm (day) -> Should be 
        11n) icon="" ;; # Thunderstorm (night) -> Should be 
        13d) icon="" ;; # Snow (day) -> Should be 
        13n) icon="" ;; # Snow (night) -> Should be 
        50d) icon="" ;; # Mist (day) -> Should be 
        50n) icon="" ;; # Mist (night) -> Should be 
        *) icon="" ;; # Unknown condition -> Maybe 
    esac
    echo $icon
}

get_duration() {
    osname=$(uname -s)
    case $osname in
        *BSD) date -r "$1" -u +%H:%M;;
        *) date --date="@$1" -u +%H:%M;;
    esac
}

KEY="32a5fc67e49ceb0d818461e8dfdb733e"
CITY="Tromsø, NO"
UNITS="metric"
SYMBOL="°"
API="https://api.openweathermap.org/data/2.5"

CITY_PARAM="q=Tromsø%2CNO"

current=$(curl -sf "$API/weather?appid=$KEY&$CITY_PARAM&units=$UNITS")
forecast=$(curl -sf "$API/forecast?appid=$KEY&$CITY_PARAM&units=$UNITS&cnt=1")

if [ -n "$current" ] && [ -n "$forecast" ]; then
    current_temp=$(echo "$current" | jq ".main.temp" | cut -d "." -f 1)
    current_icon=$(echo "$current" | jq -r ".weather[0].icon")

    forecast_temp=$(echo "$forecast" | jq ".list[].main.temp" | cut -d "." -f 1)
    forecast_icon=$(echo "$forecast" | jq -r ".list[].weather[0].icon")

    if [ "$current_temp" -gt "$forecast_temp" ]; then
        trend=""  # Temperature dropping (Down arrow)
    elif [ "$forecast_temp" -gt "$current_temp" ]; then
        trend=""  # Temperature rising (Up arrow)
    else
        trend=""  # Steady (Equal sign)
    fi

    sun_rise=$(echo "$current" | jq ".sys.sunrise")
    sun_set=$(echo "$current" | jq ".sys.sunset")
    now=$(date +%s)

    if [ "$sun_rise" -gt "$now" ]; then
        daytime="  $(get_duration "$((sun_rise-now))")"
    elif [ "$sun_set" -gt "$now" ]; then
        daytime="  $(get_duration "$((sun_set-now))")"
    else
        daytime="  $(get_duration "$((sun_rise-now))")"
    fi

    echo "$(get_icon "$current_icon") $current_temp$SYMBOL $trend  $(get_icon "$forecast_icon") $forecast_temp$SYMBOL  $CITY"
else
    echo "Weather data unavailable"
fi

