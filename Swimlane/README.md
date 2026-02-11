# swimlane
clone this repo

move to swimlane directory

enter helm install swimlane . -n swimlane --create-namespace ( where Chart.yaml is present)

once after if you still see PVC not binding , annotate it using  kubectl annotate storageclass gp2 storageclass.kubernetes.io/is-default-class="true"


once annotaed delete the pvc an let it come up on it own again
if required restart the deployment or delete the pods and let them come back again
finally check kubectl  get svc -n <ns> and take the ecternal url and paste it in the browser 

