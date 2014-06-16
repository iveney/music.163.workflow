play_cmd='(function (){document.querySelector(".ply").click();})()'
prev_cmd='(function (){document.querySelector(".prv").click();})()'
next_cmd='(function (){document.querySelector(".nxt").click();})()'
get_title_cmd='(function (){return document.querySelector("a.fc1").text;})()'
get_artist_cmd='(function (){return document.querySelector("span.by").firstChild.title;})()'
open_fav_cmd='(function (){document.querySelector("a.icn-add").click();})()'
add_fav_cmd='(function (){document.querySelector("#g_iframe").contentDocument.querySelector(".zcnt .s-fc0").click();})()'

# $1: command $2: tab id
execute() {
	cmd=$1
	tab=$2
	if [[ -n "$tab" ]]; then
		chrome-cli execute "$cmd" -t "$tab"
		return 0
	fi
	return 1
}

get_tab() {
	echo `chrome-cli list links | grep music.163.com | awk -F'[:\\\[\\\] ]' '{print $3}'`
}

get_title_with_status() {
	tab=`get_tab`
	echo `chrome-cli info -t $tab | grep Title | cut -d ' ' -f 2-`
}

get_title() {
	title=`get_title_with_status`
	echo "${title#▶ }"
}

get_status() {
	title=`get_title_with_status`
	if [[ "$title[1,1]" == "▶" ]]; then
		echo "paused"
	else
		# empty string also falls here
		echo "playing"
	fi
}

get_song_info() {
	tab=`get_tab`
	title=`execute $get_title_cmd $tab`
	artist=`execute $get_artist_cmd $tab`
	if [[ -n "$title" ]]; then
		echo "$title - $artist"
	fi
}

add_fav() {
	tab=`get_tab`
	execute "$open_fav_cmd" "$tab"
	execute "$add_fav_cmd" "$tab"
	get_song_info
}

play() {
	tab=`get_tab`
	execute "$play_cmd" "$tab"
	cmd='(function (){return document.querySelector(".ply").classList.contains("js-pause");})()'
	stat=`execute $cmd $tab`
	if [[ $stat == "0" ]]; then
		get_song_info
	fi
}

prev() {
	tab=`get_tab`
	execute "$prev_cmd" "$tab"
	sleep 1
	get_song_info
}

next() {
	tab=`get_tab`
	execute "$next_cmd" "$tab"
	sleep 1
	get_song_info
}
