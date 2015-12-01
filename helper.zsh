export PATH=$PATH:/usr/local/bin

play_cmd='(function (){document.querySelector(".ply").click();})()'
prev_cmd='(function (){document.querySelector(".prv").click();})()'
next_cmd='(function (){document.querySelector(".nxt").click();})()'
get_title_cmd='(function (){return document.querySelector("a.fc1").text;})()'
get_artist_cmd='(function (){return document.querySelector("span.by").firstChild.title;})()'
open_fav_cmd='(function (){document.querySelector("a.icn-add").click();})()'
add_fav_cmd='(function (){document.querySelector("#g_iframe").contentDocument.querySelector(".zcnt .s-fc0").click();})()'
get_state_cmd='(function (){return document.readyState;})()'
tab=''

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

get_state() {
	state=`execute $get_state_cmd $tab`
        echo $state
}

set_tab() {
	tab=`chrome-cli list links | grep music.163.com | awk -F'[:\\\[\\\] ]' '{print $2}'`
}

wait_tab() {
        while [[ ! -n "$tab" ]] || [[ `get_state` != "complete" ]]; do
		set_tab
		if [[ ! -n "$tab" ]]; then
			>&2 echo 'tab not found, create new'
			chrome-cli open http://music.163.com/ > /dev/null
			sleep 1
		else
			>&2 echo 'wait for tab ready'
			sleep 1
		fi
	done
}

get_title_with_status() {
	wait_tab
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
	wait_tab
	title=`execute $get_title_cmd $tab`
	artist=`execute $get_artist_cmd $tab`
	if [[ -n "$title" ]]; then
		echo "$title - $artist"
	fi
}

add_fav() {
	wait_tab
	execute "$open_fav_cmd" "$tab"
	execute "$add_fav_cmd" "$tab"
	get_song_info
}

play() {
	wait_tab
	execute "$play_cmd" "$tab"
	cmd='(function (){return document.querySelector(".ply").classList.contains("js-pause");})()'
	stat=`execute $cmd $tab`
	if [[ $stat == "0" ]]; then
		get_song_info
	fi
}

prev() {
	wait_tab
	execute "$prev_cmd" "$tab"
	sleep 1
	get_song_info
}

next() {
	wait_tab
	execute "$next_cmd" "$tab"
	sleep 1
	get_song_info
}
