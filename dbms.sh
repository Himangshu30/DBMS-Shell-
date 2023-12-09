#!/bin/bash
`mkdir -p databases`

select_from(){
	clear
	echo
	read -p "Enter table name to select from: " tblname
	if [[ -f databases/$connectedDB/$tblname ]]; then
		select choice in "select all" "select specific records"
		do
		case $REPLY in
			1)
			awk 'BEGIN{FS=","} {if(NR==5){for (i=1;i<=NF;i++) printf "%-5s",$i; print ""}}'  databases/$connectedDB/.$tblname"_metadata";
			awk 'BEGIN{FS=","}{for (i=1;i<=NF;i++) printf "%-5s",$i; print ""}'  databases/$connectedDB/$tblname
			echo
			echo
			table

			;;
				
			2)
			pk_name=`awk -F, '{if(NR==5){print$1}}' databases/$connectedDB/.$tblname"_metadata";`
			read -p "Enter $pk_name value: " val;
			awk 'BEGIN{FS=","} {if(NR==5){for (i=1;i<=NF;i++) printf "%-5s",$i; print ""}}'   databases/$connectedDB/.$tblname"_metadata";
			cat databases/$connectedDB/$tblname|grep ^$val>databases/$connectedDB/temp2
			awk 'BEGIN{FS=","}{for (i=1;i<=NF;i++) printf "%-5s",$i; print ""}' databases/$connectedDB/temp2
			rm databases/$connectedDB/temp2 2>/dev/null

			echo
			echo
			table
			;;
			*)echo wrong choice
			table
		esac
		done
		echo
	else
		echo
		echo There is no table with this name
		table
	fi

}

delete_from(){
	clear
	read -p "Enter table name to delete from: " tblname
	if [[ -f databases/$connectedDB/$tblname ]]; then
		select choice in "delete all records" "delete a specific record"
		do
		case $REPLY in
			1)
			> databases/$connectedDB/$tblname
			echo All records has been deleted
			echo
			table

			;;
				
			2)
			pk_name=`awk -F, '{if(NR==5){print$1}}' databases/$connectedDB/.$tblname"_metadata";`
			read -p "Enter $pk_name value: " val
			grep -v ^$val databases/$connectedDB/$tblname>databases/$connectedDB/temp.csv
			mv databases/$connectedDB/temp.csv databases/$connectedDB/$tblname
			rm databases/$connectedDB/temp.csv 2>/dev/null
			echo record with id : $val had been deleted
			echo
			table

			
		esac
		done
		echo
		echo -----------------
		table
	else
		echo There is no table with this name
		echo
		echo -----------------
		table
	fi
}

