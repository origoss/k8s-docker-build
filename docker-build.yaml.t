apiVersion: batch/v1
kind: Job
metadata:
  name: docker-image-builder
spec:
  template:
    spec:
      containers:
      - name: builder
        image: docker
        workingDir: /git
        volumeMounts:
        - name: dockersock
          mountPath: /var/run/docker.sock
        - name: dockerconfig
          mountPath: /root/.docker
        - name: gitrepo
          mountPath: /git
        command:
        - sh
        - -c
        - |
          set -e
          TAGS="{{ range .tags }}-t {{ . }} {{ end }}"
          cd $(ls -tc -1 | head -n1)
          echo "docker build $TAGS ."
          docker build $TAGS .
          {{ range .tags }}
          echo "docker push {{ . }}"
          docker push {{ . }}
          {{ end }}
      restartPolicy: Never
      volumes:
      - name: dockersock
        hostPath:
          path: /var/run/docker.sock
          type: Socket
      - name: dockerconfig
        secret:
          secretName: docker-image-builder-secret
          items:
          - key: .dockerconfigjson
            path: config.json
      - name: gitrepo
        gitRepo:
          repository: {{ .gitrepo }}
