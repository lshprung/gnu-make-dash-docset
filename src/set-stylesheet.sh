#!/usr/bin/sh

unset LOCAL_CSS_PATH
unset WEB_CSS_PATH
CSS="$1"
shift

get_css_path() {
	# Used to set WEB_CSS_PATH
	pup "link[rel=stylesheet] attr{href}" -f "$1"
}

stylesheet_replace() {
	# Replace each stylesheet href value with LOCAL_CSS_PATH
	while [ -n "$1" ]; do
		sed -i 's|'"$(pup link[rel=stylesheet] -f "$1")"'|<link rel="stylesheet" type="text/css" href="manual.css">|g' "$1"
		shift
	done
}

stylesheet_remove() {
	# Remove the stylesheet link
	while [ -n "$1" ]; do
		sed -i 's|'"$(pup link[rel=stylesheet] -f "$1")"'||g' "$1"
		shift
	done
}

if [ "$CSS" = "yes" ]; then
	WEB_CSS_PATH="$(get_css_path "$1")"
	if [ -n "$WEB_CSS_PATH" ]; then
		LOCAL_CSS_PATH="$(dirname "$1")"/manual.css
		curl -o "$LOCAL_CSS_PATH" "$WEB_CSS_PATH"
	fi
	if [ -r "$LOCAL_CSS_PATH" ]; then
		stylesheet_replace "$@"
	else
		CSS="no"
	fi
fi

if [ "$CSS" = "no" ]; then
	stylesheet_remove "$@"
fi
