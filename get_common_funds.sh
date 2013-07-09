usage()
{
  echo "Usage: $0 (-i|-u|-a|-b) [-h] [-c -s <date-1> -e <date-2> ] file1 file2"
  echo " one of -i,-u,-a,-b is mandatory and are mutually exclusive"
  echo "    -i .. intersection of both files"
  echo "    -u .. union of both files"
  echo "    -a .. only in file1"
  echo "    -b .. only in file2"
  echo " -c .. Also invoke the cagr computation"
  echo "    -s .. start date"
  echo "    -e .. end date"
  echo " -h .. print this help and exit"
  exit 1;
}

INTERSECT=1
UNION=2
FILE1=3
FILE2=4

action=0
cagr=0
start_date=0
end_date=0

while getopts "iuabcs:e:h" opt; do
  case $opt in
    i)
      if [ $action != 0 ] ; then
        usage
      fi
      action=$INTERSECT
      ;;
    u)
      if [ $action != 0 ] ; then
        usage
      fi
      action=$UNION
      ;;
    a)
      if [ $action != 0 ] ; then
        usage
      fi
      action=$FILE1
      ;;
    b)
      if [ $action != 0 ] ; then
        usage
      fi
      action=$FILE2
      ;;
    c)
      cagr=1
      ;;
    s)
      start_date=$OPTARG;
      ;;
    e)
      end_date=$OPTARG;
      ;;
    h)
      usage $0
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      usage $0
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

if [ $action == 0 ] ; then
  usage $0
fi

if [ $cagr != 0 ] ; then
  if [[ ( $start_date -eq 0 ) || ( $end_date -eq 0 ) ]] ; then
    echo $start_date
    echo $end_date
    usage $0
  fi
fi

shift $((OPTIND-1))
# now do something with $@

if [ $# != 2 ] ; then 
  usage
fi

file1=$1
file2=$2

if [ $action != $INTERSECT ] ; then 
  echo "Sorry.. only intersect supported now"
  exit 1
fi

awk -v firstfile=$file1 -v cagr=$cagr -v start_date=$start_date -v end_date=$end_date ' BEGIN { 
    FS=";" ;
    while ( getline < firstfile ) {
      firstfilecontent[$1]=1;
      firstfilenav[$1]=$2;
    }
    cagr=strtonum(cagr)
  }
  1 {
    fund=$1;
    if (fund in firstfilecontent) {
      if (cagr == 1) {
        cmd= "./check_returns.tcl " start_date " " firstfilenav[fund] " " end_date " " $2;
        cmd | getline cagr_result
        close(cmd);
        printf "%s;%s\n",fund,cagr_result
      } else {
        printf "%s;%s;%s\n",fund,firstfilenav[fund],$2
      }
    }
  }' $file2

