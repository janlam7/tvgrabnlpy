#!/bin/bash

# Can be slow (the default) or fast
declare Speed=${1:-"slow"}

# Can be full (the default) or a number
# if Speed is slow, full = 14
# if Speed is fast, full = 4
declare Days=${2:-"full"}

# Can be default, all or selected
# if Speed is slow, default = all
# if Speed is fast, default = selected
declare Group=${3:-"default"}

# Optional offset defaults to 0
declare Offset=${4:-"0"}

# The MythTV sourceID's to fill. 
# If you have only 1 source, set SourceID2=""
declare SourceID1=1
declare SourceID2=8

# The location for the output, config and log files
declare xml_path="/tmp/"
declare Conf_path="${HOME}/.xmltv/"
# Delete the output end config after use. Set to 0 to keep them
declare -i clean_xml=1
declare -i clean_Conf=1

declare Conf_file
declare xml_file
declare -i Chan_Cnt

# The actual grab and mythfilldatabase command
# If the selection contains no channels ($Chan_Cnt -eq 0) it does nothing
# Therefor you set the value to add in every add section below to 1 or 0 e.g.:
#	Chan_Cnt=$Chan_Cnt+1
#	Chan_Cnt=$Chan_Cnt+0
# It keeps running mythfilldatabase until it runs out of parameters
function Grab_And_Fill {
	[ $Chan_Cnt -eq 0 ] && return
	
	if [ "$1" != "" ]; then
		/usr/bin/tv_grab_nl.py --config-file ${Conf_file} --output ${xml_file}
	fi
	
	if [ $? == 0 ]; then
		while [ "$1" != "" ]; do
			/usr/bin/mythfilldatabase --syslog local5 --file --xmlfile ${xml_file} --sourceid $1
			shift
		done
	fi
}

# This contains the Configuration Settings
function Add_Header {
	echo "# encoding: utf-8" > $Conf_file
	echo "# configversion: 2.1" >> $Conf_file
	echo "" >> $Conf_file
	echo "[Configuration]" >> $Conf_file
	echo "write_info_files = True" >> $Conf_file
	echo "log_level = 7" >> $Conf_file
	echo "quiet = False" >> $Conf_file
	echo "cache_save_interval = 1000" >> $Conf_file
	echo "desc_length = 1000" >> $Conf_file

	if [ "$Speed" == "slow" ]; then
		echo "fast = False" >> $Conf_file
		echo "offset = $Offset" >> $Conf_file
		echo "days = $Days" >> $Conf_file
		echo "rtldays = $Days" >> $Conf_file
		echo "tevedays = 8" >> $Conf_file
	elif [ "$Speed" == "fast" ]; then
		echo "fast = True" >> $Conf_file
		echo "offset = $Offset" >> $Conf_file
		echo "days = $Days" >> $Conf_file
		echo "rtldays = $Days" >> $Conf_file
		echo "tevedays = $Days" >> $Conf_file
	elif [ "$Speed" == "alt" ]; then
		echo "fast = False" >> $Conf_file
		echo "offset = 0" >> $Conf_file
		echo "days = 1" >> $Conf_file
		echo "rtldays = 1" >> $Conf_file
		echo "tevedays = 1" >> $Conf_file
	fi
	
	echo "" >> $Conf_file
	echo "[Channels]" >> $Conf_file
}

# These are the common Channels you want to grab always
function Add_Base_Channels {
	Chan_Cnt=$Chan_Cnt+1
	echo "Nederland 1;1;1;nederland-1;;npo-1;4;npo1.png" >> $Conf_file
	echo "Nederland 2;1;2;nederland-2;;npo-2;4;npo2.png" >> $Conf_file
	echo "Nederland 3;1;3;nederland-3;;npo-3;4;npo3.png" >> $Conf_file
	echo "RTL 4;1;4;rtl-4;RTL4;;4;rtl4_1.png" >> $Conf_file
	echo "RTL 5;1;31;rtl-5;RTL5;;4;rtl_5_1.png" >> $Conf_file
	echo "RTL 7;1;46;rtl-7;RTL7;;4;rtl7.png" >> $Conf_file
	echo "RTL 8;1;92;rtl-8;RTL8;;4;rtl_8_1.png" >> $Conf_file
	echo "SBS 6;1;36;sbs-6;;;4;sbs6_1.png" >> $Conf_file
	echo "NET 5;1;37;net-5;;;4;net5.png" >> $Conf_file
	echo "Veronica;1;34;veronica;;;4;veronica_disney_xd.png" >> $Conf_file
	echo "Eén;2;5;een;;een;2;39043/een-nl.jpg" >> $Conf_file
	echo "Canvas;2;6;ketnet-canvas;;canvas;4;canvas.png" >> $Conf_file
	echo "BBC 1;3;7;bbc-1;;bbc1-nl;2;18285/bbc-1-nl.jpg" >> $Conf_file
	echo "BBC 2;3;8;bbc-2;;bbc2-nl;2;18287/bbc-2-nl.jpg" >> $Conf_file
}

