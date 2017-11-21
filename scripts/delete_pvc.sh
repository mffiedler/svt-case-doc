function delete_projects()
{
  echo "deleting pvc"
  oc delete pvc --all -n pvcproject0
}

function wait_for_project_termination()
{
  terminating=`oc get pv | grep pvcproject0 | wc -l`
  while [ ${terminating} -ne 0 ]; do
  sleep 5
  terminating=`oc get pv | grep pvcproject0 | wc -l`
  echo "$terminating pv are still there"
  done
}

start_time=`date +%s`

delete_projects
wait_for_project_termination

stop_time=`date +%s`
total_time=`echo $stop_time - $start_time | bc`
echo "Deletion Time - $total_time"