table(){
    echo
	echo _______________$connectedDB Database_______________
	echo
choice=read
select choice in "create table" "list tables" "drop table" "show meta data of a table" "insert to table" "select from table" "delete from table" "back to main menu" 
	do
	case $REPLY in
	1)
	clear
	read -p "Enter a name for the table: " tblname
	if [[ -f databases/$connectedDB/$tblname ]];then
		echo table already exists
		echo
		echo --------------------
		table
	else
		read -p "Enter number of columns :" cols;
		if [[ $cols -eq 0 ]];then
			echo Cannot create a table without columns
			table
		fi
		`touch databases/$connectedDB/$tblname`
		`touch databases/$connectedDB/.$tblname"_metadata"`
		`chmod -R 777 databases/$connectedDB/$tblname`
		echo "Table Name:"$tblname >> databases/$connectedDB/.$tblname"_metadata"
		echo "Number of columns:"$cols >> databases/$connectedDB/.$tblname"_metadata"
		

		for (( i = 1; i <= cols; i++ )); do
			if [[ i -eq 1 ]];then
				read -p "Enter column $i name as a primary key: " name;
				echo "The primary key for this table is: "$name >> databases/$connectedDB/.$tblname"_metadata";
				echo "Names of columns: " >> databases/$connectedDB/.$tblname"_metadata"
				echo -n $name"," >> databases/$connectedDB/.$tblname"_metadata";

			elif [[ i -eq cols ]];then
				read -p "Enter column $i name: " name;
				echo -n $name >> databases/$connectedDB/.$tblname"_metadata";
			else
				read -p "Enter column $i name: " name;
				echo -n $name"," >> databases/$connectedDB/.$tblname"_metadata";	
			fi 
		done 
		clear
		echo Table created sucsessfully
		table
	fi

	;;
	2)
	if [ -z "$(ls -A -- databases/$connectedDB)" ]; then
		clear
		echo
		echo This database is empty
		echo
		echo ----------------------
		table
	else
		clear
		echo
		echo The tables of this database are: 
			ls -1 databases/$connectedDB
		echo
		echo ----------------------
		table
	fi
		;;
	3)echo 
	clear
		read -p "Enter name of the table you want to drop:"
		if [[ -f databases/$connectedDB/$REPLY ]];then
			rm databases/$connectedDB/$REPLY
			rm databases/$connectedDB/.$REPLY"_metadata"
			echo table removed successfully
			echo
			echo -------------------------
			table
		else
			echo no table with this name
			echo
			echo --------------------------
			table
		fi
		;;
	4)
	clear
	echo
	read -p "Enter the table name: " tblname
	if [[ -f databases/$connectedDB/$tblname ]];then
			cat databases/$connectedDB/.$tblname"_metadata"
			echo
		else
			echo There is no table with this name
		fi
	echo ------------------
	table
	;;
	

	5)
	clear
	read -p "Enter the table name: " tblname
	if [[ -f databases/$connectedDB/$tblname ]]; then
	typeset -i cols=`awk -F, '{if(NR==5){print NF}}' databases/$connectedDB/.$tblname"_metadata";`
	
	for (( i = 1; i <= $cols; i++ )); do
	 	colname=`awk -F, -v"i=$i" '{if(NR==5){print $i}}' databases/$connectedDB/.$tblname"_metadata";`
		read -p "Enter $colname: " value;
		if [[ $colname -eq id ]];then
				pks=`sed -n '1,$'p databases/$connectedDB/$tblname| cut -f1 -d,`
				for j in $pks 
				do					
					if [[ $j -eq $value ]];then
					echo "cannot redundant primary key"
					table
					fi
				done
		fi 2>/dev/null
			if [[ $i != $cols ]]; then
				echo -n $value"," >> databases/$connectedDB/$tblname;
			else	
				echo $value >> databases/$connectedDB/$tblname;
			fi
	done 
	echo "Data has been sorted successfully"
	echo
	echo
	table
 	
	else
		echo "$tblname doesn't exist";
		echo
		table
	fi
	;;
	6)
	select_from
	;;
	7)
	delete_from
	;;
	8)
		#Back to main menu works fine on centos, but in some other linux distributions, this command exists from the file
		clear
		exec $0 
	;;
		
	*)
	clear
	echo "Wrong choice"
		break 2
	esac
done
}

echo
echo ----------------------------------------------------------
echo Hello, `whoami`!! Welcom to our database managment system
echo
echo Created by @Himangshu

	select choice in "create database" "List Databases" "Connect to databases " "Drop Database" "Exit from DBMS" 
	do
	case $REPLY in
	1)
	clear
	read -p "Enter a name for the database: "; 
	if [[ -d databases/$REPLY ]];then
	echo 'Database already exists'	
	else  
	`mkdir databases/${REPLY}`
		echo ${REPLY} database created succsessfully!!!
		fi
		break
	;;
	2)
	clear
	echo
	echo The available databases are:
	ls -1 databases
	echo
	echo ---------------------------
	break
	;;
 	3)
	clear
	read -p "Enter the name of the database you want to connect with: "
	connectedDB=$REPLY
	if [[ -d databases/$connectedDB ]];then
		clear
		echo You are now connected to $connectedDB database
		table
	else
		echo
		echo No database with name $connectedDB
		echo
		echo -----------------------------------
	fi 
	break
	;;
	4)
	clear
	read -p "Enter the name of the database you want to drop: "
	if [[ -d databases/$REPLY ]];then
		`rm -r databases/$REPLY`
		echo $REPLY dropped sucsessfully
	else
		echo their is no database with this name
	fi
	break
	;;
	5)
		exit
		;;
	*)echo $REPLY is  invalid choice
		break
 		;;
	esac
done
done