# These are the Source1  Channels you want to grab always
function Add_BaseSource1_Channels {
	Chan_Cnt=$Chan_Cnt+0
	echo "" >> $Conf_file
}

# These are the Source2  Channels you want to grab always
function Add_BaseSource2_Channels {
	Chan_Cnt=$Chan_Cnt+0
	echo "" >> $Conf_file
}

# These are the rest of the common Channels
function Add_Common_Channels {
	Chan_Cnt=$Chan_Cnt+1
	echo "CNN;3;26;cnn;;;4;cnn.png" >> $Conf_file
	#~ echo "ARD;4;9;ard;;ard;2;39131/ard-nl.jpg" >> $Conf_file
	echo "ARD;4;9;ard;;ard;4;ard.png" >> $Conf_file
	echo "RTV Utrecht;6;100;rtv-utrecht;;;4;rtvutrecht.png" >> $Conf_file
	echo "Comedy Central;7;91;comedy-central;;;0;comedy_central.gif" >> $Conf_file
	#~ echo "Discovery Channel;7;29;discovery-channel;;;0;discover-spacey.gif" >> $Conf_file
	echo "Discovery Channel;7;29;discovery-channel;;;4;discovery_channel.png" >> $Conf_file
	#~ echo "Eurosport;7;19;eurosport;;eurosport;2;39217/eurosport-nl.jpg" >> $Conf_file
	echo "Eurosport;7;19;eurosport;;eurosport;4;eurosport.png" >> $Conf_file
	#~ echo "National Geographic;7;18;national-geographic;;national-geographic;2;39067/national-geographic-nl.jpg" >> $Conf_file
	echo "National Geographic;7;18;national-geographic;;national-geographic;4;national_geographic_sd.png" >> $Conf_file
	echo "Nickelodeon;7;89;nickelodeon;;;4;nickelodeon.png" >> $Conf_file
	#~ echo "MTV;7;25;mtv;;;2;39133/mtv-black-nl.jpg" >> $Conf_file
	echo "MTV;7;25;mtv;;;4;mtv_1.png" >> $Conf_file
	echo "TLC;7;438;tlc;;tlc;4;/tlc_logo.png" >> $Conf_file
}

# These are the rest of the Source1 Channels
function Add_Source1_Channels {
	Chan_Cnt=$Chan_Cnt+0
	echo "" >> $Conf_file
}

