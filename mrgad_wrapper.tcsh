#! /bin/tcsh -f

#===============================================================================================================================================================

set wrapperDir = $PWD
set startTime = `date +"%Y%m%d%H%M%S"`
echo
echo Wrapper Started at:
echo $startTime
echo 
echo Version 1.0
echo
echo This Wrapper will wrap around and run MRGAD


#check hyphenated argument
@ i = 0
set rsyncSet = "false"
while ($i < $# + 1)
      if("$argv[$i]" == "-rsync") then 
        echo Argument "-rsync" detected. Will rsync Tyto, Otus, and Athene.
        set rsyncSet = "true"
      else if("$argv[$i]" == "-startTime") then 
	 echo Argument "-startTime" detected.
     	@ temp = $i + 1
     	if($temp < $# + 1) then
		if("$argv[$temp]" != "") then
			set startTime = $argv[$temp]
			echo Outer Wrapper startTime == $startTime 
     		else
			echo please enter startTime after '-startTime'
		endif
	else
                echo please enter startTime after '-startTime'
     	endif
	@ i += 1  # skip next i since next argument was already read above 
      endif
      @ i +=  1
end

if ($# < 2) then #($# != 2 && $# != 3) then
        #Error handling
        #Too many or too little arguments       
        echo ""
	echo "ERROR: not enough arguments:"
	echo Mode 1 call:
	echo ./mrgad_wrapper.tcsh 1 ParentDir/
	echo Mode 2 call:
	echo ./mrgad_wrapper.tcsh 2 inputList.txt ParentDir/
	echo Mode 3 call:
        echo ./mrgad_wrapper.tcsh 3 ParentDir/ TileName
        echo
        echo Exiting...
        exit
#Mode1
else if ($1 == 1) then #($# == 2 && $1 == 1) then
        set ParentDir = $2
        echo Parent directory ==  $ParentDir
        echo "Is this the correct Parent directory? (y/n)"
        set userInput = $<

        #Error handling
        #if user input dir wrong
        if($userInput != "Y" && $userInput != "y") then
                echo Please execute program again with full Input Directory path as the 2nd parameter and the Ouput Directory path as your 3rd parameter
                #TODO actually throw an error instead of just outputing to stdout... output to stderr
                echo
                echo Exiting...
                exit
        endif
        #if directories dont exist, throw error
        if(! -d $ParentDir) then
                echo ERROR: Input Directory $ParentDir doest not exist.
                echo
                echo Exiting...
                exit
        endif

	goto Mode1
#Mode2
else if ($1 == 2) then
	set InputsList = $3
        set ParentDir = $2
	echo
        echo Inputs list ==  $InputsList
        echo Parent directory == $ParentDir
        echo "Is this the correct input list and Parent directory? (y/n)"
        set userInput = $<
    
    #Error handling
        #if user input dir wrong
        if($userInput != "Y" && $userInput != "y") then
                echo Please execute program again with full Input List file as the 2nd parameter and the Parent Directory path as your 3rd parameter
                #TODO actually throw an error instead of just outputing to stdout... output to stderr
                echo
                echo Exiting...
                exit
        endif
        #if directories dont exist, throw error
        if(! -f $InputsList) then
                echo ERROR: Input List file $InputsList doest not exist.
                echo
                echo Exiting...
                exit
        endif
        if (! -d $ParentDir) then
                echo ERROR: Parent Directory $ParentDir does not exist.
                echo
                echo Exiting...
                exit
        endif
        goto Mode2
#Mode3 Single Tile Mode
else if ($1 == 3) then
	set ParentDir = $2
	set RadecID = $3
 	echo Parent Dir ==  $ParentDir
        echo Tile Name == $RadecID
        echo
        echo "Is this the correct Parent Directory and Tile Name? (y/n)"
        set userInput = $<
 	#Error handling
        #if user input dir wrong
        if($userInput != "Y" && $userInput != "y") then
                echo Please execute program again with Parent Directory as the 2nd parameter and the Tile Name as your 3rd parameter
                #TODO actually throw an error instead of just outputing to stdout... output to stderr
                echo
                echo Exiting...
                exit
        endif
        #if directories dont exist, throw error
        if(! -d $ParentDir) then
                echo ERROR: $ParentDir doest not exist.
                echo
                echo Exiting...
                exit
        endif
	goto Mode3
else
        #Error handling
        #option 1/2/3 not second parameter. program exits.
        echo
	echo ERROR mode 1, 2, or 3 not selected
	echo Mode 1 call:
        echo ./mrgad_wrapper.tcsh 1 ParentDir/
        echo Mode 2 call:
        echo ./mrgad_wrapper.tcsh 2 inputList.txt ParentDir/
        echo Mode 3 call:
        echo ./mrgad_wrapper.tcsh 3 ParentDir/ TileName
        echo
        echo Exiting...
	exit
endif


Mode1:
#===============================================================================================================================================================        
# loops through all of the tiles and executes mrgad
set InputDir = $ParentDir/CatWISE/

echo Wrapper now starting...
echo
echo
echo 1\) mrgad wrapper programs now starting...

foreach RaRaRaDir ($InputDir*/) #for each directory in InputDir, get each RadecIDdir, run wrapper on RadecID tile

        foreach RadecIDDir ($RaRaRaDir*/)

                echo =============================== starting mrgad wrapper loop iteration =================================
	#Stops calling programs if number of scripts running is greater than number of threads on CPU
               
		set tempSize = `echo $RadecIDDir  | awk '{print length($0)}'`
        	@ tempIndex = ($tempSize - 8)
        	set RadecID = `echo $RadecIDDir | awk -v startIndex=$tempIndex '{print substr($0,startIndex,8)}'`
		set RaRaRa = `echo $RadecID | awk '{print substr($0,0,3)}'`
		set CatWISEDir = $ParentDir/CatWISE/$RaRaRa/$RadecID/Full/ 
		set TileDir = $ParentDir/CatWISE/$RaRaRa/$RadecID/
		set AsceDir = $ParentDir/CatWISE/$RaRaRa/$RadecID/Full/Asce/ 
		set DescDir = $ParentDir/CatWISE/$RaRaRa/$RadecID/Full/Desc/ 

		
		#Error Checking
		if(! -d $CatWISEDir) then
	                echo ERROR: $CatWISEDir does not exist.
	                echo
	                echo Exiting...
	                exit
	        endif 

	#mrgad mode 3 call
	set date_t = `date +"%Y%m%d_%H%M%S"`
	mkdir -p ${CatWISEDir}/ProgramTerminalOutput/
        if($rsyncSet == "true") then
		((echo y | source mrgad_wrapper.tcsh 3 $ParentDir $RadecID -rsync -startTime $startTime) |& tee -a ${CatWISEDir}/ProgramTerminalOutput/mrgadwrapperlog_${RadecID}_${date_t}.txt) & 
	else
		((echo y | source mrgad_wrapper.tcsh 3 $ParentDir $RadecID -startTime $startTime) |& tee -a ${CatWISEDir}/ProgramTerminalOutput/mrgadwrapperlog_${RadecID}_${date_t}.txt) & 
	endif

		if(`ps -ef | grep mrgad_wrapper | wc -l` > 14) then
			echo ${RadecID} More than 12 mrgad_wrapper processes, waiting...
			while(`ps -ef | grep mrgad_wrapper | wc -l` > 14)
				sleep 1
                        	#echo IM WATING
                        	#do nothing
        		end
			echo ${RadecID} Done waiting!
		endif	

        echo mrgad for ${RadecID} done!


        echo ================================ ending mrgad wrapper loop iteration =================================
        end
end

#===============================================================================================================================================================

#wait for background processes to finish
wait
echo mrgad wrapper finished!
echo
goto Done

Mode2:
	
    foreach line (`cat $InputsList`)    
        echo ===================================== start mrgad wrapper loop iteration ======================================
     
        set RadecID = `echo $line`
        set RaRaRa = `echo $RadecID | awk '{print substr($0,0,3)}'`


	set CatWISEDir = $ParentDir/CatWISE/$RaRaRa/$RadecID/Full/ 
	set TileDir = $ParentDir/CatWISE/$RaRaRa/$RadecID/
	set AsceDir = $ParentDir/CatWISE/$RaRaRa/$RadecID/Full/Asce/ 
	set DescDir = $ParentDir/CatWISE/$RaRaRa/$RadecID/Full/Desc/ 

	
	#Error Checking
	if(! -d $CatWISEDir) then
	        echo ERROR: $CatWISEDir does not exist.
	        echo
	        echo Exiting...
	        exit
	endif 
 
	#call mrgad wrapper
	set date_t = `date +"%Y%m%d_%H%M%S"`        
	echo "mkdir -p ${CatWISEDir}/ProgramTerminalOutput/"
	mkdir -p ${CatWISEDir}/ProgramTerminalOutput/
        if($rsyncSet == "true") then
		((echo y | source mrgad_wrapper.tcsh 3 $ParentDir $RadecID -rsync -startTime $startTime) |& tee -a ${CatWISEDir}/ProgramTerminalOutput/mrgadwrapperlog_${RadecID}_${date_t}.txt) & 
	else
		(echo y | ./mrgad_wrapper.tcsh 3 $ParentDir $RadecID -startTime $startTime |& tee -a ${CatWISEDir}/ProgramTerminalOutput/mrgadwrapperlog_${RadecID}_${date_t}.txt) &  
	endif
	#TODO have a set status here that catches errors? if 3 works, then 2 should work recursively using 3. However, we need to catch these errors
	
	if(`ps -ef | grep mrgad_wrapper | wc -l` > 14) then
		echo ${RadecID} More than 12 mrgad_wrapper processes, waiting...
		while(`ps -ef | grep mrgad_wrapper | wc -l` > 14)
			sleep 1
                	#echo IM WATING
                	#do nothing
        	end
		echo ${RadecID} Done waiting!
	endif	
	
        echo mrgad for ${RadecID} done!
		
	end

    #===============================================================================================================================================================

    #wait for background processes to finish
    wait
    echo mrgad wrapper finished!
    echo
    goto Done

Mode3:
	set RaRaRa = `echo $RadecID | awk '{print substr($0,0,3)}'`
	set CatWISEDir = $ParentDir/CatWISE/$RaRaRa/$RadecID/Full/ 
	set TileDir = $ParentDir/CatWISE/$RaRaRa/$RadecID/
	set AsceDir = $ParentDir/CatWISE/$RaRaRa/$RadecID/Full/Asce/ 
	set DescDir = $ParentDir/CatWISE/$RaRaRa/$RadecID/Full/Desc/ 
        echo "    RaRaRa == "$RaRaRa
        echo "    RadecID == "$RadecID
	echo "    Creating temp dir for $RadecID"
	mkdir -p ${CatWISEDir}/ProgramTerminalOutput/DELETEME
	echo "DONE CREATING DELETEME/"

	#Error Checking
	if(! -d $CatWISEDir) then
                echo ERROR: $CatWISEDir does not exist.
                echo
                echo Exiting...
                exit
        endif 
	
        ###GenWFL Makes frames list for Asce and Desc	
	echo
	echo START GENWFL
	/Users/CatWISE/genwfl -t $TileDir -oa ${AsceDir}/frames_list_Asce.tbl -od ${DescDir}frames_list_Desc.tbl -ox ${CatWISEDir}/epochs.tbl -td ${CatWISEDir}/ProgramTerminalOutput/DELETEME 
 	set saved_status = $? 
	#check exit status
	echo genwfl saved_status == $saved_status 
	if($saved_status != 0) then #if program failed, status != 0
		echo Failure detected on tile $RadecID
		set failedProgram = "genwfl"
		goto Failed
	endif
	echo END GENWFL	

	
	echo "gzip -f ${CatWISEDir}/stf-mrg13_asce.Opt-1a-rf1.tbl"
	echo "gzip -f ${CatWISEDir}/stf-mrg13_desc.Opt-1a-rf2.tbl"
	echo "gunzip -f ${AsceDir}/stf-mdex_asce.Opt-1a.tbl"
        echo "gunzip -f ${DescDir}/stf-mdex_desc.Opt-1a.tbl"
	
	gunzip -f ${CatWISEDir}/stf-mrg13_asce.Opt-1a-rf1.tbl 
	gunzip -f ${CatWISEDir}/stf-mrg13_desc.Opt-1a-rf2.tbl
	gunzip -f ${AsceDir}/stf-mdex_asce.Opt-1a.tbl
        gunzip -f ${DescDir}/stf-mdex_desc.Opt-1a.tbl


	### gsa
	echo calling gsa on $RadecID
	/Users/CatWISE/gsa -t ${AsceDir}/stf-mdex_asce.Opt-1a.tbl -t ${DescDir}/stf-mdex_desc.Opt-1a.tbl -o ${CatWISEDir}/gsa.tbl -ra1 ra -ra2 ra -dec1 dec -dec2 dec -r 20 -cw -a1 -ns -rf1 ${CatWISEDir}/stf-mrg13_asce.Opt-1a-rf1.tbl -rf2 ${CatWISEDir}/stf-mrg13_desc.Opt-1a-rf2.tbl -td ${CatWISEDir}/ProgramTerminalOutput/ 
	#check the exit status of mrgad (may need to change option-0.tcsh
        set saved_status = $?
	echo saved_status == $saved_status
        if($saved_status != 0) then #if program failed, status != 0
		echo Failure detected on tile $RadecID
                set failedProgram = "gsa"
                goto Failed
        endif

       #changing from set date_t =`date`
       #changed {date} to {date_t} prme 2018 mar 14
	set date_t = `date +"%Y%m%d_%H%M%S"`        


       ### mrgad
	echo calling mrgad on $RadecID
  	/Users/CatWISE/mrgad -i ${CatWISEDir}/gsa.tbl -ia ${AsceDir}/stf-mdex_asce.Opt-1a.tbl -id ${DescDir}/stf-mdex_desc.Opt-1a.tbl -o ${CatWISEDir}/${RadecID}_opt1_${date_t}.tbl
       #check the exit status of mrgad (may need to change option-0.tcsh
        set saved_status = $?
	echo saved_status == $saved_status
        if($saved_status != 0) then #if program failed, status != 0
		echo Failure detected on tile $RadecID
                set failedProgram = "mrgad"
                goto Failed
        endif
       
        #steps to save disk space	
	#gzip output
	gzip -f ${CatWISEDir}/${RadecID}_opt1_${date_t}.tbl
	gzip -f	${CatWISEDir}/stf-mrg13_asce.Opt-1a-rf1.tbl 
	gzip -f ${CatWISEDir}/stf-mrg13_desc.Opt-1a-rf2.tbl
	gzip -f ${AsceDir}/stf-mdex_asce.Opt-1a.tbl 
	gzip -f ${DescDir}/stf-mdex_desc.Opt-1a.tbl	
       #rm output 	
	rm -f ${CatWISEDir}/gsa.tbl 

       #rsync folders from Tyto, Athene, Otus
        if($rsyncSet == "true") then
 	       #rsync
       		echo running rsync on tile $RadecID
        	set currIP = `dig +short myip.opendns.com @resolver1.opendns.com`
       	 	echo current IP = $currIP
        	if($currIP == "137.78.30.21") then #Tyto
                	set otus_CatWISEDir = `echo $CatWISEDir | sed 's/CatWISE1/otus1/g'`
                	set athene_CatWISEDir = `echo $CatWISEDir | sed 's/CatWISE1/athene1/g'`
                	set otus_CatWISEDir = `echo $otus_CatWISEDir | sed 's/tyto/otus/g'`
                	set athene_CatWISEDir = `echo $athene_CatWISEDir | sed 's/tyto/athene/g'`
                	set otus_CatWISEDir = `echo $otus_CatWISEDir | sed 's/CatWISE3/otus3/g'`
                	set athene_CatWISEDir = `echo $athene_CatWISEDir | sed 's/CatWISE3/athene3/g'`
                	echo On Tyto!

               	       #Transfer Tyto CatWISE/ dir to Otus
                	echo rsync Tyto\'s $CatWISEDir to Otus $otus_CatWISEDir
                	ssh ${user}@137.78.80.75 "mkdir -p $otus_CatWISEDir"
                	rsync -avu $CatWISEDir ${user}@137.78.80.75:$otus_CatWISEDir

               	       #Transfer Tyto CatWISE/ dir to Athene
                	echo rsync Tyto\'s $CatWISEDir to Athene $athene_CatWISEDir
                	ssh ${user}@137.78.80.72 "mkdir -p $athene_CatWISEDir"
                	rsync -avu  $CatWISEDir ${user}@137.78.80.72:$athene_CatWISEDir
        	else if($currIP == "137.78.80.75") then  #Otus
                	set tyto_CatWISEDir = `echo $CatWISEDir | sed 's/otus3/CatWISE3/g'`
                	set tyto_CatWISEDir = `echo $tyto_CatWISEDir | sed 's/otus/tyto/g'`
                	set athene_CatWISEDir = `echo $CatWISEDir | sed 's/otus/athene/g'`
                	echo On Otus!

               	       #Transfer Otus CatWISE/ dir to Tyto
                	echo rsync Otus\'s $CatWISEDir to Tyto $tyto_CatWISEDir
                	ssh ${user}@137.78.30.21 "mkdir -p $tyto_CatWISEDir"
                	rsync -avu $CatWISEDir ${user}@137.78.30.21:$tyto_CatWISEDir
	
            	       #Transfer Otus CatWISE/ to Athene
                	echo rsync Otus\'s $CatWISEDir/to Athene $athene_CatWISEDir
                	ssh ${user}@137.78.80.72 "mkdir -p $athene_CatWISEDir"
                	rsync -avu  $CatWISEDir ${user}@137.78.80.72:$athene_CatWISEDir
        	else if($currIP == "137.78.80.72") then #Athene
                	set tyto_CatWISEDir = `echo $CatWISEDir | sed 's/athene3/CatWISE3/g'`
                	set tyto_CatWISEDir = `echo $tyto_CatWISEDir | sed 's/athene/tyto/g'`
                	set otus_CatWISEDir = `echo $CatWISEDir | sed 's/athene/otus/g'`
                	echo On Athene!

               	       #Transfer to Tyto
                	echo rsync Athene\'s $CatWISEDir/ to Tyto $tyto_CatWISEDir
                	ssh ${user}@137.78.30.21 "mkdir -p $tyto_CatWISEDir"
                	rsync -avu $CatWISEDir ${user}@137.78.30.21:$tyto_CatWISEDir
	
                       #Transfer to Otus
               	 	echo rsync Athene\'s $CatWISEDir/ to Otus $otus_CatWISEDir
                	ssh ${user}@137.78.80.75 "mkdir -p $otus_CatWISEDir"
                	rsync -avu $CatWISEDir ${user}@137.78.80.75:$otus_CatWISEDir
        	endif
        endif

	goto Done

Done:
echo MRGADWrapper Mode: ${1} Done!
echo
set endTime = `date '+%m/%d/%Y %H:%M:%S'`
echo Wrapper Mode ${1} Ended at:
echo $endTime
exit

#program jumps here if a program returns an exit status 32(Warning) or 64(Error)
Failed:
echo exit status of ${failedProgram} for tile \[${RadecID}\]\: ${saved_status}
	set currIP = `dig +short myip.opendns.com @resolver1.opendns.com`
        echo current IP = $currIP
        if($currIP == "137.78.30.21") then #Tyto
		if($saved_status <= 32) then #status <= 32, WARNING 
			echo WARNING ${failedProgram} on tile \[$RadecID\] exited with status ${saved_status}	
			echo WARNING ${failedProgram} on tile \[$RadecID\] exited with status ${saved_status} >> /Volumes/tyto2/ErrorLogsTyto/errorlog_${startTime}.txt 	
               		echo WARNING output to error log: /Volumes/tyto2/ErrorLogsTyto/errorlog_${startTime}.txt

			if($rsyncSet == "true") then #rsync to other machines
	 	       	       #Transfer Tyto ErrorLogsTyto/ dir to Otus
               	 		echo rsync Tyto\'s /Volumes/tyto2/ErrorLogsTyto/ to Otus /Volumes/otus2/ErrorLogsTyto/
                		ssh ${user}@137.78.80.75 "mkdir -p /Volumes/otus2/ErrorLogsTyto/"
                		rsync -avu /Volumes/tyto2/ErrorLogsTyto/ ${user}@137.78.80.75:/Volumes/otus2/ErrorLogsTyto/

	               	       #Transfer Tyto ErrorLogsTyto/ dir to Athene
        	        	echo rsync Tyto\'s /Volumes/tyto2/ErrorLogsTyto/ to Athene /Volumes/athene2/ErrorLogsTyto/ 
                		ssh ${user}@137.78.80.72 "mkdir -p /Volumes/athene2/ErrorLogsTyto/"
                		rsync -avu  /Volumes/tyto2/ErrorLogsTyto/ ${user}@137.78.80.72:/Volumes/athene2/ErrorLogsTyto/ 
			endif
			echo Exiting wrapper...
			exit
		else if($saved_status > 32) then #status > 32, ERROR
			echo ERROR ${failedProgram} on tile \[$RadecID\] exited with status ${saved_status}
	                echo ERROR ${failedProgram} on tile \[$RadecID\] exited with status ${saved_status} >> /Volumes/tyto2/ErrorLogsTyto/errorlog_${startTime}.txt
               		echo ERROR output to error log: /Volumes/tyto2/ErrorLogsTyto/errorlog_${startTime}.txt

			if($rsyncSet == "true") then #rsync to other machines
	 	       	       #Transfer Tyto ErrorLogsTyto/ dir to Otus
               	 		echo rsync Tyto\'s /Volumes/tyto2/ErrorLogsTyto/ to Otus /Volumes/otus2/ErrorLogsTyto/
                		ssh ${user}@137.78.80.75 "mkdir -p /Volumes/otus2/ErrorLogsTyto/"
                		rsync -avu /Volumes/tyto2/ErrorLogsTyto/ ${user}@137.78.80.75:/Volumes/otus2/ErrorLogsTyto/

	               	       #Transfer Tyto ErrorLogsTyto/ dir to Athene
        	        	echo rsync Tyto\'s /Volumes/tyto2/ErrorLogsTyto/ to Athene /Volumes/athene2/ErrorLogsTyto/ 
                		ssh ${user}@137.78.80.72 "mkdir -p /Volumes/athene2/ErrorLogsTyto/"
                		rsync -avu  /Volumes/tyto2/ErrorLogsTyto/ ${user}@137.78.80.72:/Volumes/athene2/ErrorLogsTyto/ 
			endif
			echo Exiting wrapper...
			exit
		endif
	else if($currIP == "137.78.80.75") then  #Otus
		if($saved_status <= 32) then #status <= 32, WARNING
			echo WARNING ${failedProgram} on tile \[$RadecID\] exited with status ${saved_status}
                	echo WARNING ${failedProgram} on tile \[$RadecID\] exited with status ${saved_status} >> /Volumes/otus1/ErrorLogsOtus/errorlog_${startTime}.txt
               		echo WARNING output to error log: /Volumes/otus1/ErrorLogsOtus/errorlog_${startTime}.txt
	
			if($rsyncSet == "true") then #rsync to other machines
	                       #Transfer Otus ErrorLogsOtus/ dir to Tyto
       		         	echo rsync Otus\'s /Volumes/otus1/ErrorLogsOtus/ to Tyto /Volumes/tyto1/ErrorLogsOtus/
       		         	ssh ${user}@137.78.30.21 "mkdir -p /Volumes/tyto1/ErrorLogsOtus/"
               		 	rsync -avu /Volumes/otus1/ErrorLogsOtus/ ${user}@137.78.30.21:/Volumes/tyto1/ErrorLogsOtus/

            	   	       #Transfer Otus ErrorLogsOtus/ dir to Athene
            	    		echo rsync Otus\'s /Volumes/otus1/ErrorLogsOtus/ to Athene /Volumes/athene1/ErrorLogsOtus/
               		 	ssh ${user}@137.78.80.72 "mkdir -p /Volumes/athene1/ErrorLogsOtus/"
                		rsync -avu /Volumes/otus1/ErrorLogsOtus/ ${user}@137.78.80.72:/Volumes/athene1/ErrorLogsOtus/
			endif
			echo Exiting wrapper...
			exit
		else if($saved_status > 32) then #status > 32, ERROR
                        echo ERROR ${failedProgram} on tile \[$RadecID\] exited with status ${saved_status}
                        echo ERROR ${failedProgram} on tile \[$RadecID\] exited with status ${saved_status} >> /Volumes/otus1/ErrorLogsOtus/errorlog_${startTime}.txt
                        echo ERROR output to error log: /Volumes/otus1/ErrorLogsOtus/errorlog_${startTime}.txt

			if($rsyncSet == "true") then #rsync to other machines
	                       #Transfer Otus ErrorLogsOtus/ dir to Tyto
       		         	echo rsync Otus\'s /Volumes/otus1/ErrorLogsOtus/ to Tyto /Volumes/tyto1/ErrorLogsOtus/
       		         	ssh ${user}@137.78.30.21 "mkdir -p /Volumes/tyto1/ErrorLogsOtus/"
               		 	rsync -avu /Volumes/otus1/ErrorLogsOtus/ ${user}@137.78.30.21:/Volumes/tyto1/ErrorLogsOtus/

            	   	       #Transfer Otus ErrorLogsOtus/ dir to Athene
            	    		echo rsync Otus\'s /Volumes/otus1/ErrorLogsOtus/ to Athene /Volumes/athene1/ErrorLogsOtus/
               		 	ssh ${user}@137.78.80.72 "mkdir -p /Volumes/athene1/ErrorLogsOtus/"
                		rsync -avu /Volumes/otus1/ErrorLogsOtus/ ${user}@137.78.80.72:/Volumes/athene1/ErrorLogsOtus/
			endif
			echo Exiting wrapper...
			exit
                endif

	else if($currIP == "137.78.80.72") then  #Athene
                if($saved_status <= 32) then #status <= 32, WARNING
                        echo WARNING ${failedProgram} on tile \[$RadecID\] exited with status ${saved_status}
                        echo WARNING ${failedProgram} on tile \[$RadecID\] exited with status ${saved_status} >> /Volumes/athene3/ErrorLogsAthene/errorlog_${startTime}.txt
                        echo WARNING output to error log: /Volumes/athene3/ErrorLogsAthene/errorlog_${startTime}.txt
                	
			if($rsyncSet == "true") then #rsync to other machines
                 	       #Transfer Athene ErrorLogsAthene/ dir to Tyto
                      	  	echo rsync Athene\'s /Volumes/athene3/ErrorLogsAthene/ to Tyto /Volumes/CatWISE3/ErrorLogsAthene/
                        	ssh ${user}@137.78.30.21 "mkdir -p /Volumes/CatWISE3/ErrorLogsAthene/"
                        	rsync -avu /Volumes/athene3/ErrorLogsAthene/ ${user}@137.78.30.21:/Volumes/CatWISE3/ErrorLogsAthene/

              	               #Transfer Athene ErrorLogsTyto/ dir to Otus
                        	echo rsync Athene\'s /Volumes/athene3/ErrorLogsAthene/ to Otus /Volumes/otus3/ErrorLogsAthene/
                        	ssh ${user}@137.78.80.72 "mkdir -p /Volumes/otus3/ErrorLogsAthene/"
                        	rsync -avu /Volumes/athene3/ErrorLogsAthene/ ${user}@137.78.80.72:/Volumes/otus3/ErrorLogsAthene/
                	endif
			echo Exiting wrapper...
			exit
                else if($saved_status > 32) then #status > 32, ERROR
                        echo ERROR ${failedProgram} on tile \[$RadecID\] exited with status ${saved_status}
                        echo ERROR ${failedProgram} on tile \[$RadecID\] exited with status ${saved_status} >> /Volumes/athene3/ErrorLogsAthene/errorlog_${startTime}.txt
                        echo ERROR output to error log: /Volumes/athene3/ErrorLogsAthene/errorlog_${startTime}.txt

                	if($rsyncSet == "true") then #rsync to other machines
                 	       #Transfer Athene ErrorLogsAthene/ dir to Tyto
                      	  	echo rsync Athene\'s /Volumes/athene3/ErrorLogsAthene/ to Tyto /Volumes/CatWISE3/ErrorLogsAthene/
                        	ssh ${user}@137.78.30.21 "mkdir -p /Volumes/CatWISE3/ErrorLogsAthene/"
                        	rsync -avu /Volumes/athene3/ErrorLogsAthene/ ${user}@137.78.30.21:/Volumes/CatWISE3/ErrorLogsAthene/

              	               #Transfer Athene ErrorLogsTyto/ dir to Otus
                        	echo rsync Athene\'s /Volumes/athene3/ErrorLogsAthene/ to Otus /Volumes/otus3/ErrorLogsAthene/
                        	ssh ${user}@137.78.80.72 "mkdir -p /Volumes/otus3/ErrorLogsAthene/"
                        	rsync -avu /Volumes/athene3/ErrorLogsAthene/ ${user}@137.78.80.72:/Volumes/otus3/ErrorLogsAthene/
                	endif
			echo Exiting wrapper...
			exit
                endif

	endif

