#!/bin/bash
 
function help(){
echo "usage:"
echo "this script take list of template and test it on list of url  "
echo -e "\t u \t update  templates"
echo -e "\t s \t show templates "
echo -e "\t l \t provide list of url (require) "
echo -e "\t t \t use specific template tmp1,tmp2,tmp3,..."
echo -e "\t g \t ignore previous test"
echo -e "\t c \t occurance number (10 default)"
}

function template_base_logs(){
	if [ -f ./jls_$1/.logs ];then
		a=""
		for i in $2 ;do
			if ! grep "$i" ./jls_$1/.logs &> /dev/null  ;then
				a="$a $i"
				
			fi
		done
	else
		a="$2"
	fi
	echo "$a"
}

function template_specific(){
	echo $(echo $1 |sed 's/,/ /g')
        }

function template_all(){
        ls  ~/jls_templates |xargs
    	}

function a(){
echo $1
echo $2
echo $3
}

function jls(){
	mkdir -p jls_$1 
#	echo "$3"
	for i in $3 ;do 
		template="/home/medbsq/jls_templates/$i"
		output="./jls_$1/$i.txt"
		#echo "$template"
		if [ -f $template ];then
			echo  -ne "\e[33mtemplate :  $i"\\r
#			jaeles scan -s   $template    -U $1 -o $output  -c $2 
		        jaeles scan -c $2 -s $template -v -U $1 -o $output
#		-c 100 -s   jls_templates/aircontrol-rce.yaml -o p
#			echo "$i		[$(date +%D__%X)]" >> ./jls_$1/.logs
		fi
	done
	echo "------------------------------------------------------------------------------------------------------------" >> ./jls_$1/.logs
	find ./$output -empty -delete &> /dev/null
}


function update_tmp(){
#	original_location="~/nuclei-templates"
#	work_location="~/templates"

#update template from github 
        cd ~/jaeles-signatures && git pull
        cd - &> /dev/null

#transfer tmp process

        for i in   common  cves  fuzz  mics  passives  probe   sensitive;do
	cp $(find ~/jaeles-signatures/$i  -iname "*.yaml" )   ~/jls_templates &> /dev/null
        done

#custom templates

        cp ~/jls/costum_tmp  ~/jls_templates &>/dev/null

	cd ~/jls-sig/Mysignature && git pull
        cd - &> /dev/null
	cp ~/jls-sig/Mysignature  ~/jls_templates &>/dev/null


	cd ~/jls-sig/ghsec-jaeles-signatures && git pull
        cd - &> /dev/null
        cp ~/jls-sig/ghsec-jaeles-signatures  ~/jls_templates &>/dev/null
}

function list_tmp(){
	ls  ~/jls_templates/ 

}


#variables
template=""
url=""
occurence=10
ignore=0


#option handler
while getopts ":l:t:c:gsu" OPTION
do
        case $OPTION in
                s)
			list_tmp
			exit
                        ;;
                t)
                        template="$OPTARG"
                        ;;
		c)
                        occurence="$OPTARG"
                        ;;
		g)
                        ignore=1
                        ;;

                l)
                        url="$OPTARG"
                        ;;
		u)
                        #update_tmp
			update_tmp
			exit
                        ;;
                :)
                        help
                        exit 1
                        ;;
                \?)
                        help
                        exit 1
                        ;;

        esac
done


#get template
if [[ $template == "" ]] && [[ $url == "" ]];then
	help
	exit
elif [[ $template == "" ]] && [[ $url != "" ]];then
	template="$(template_all)"
elif [[ $template != "" ]] && [[ $url == "" ]];then
	help
        exit
else
	template="$(template_specific $template)"
		
fi

#logs filtration
if [ $ignore -eq 0 ];then
	template=$(template_base_logs $url "$template")
#template_base_logs $url "$template"
fi

 
jls  $url $occurence "$template"