# These are the rest of the Source2 Channels
function Add_Source2_Channels {
	Chan_Cnt=$Chan_Cnt+1
	echo "BBC World;3;86;bbc-world;;;4;bbc_world_news.png" >> $Conf_file
	echo "ZDF;4;10;zdf;;zdf;4;zdf.png" >> $Conf_file
	echo "Brava NL;7;428;bravatv;;;4;bravanl.png" >> $Conf_file
	echo "Comedy Family;7;317;comedy-family;;;4;comedy_central_family1.png" >> $Conf_file
	echo "Disney Channel;7;424;disney-channel;;disneychannel;4;disney_channel_2.png" >> $Conf_file
	echo "Ketnet;8;;;;ketnet;2;39223/ketnet-nl.jpg" >> $Conf_file
	echo "AT 5;6;40;at-5;;;4;at5.png" >> $Conf_file
	echo "L1 TV;6;115;l1-tv;;;4;omroep_limburg.png" >> $Conf_file
	echo "Omroep Brabant;6;114;omroep-brabant;;;4;omroep_brabant.png" >> $Conf_file
	echo "Omroep Flevoland;6;113;omroep-flevoland;;;4;omroep_flevoland.png" >> $Conf_file
	echo "Omroep Gelderland;6;112;omroep-gelderland;;;4;omroep_gelderland.png" >> $Conf_file
	echo "Omroep Zeeland;6;116;omroep-zeeland;;;4;omroep_zeeland.png" >> $Conf_file
	echo "Omrop Fryslân;6;109;omrop-fryslan;;;4;omroep_friesland.png" >> $Conf_file
	echo "RTV Drenthe;6;110;rtv-drenthe;;;4;rtv_drenthe.png" >> $Conf_file
	echo "RTV Noord-Holland;6;103;rtv-noord-holland;;;4;rtv_nh.png" >> $Conf_file
	echo "RTV Noord;6;108;rtv-noord;;;4;rtv_noord.png" >> $Conf_file
	echo "RTV Oost;6;111;rtv-oost;;;4;rtv_oost.png" >> $Conf_file
	echo "RTV Rijnmond;6;102;rtv-rijnmond;;;4;tv_rijnmond.png" >> $Conf_file
	echo "RTV West;6;101;rtv-west;;;4;tv_west.png" >> $Conf_file
}

# Here add all channel specific settings for all channels
function Add_Channel_Config {
	echo "" >> $Conf_file
	# Nederland 1
	echo "[Channel 1]" >> $Conf_file
	echo "append_tvgidstv = False" >> $Conf_file
	echo "prefered_description = 1" >> $Conf_file
	echo "" >> $Conf_file
	# Nederland 2
	echo "[Channel 2]" >> $Conf_file
	echo "append_tvgidstv = False" >> $Conf_file
	echo "prefered_description = 1" >> $Conf_file
	echo "" >> $Conf_file
	# Nederland 3
	echo "[Channel 3]" >> $Conf_file
	echo "append_tvgidstv = False" >> $Conf_file
	echo "prefered_description = 1" >> $Conf_file
	echo "" >> $Conf_file
	# Eén
	echo "[Channel 5]" >> $Conf_file
	echo "prime_source = 3" >> $Conf_file
	echo "prefered_description = 3" >> $Conf_file
	echo "" >> $Conf_file
	# Canvas
	echo "[Channel 6]" >> $Conf_file
	echo "prime_source = 3" >> $Conf_file
	echo "prefered_description = 3" >> $Conf_file
	echo "" >> $Conf_file
	# BBC 1
	echo "[Channel 7]" >> $Conf_file
	echo "" >> $Conf_file
	#BBC 2
	echo "[Channel 8]" >> $Conf_file
	echo "" >> $Conf_file
	# RTL 4
	echo "[Channel 4]" >> $Conf_file
	echo "prime_source = 2" >> $Conf_file
	echo "prefered_description = 2" >> $Conf_file
	echo "" >> $Conf_file
	# RTL 5
	echo "[Channel 31]" >> $Conf_file
	echo "prime_source = 2" >> $Conf_file
	echo "prefered_description = 2" >> $Conf_file
	echo "" >> $Conf_file
	# RTL 7
	echo "[Channel 46]" >> $Conf_file
	echo "prime_source = 2" >> $Conf_file
	echo "prefered_description = 2" >> $Conf_file
	echo "" >> $Conf_file
	# RTL 8
	echo "[Channel 92]" >> $Conf_file
	echo "prime_source = 2" >> $Conf_file
	echo "prefered_description = 2" >> $Conf_file
	echo "" >> $Conf_file
	# SBS 6
	echo "[Channel 36]" >> $Conf_file
	echo "append_tvgidstv = False" >> $Conf_file
	echo "prefered_description = 1" >> $Conf_file
	echo "" >> $Conf_file
	# NET 5
	echo "[Channel 37]" >> $Conf_file
	echo "append_tvgidstv = False" >> $Conf_file
	echo "prefered_description = 1" >> $Conf_file
	echo "" >> $Conf_file
	# Veronica
	echo "[Channel 34]" >> $Conf_file
	echo "append_tvgidstv = False" >> $Conf_file
	echo "prefered_description = 1" >> $Conf_file
	echo "" >> $Conf_file
}

