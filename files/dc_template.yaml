
apiVersion: v1
kind: Template
metadata:
  creationTimestamp: null
  name: dc_template
objects:
- kind: "DeploymentConfig"
  apiVersion: "v1"
  metadata:
    name: "${NAME}"
  spec:
    template:
      metadata:
        labels:
          name: "${NAME}"
      spec:
        containers:
          - name: "${NAME}"
            image: "${POD_IMAGE}"
        volumeMounts:
          - name: "pvol"
            mountPath: "/data"
      volumes:
        - name: "pvol"
          persistentVolumeClaim:
            claimName: "${PVC_NAME}"
    triggers:
      - type: "ConfigChange"
    replicas: 1
parameters:
- description: Name
  displayName: Name
  name: NAME
  required: true
- description: Pod Image
  displayName: Pod Image
  name: POD_IMAGE
  required: true
  value: "docker.io/hongkailiu/svt-go:http"
- description: PVC Name
  displayName: PVC Name
  name: PVC_NAME
  required: true
