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
	if [ -f ./nuclei_$1/.logs ];then
		a=""
		for i in $2 ;do
			if ! grep "$i" ./nuclei_$1/.logs &> /dev/null  ;then
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
        ls  ~/templates |xargs
    	}

function a(){
echo $1
echo $2
echo $3
}

function ncl(){
	mkdir -p  nuclei_$1 
	for i in $3 ;do 
		template="~/templates/$i"
		output="./nuclei_$1/$i.txt"
		if [ -f $template ];then
			echo  -ne "\e[33mtemplate :  $i"\\r
			nuclei -t  $template    -silent -l $1 -o $output  -c $2  -retries 2
			echo "$i		[$(date +%D__%X)]" >> ./nuclei_$1/.logs
		fi
	done
	echo "------------------------------------------------------------------------------------------------------------" >> ./nuclei_$1/.logs
	find ./$output -empty -delete
}


function update_tmp(){
#	original_location="~/nuclei-templates"
#	work_location="~/templates"

#update template from github 
        cd ~/nuclei-templates && git pull
        cd - &> /dev/null

#transfer tmp process

        for i in  cves security-misconfiguration files security-misconfiguration panels vulnerabilities tokens subdomain-takeover workflows ;do
                for j in $(ls ~/nuclei-templates/$i);do
                       if [  -f ~/templates/$j ];then
                           #echo "$work_location/$j"
			     a="$(cat   ~/templates/$j |wc -c )"
                             b="$(cat  ~/nuclei-templates/$i/$j|wc -c  )"
                                if [ $a -ne $b ];then
                                       echo "$j" >> update_tmp.txt
                                fi
                        fi

                done
	cp ~/nuclei-templates/$i/* ~/templates
        done

#custom templates
        for j in $(ls ~/ncl/costum_tmp);do
                        #old tmp
                        if [  -f ~/templates/$j ];then
                           #echo /$j"
                             a="$(cat   ~/templates/$j |wc -c )"
                             b="$(cat  ~/ncl/costum_tmp/$j |wc -c  )"
                                if [ $a -ne $b ];then
                                        echo "$j" >> update_tmp.txt
                                fi
                        fi

        done

        cp ~/ncl/costum_tmp  ~/templates

        for log in $(find $1 -iname "nuclei_*" -type f) ;do
                        cat $log |grep  -v -f update_tmp.txt |sort -o $log
        done

	rm  -rf update_tmp.txt &> /dev/null

        for i in  typescript  swagger-panel.yaml basic-cors-flash.yaml ;do
                rm ~/templates/$i &> /dev/null
        done
}

function list_tmp(){
	ls  ~/templates/ 

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

 
ncl  $url $occurence "$template"

