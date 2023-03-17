#!/usr/bin/env sh

create_table() {
	sqlite3 "$DB_PATH" "CREATE TABLE IF NOT EXISTS searchIndex(id INTEGER PRIMARY KEY, name TEXT, type TEXT, path TEXT);"
	sqlite3 "$DB_PATH" "CREATE UNIQUE INDEX IF NOT EXISTS anchor ON searchIndex (name, type, path);"
}

get_title() {
	FILE="$1"

	pup -p -f "$FILE" 'title text{}' | \
		tr -d \\n | \
		sed 's/(GNU make)//g' | \
		sed 's/\"/\"\"/g'
}

get_type() {
	LINK="$(echo "$1" | sed 's/#[^#]*$//')"
	LINK_TITLE="$(get_title "$2/$LINK")"

	set -- $POSSIBLE_TYPES

	while [ -n "$1" ]; do
		if echo "$LINK_TITLE" | grep -iq "$1"; then
			echo "$1"
			return
		fi
		shift
	done

	echo "Entry"
}

insert() {
	NAME="$1"
	TYPE="$2"
	PAGE_PATH="$3"

	sqlite3 "$DB_PATH" "INSERT INTO searchIndex(name, type, path) VALUES (\"$NAME\",\"$TYPE\",\"$PAGE_PATH\");"
}

insert_index_terms() {
	# Get each term from an index page and insert
	while [ -n "$1" ]; do
		grep -Eo "<a href.*></a>:" "$1" | while read -r line; do
			insert_term "$line" "$(dirname "$1")"
		done

		shift
	done
}


insert_pages() {
	# Get title and insert into table for each html file
	while [ -n "$1" ]; do
		unset PAGE_NAME
		unset PAGE_TYPE
		PAGE_NAME="$(get_title "$1")"
		if [ -n "$PAGE_NAME" ]; then
			PAGE_TYPE="Guide"
			insert "$PAGE_NAME" "$PAGE_TYPE" "$(basename "$1")"
		fi
		shift
	done
}

insert_term() {
	LINK="$1"
	PAGE_DIR="$2"

	NAME="$(echo "$LINK" | pup -p 'a text{}' | tr -d \\n | sed 's/"/\"\"/g')"
	TYPE="$INDEX_TYPE"
	PAGE_PATH="$(echo "$LINK" | pup -p 'a attr{href}')"
	if [ -n "$POSSIBLE_TYPES" ]; then
		TYPE="$(get_type "$PAGE_PATH" "$PAGE_DIR")"
	elif [ -z "$TYPE" ]; then
		TYPE="Entry"
	fi

	insert "$NAME" "$TYPE" "$PAGE_PATH"
}

TYPE="PAGES"

# Check flags
while true; do
	case "$1" in
		-c|--check)
			# List of space-separated possible index entry types (overwrites -t)
			shift
			POSSIBLE_TYPES="$1"
			shift
			;;
		-i|--index)
			# Set the script to handle index pages
			TYPE="INDEX"
			shift
			;;
		-t|--type)
			# Set a type for index entries
			shift
			INDEX_TYPE="$1"
			shift
			;;
		*)
			break
	esac
done

DB_PATH="$1"
shift

create_table
case "$TYPE" in
	PAGES)
		insert_pages "$@"
		;;
	INDEX)
		insert_index_terms "$@"
		;;
esac
