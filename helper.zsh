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
	if [[ $title[0,1] == "▶" ]]; then
		echo "paused"
	else
		echo "playing"
	fi
}

play_cmd='(function (){document.querySelector(".ply").click();})()'
prev_cmd='(function (){document.querySelector(".prv").click();})()'
next_cmd='(function (){document.querySelector(".nxt").click();})()'

play() {
	tab=`get_tab`
	if [[ -n "$tab" ]]; then
		chrome-cli execute "$play_cmd" -t $tab
		echo `get_title`
	fi
}

prev() {
	tab=`get_tab`
	if [[ -n "$tab" ]]; then
		chrome-cli execute "$prev_cmd" -t $tab
		sleep 1
		echo `get_title`
	fi
}

next() {
	tab=`get_tab`
	if [[ -n "$tab" ]]; then
		chrome-cli execute "$next_cmd" -t $tab
		sleep 1
		echo `get_title`
	fi
}
