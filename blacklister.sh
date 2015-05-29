#! /bin/sh
# 
# 2015, Imprev, Inc.
# 
# Helper script that pre-populates a list of servers to back up based on a
# provided list of servers to blacklist.  Will merge with current list, so
# you can still custom-specify servers.  Regex is allowed (uses egrep)
#

usage() {
	echo "Ex Crontab:"
	echo "    0 * * * * /usr/local/ghettoVCB/blacklister.sh /usr/local/ghettoVCB/black.list"
}

# $1 - File to use as blacklist
# $2 - Output file for ghettoVCB to use as server list
main() {
	# Need blacklist.  Should be a plain text file with each server/pattern, one on each line.
	[ "$#" -lt 1 ] && { echo "At least one arg needed."; usage; exit 1; }
	blacklist=$1
	black_list=`cat $blacklist`
	# Get other arguments
	white_list=${2:-"/usr/local/ghettoVCB/server.list"}
	vmfs=${3:-"/vmfs/volumes/datastore1"}
	
	# Get list of servers under $vmfs folder
	server_list=`ls -1 $vmfs`
	# Clear out servers in the $black_list
	for black in $black_list; do
		server_list=`echo $server_list|sed 's/\ /\n/g'|egrep -v "$black"`
	done
	# Merge this list with the current $white_list and uniquify
	server_list=$(echo "`echo $server_list` `cat server.list 2>/dev/null`"|sed 's/\ /\n/g'|sort -u)
	
	# Populate new $white_list
	> $white_list
	for server in $server_list; do
		echo $server >> $white_list
	done
}

main "$@"
