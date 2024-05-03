#!/bin/bash
### HOW TO USE #################################################################################
### SYNTAX: ./outcars2nepDataset.sh dire_name   
###     NOTE: 1).'dire_name' is the directory containing OUTCARs
### Email: yanzhowang@gmail.com if any questions
### Modified by Shunda Chen
### Modified by Nan Xu
################################################################################################
#--- DEFAULT ASSIGNMENTSts ---------------------------------------------------------------------
isol_ener=0     # Shifted energy, specify the value?
viri_logi=1     # Logical value for virial, true=1, false=0
check_convergency=1 # # Logical value for checking_convergency, true=1, false=0
#--------------------------------------------------------------------------------------------
read_dire=$1
if [ -z $read_dire ]; then
        echo "Your syntax is illegal, please specify dirs that contain OUTCAR!"
        exit
fi
writ_dire="NEPdataset"; writ_file="NEP-dataset.xyz";
rm -rf $writ_dire; mkdir $writ_dire

N_case=$(find -L $read_dire -name "OUTCAR" | wc -l)
N_count=1
failed_count=0
to_print=()
for i in `find -L $read_dire -name "OUTCAR"`
do
	     configuration=$(echo "$i" |sed 's/\/OUTCAR//g' | awk -F'/' '{print $NF}')
           if [[ $check_convergency -eq 1 ]]
           then
                 grep "General timing and accounting informations" $i >/dev/null 2>&1
                 if [ $? -ne 0 ]
                 then
                       current_info=$(echo "$i" |sed 's/\/OUTCAR//g' | awk -F'/' '{print $NF}')
                       to_print+=($current_info)
                       let failed_count+=1
                       continue  				
                 fi
                 lastscf=$(grep "Iteration" $i | tail -n 1 | awk -F'(' '{print $NF}' | awk -F')' '{print $1}')
                 MAXSCF=$(grep "NELMIN=.*NELMDL=" $i | awk -F'=' '{print $2}' | awk -F';' '{print $1}')
                 if [ ${MAXSCF} -eq ${lastscf} ]
                 then
                       current_info=$(echo "$i" |sed 's/\/OUTCAR//g' | awk -F'/' '{print $NF}') 
                       to_print+=($current_info)
                       let failed_count+=1
                       continue  				
                 fi                 
           fi
             syst_numb_atom=$(grep "number of ions" $i |awk '{print $12}')
             echo $syst_numb_atom >> $writ_dire/$writ_file
             latt=$(grep -A 7 "VOLUME and BASIS-vectors are now" $i |tail -n 3 |sed 's/-/ -/g'  |awk '{print $1,$2,$3}' |xargs)
             ener=$(grep "free  energy   TOTEN" $i | tail -1 | awk '{printf "%.6f\n", $5 - '$syst_numb_atom' * '$isol_ener'}')
             if [[ $viri_logi -eq 1 ]]
             then
                   viri=$(grep -A 20 "FORCE on cell =-STRESS" $i | grep "Total " | tail -n 1 | awk '{print $2,$5,$7,$5,$3,$6,$7,$6,$4}')
                   echo "Config_type=$configuration Weight=1.0 Lattice=\"$latt\" Energy=$ener Virial=\"$viri\" Properties=species:S:1:pos:R:3:forces:R:3" >> $writ_dire/$writ_file
             else
                   echo "Config_type=$configuration Weight=1.0 Lattice=\"$latt\" Energy=$ener Properties=species:S:1:pos:R:3:forces:R:3" >> $writ_dire/$writ_file
             fi
             ion_numb_arra=($(grep "ions per type"  $i | tail -n 1 | awk -F"=" '{print $2}'))
             ion_symb_arra=($(grep "POTCAR:" $i  | awk '{print $3}' | awk -F"_" '{print $1}' | awk '!seen[$0]++'))
             #ion_symb_arra=($(grep "VRHFIN" $i | awk -F"=" '{print $2}' |awk -F":" '{print $1}'))
             for((j=0;j<${#ion_numb_arra[*]};j++))
             do
                     printf ''${ion_symb_arra[j]}'%.0s\n' `seq 1 1 ${ion_numb_arra[j]}` >> $writ_dire/symb.tem
             done
             grep -A $(($syst_numb_atom + 1)) "TOTAL-FORCE (eV/Angst)" $i | tail -n $syst_numb_atom > $writ_dire/posi_forc.tem
             paste $writ_dire/symb.tem $writ_dire/posi_forc.tem >> $writ_dire/$writ_file
             rm -f $writ_dire/*.tem
           echo 
	     echo -ne "\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\bProgress: $N_count/$N_case "

             N_count=$((N_count + 1))
done
echo

if [ -f "$writ_dire/$writ_file" ]; then
    dos2unix "$writ_dire/$writ_file" >  /dev/null 2>&1
    if [ $? -ne 0 ]; then
      sed -i "s/\t/    /g" "$writ_dire/$writ_file" 
      sed -i "s/\r//g" "$writ_dire/$writ_file"
    fi
    if [ $failed_count -ne 0 ]; then
      echo "Conversion successfully, but the following jobs may failed."
      for str in ${to_print[@]}; 
         do   
         echo $str; 
      done
    else
      echo "Conversion successfully."
    fi 
else 
    echo "Nothing found, conversion failed."
fi