# Set defaults depending on slow or fast mode
if [ "$Speed" == "slow" ]; then
	if [ "$Days" == "full" ]; then
		Days=14
	fi
	
	if [ "$Group" == "default" ]; then
		Group="all"
	fi
	
elif [ "$Speed" == "fast" ]; then
	if [ "$Days" == "full" ]; then
		Days=4
	fi
	
	if [ "$Group" == "default" ]; then
		Group="selected"
	fi
	
else
	exit
fi

# The actual commands
if [ "$Group" == "all" ]; then
	Conf_file="${Conf_path}all_s2_${Speed}.conf"
	xml_file="${xml_path}all_s2_output.xml"
	Chan_Cnt=0
	Add_Header
	Add_BaseSource2_Channels
	Add_Source2_Channels
	Add_Channel_Config
	Grab_And_Fill $SourceID2
	[ $clean_Conf -gt 0 ] && rm -f ${Conf_file}
	[ $clean_xml -gt 0 ] && rm -f ${xml_file}

	Conf_file="${Conf_path}all_s1_${Speed}.conf"
	xml_file="${xml_path}all_s1_output.xml"
	Chan_Cnt=0
	Add_Header
	Add_BaseSource1_Channels
	Add_Source1_Channels
	Add_Channel_Config
	Grab_And_Fill $SourceID1
	[ $clean_Conf -gt 0 ] && rm -f ${Conf_file}
	[ $clean_xml -gt 0 ] && rm -f ${xml_file}

	Conf_file="${Conf_path}all_${Speed}.conf"
	xml_file="${xml_path}all_output.xml"
	Chan_Cnt=0
	Add_Header
	Add_Base_Channels
	Add_Common_Channels
	Add_Channel_Config
	Grab_And_Fill $SourceID1 $SourceID2
	[ $clean_Conf -gt 0 ] && rm -f ${Conf_file}
	[ $clean_xml -gt 0 ] && rm -f ${xml_file}
	
	# An extra add hoc fill only for one day for the monthly changing "Zender van de Maand"
	# Set Chan_Cnt to 1 to enable it. There is an extra header in "Add_Header" for this one.
	Speed="alt"
	Conf_file="${Conf_path}extra_s2_${Speed}.conf"
	xml_file="${xml_path}extra_s2_output.xml"
	Chan_Cnt=0
	Add_Header
	echo "NPO Best;7;316;best-24;;;4;npo_best" >> $Conf_file
	Add_Channel_Config
	Grab_And_Fill $SourceID2
	[ $clean_Conf -gt 0 ] && rm -f ${Conf_file}
	[ $clean_xml -gt 0 ] && rm -f ${xml_file}

elif [ "$Group" == "selected" ]; then
	Conf_file="${Conf_path}sel_s2_${Speed}.conf"
	xml_file="${xml_path}sel_s2_output.xml"
	Chan_Cnt=0
	Add_Header
	Add_BaseSource2_Channels
	Add_Channel_Config
	Grab_And_Fill $SourceID2
	[ $clean_Conf -gt 0 ] && rm -f ${Conf_file}
	[ $clean_xml -gt 0 ] && rm -f ${xml_file}

	Conf_file="${Conf_path}sel_s1_${Speed}.conf"
	xml_file="${xml_path}sel_s1_output.xml"
	Chan_Cnt=0
	Add_Header
	Add_BaseSource1_Channels
	Add_Channel_Config
	Grab_And_Fill $SourceID1
	[ $clean_Conf -gt 0 ] && rm -f ${Conf_file}
	[ $clean_xml -gt 0 ] && rm -f ${xml_file}

	Conf_file="${Conf_path}sel_${Speed}.conf"
	xml_file="${xml_path}sel_output.xml"
	Chan_Cnt=0
	Add_Header
	Add_Base_Channels
	Add_Channel_Config
	Grab_And_Fill $SourceID1 $SourceID2
	[ $clean_Conf -gt 0 ] && rm -f ${Conf_file}
	[ $clean_xml -gt 0 ] && rm -f ${xml_file}

fi

