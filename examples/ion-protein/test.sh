#!/bin/bash

if [[ $1 = "" ]]; then
    echo "Please use \"make test\" to run the tests."
    exit
fi


logfile=TESTRESULTS.log
nettime=0
vsmall=0.000000001000

input=( apbs-mol-pdiel2 apbs-smol-pdiel2 apbs-spl2-pdiel2 apbs-mol-pdiel12 apbs-smol-pdiel12 apbs-spl2-pdiel12 )

results=( 2.165734649777E+01  2.283125507537E+01 1.815826421427E+01 1.872804169880E+01 1.926032297424E+01 1.743122248521E+01 )

# Initialize the results file

date=`date`
echo "Date     : ${date}" >> $logfile
echo "Directory: ion-protein" >> $logfile
echo "Results  :" >> $logfile

# For each file in the directory, run APBS and get the value

for i in 0 1 2 3 4 5
do
  echo "----------------------------------------"
  echo "Testing input file ${input[i]}.in"
  echo ""

 
  starttime=`date +%s`
  $1 ${input[i]}.in > ${input[i]}.out 
  answer=`grep "Global net" ${input[i]}.out | awk '{print $5}'`

  echo "Global net energy: $answer"
  sync

  fanswer=`printf "%.12f" $answer`
  fexpected=`printf "%.12f" ${results[i]}`
  r=`echo "scale=12;if($fanswer>($fexpected-$vsmall) && $fanswer<($fexpected+$vsmall))r=1;if($fanswer == $fexpected)r=2;r" | bc`
  
  case "$r" in
      2)  echo "*** PASSED ***"
          echo "           ${input[i]}.in: PASSED ($answer)" >> $logfile ;;
      1)
          echo "*** PASSED (with rounding error - see log) ***"
          echo "           ${input[i]}.in: PASSED with rounding error ($answer; expected ${results[i]})" >> $logfile ;;
      *)
          echo "*** FAILED ***"
          echo "   APBS returned $answer"
          echo "   Expected result is ${results[i]}"
          echo "           ${input[i]}.in: FAILED ($answer; expected ${results[i]})" >> $logfile ;;
  esac
  
  endtime=`date +%s`
  let elapsed=$endtime-$starttime
  let nettime=$nettime+$elapsed
  echo "Total elapsed time: $elapsed seconds"
  echo "----------------------------------------"


done

echo "Test results have been logged to ${logfile}."
echo "Total time for this directory: ${nettime} seconds."

echo "Time     : ${nettime} seconds" >> $logfile
echo "" >> $logfile
