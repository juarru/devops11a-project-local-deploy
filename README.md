# PROYECTO GRUPO DEVOPS11A

Proyecto del grupo DEVOPS11A  

Repositorio de manifiestos de Kubernetes y argocd para la práctica de cicd.

## TABLA DE CONTENIDOS

- [Descripción](#descripción)
- [Estructura del Proyecto](#estructura-del-proyecto)
- [Requisitos](#requisitos)
- [Despliegue](#despliegue)
- [Acceso a la aplicación](#acceso-a-la-aplicación)
- [Notas](#notas)

## Descripción

Este repositorio contiene los manifiestos de *Kubernetes* para desplegar *ArgoCD* y la aplicación *Flask* con los servicios *Redis*, *Elasticsearch*, *Kibana*, *Prometheus* y *Grafana*,  que se encuentran asociados al proyecto final.

## Estructura del Proyecto

```bash
/
|-- k8s/ # Contiene los manifiestos de Kubernetes para desplegar la aplicación Flask y Redis
|   |-- elasticsearch/ # Contiene los manifiestos para desplegar el servicio de ElasticSearch.
|   |-- grafana/ # Contiene los manifiestos para desplegar el servicio de Grafana.
|   |-- kibana/ # Contiene los manifiestos para desplegar el servicio de Kibana.
|   |-- prometheus/ # Contiene los manifiestos para desplegar el servicio de Prometheus.
|   |-- deployment.yml  # Define el despliegue de la aplicación Flask con 2 réplicas, límites y peticiones de recursos adecuados.
|   |-- ingress.yml # Configura un recurso Ingress para acceder a la aplicación Flask mediante `flask.local`.
|   |-- kustomization.yaml # Define los ficheros y carpetas que forman parte del despliegue
|   |-- redis-deployment.yml # Define el despliegue de Redis con una única réplica.
|   |-- redis-service.yml # Expone Redis como un servicio accesible dentro del clúster en el puerto 6379.
|   |-- service.yml # Define un servicio de tipo `NodePort` para la aplicación Flask, permitiendo el acceso a través del puerto 80.
|
|-- kind/ # Contiene la configuración para desplegar un clúster local con Kind
|   |-- kind-config.yml # Configura un clúster Kind con un control-plane y redirección de puertos para acceso a Ingress.
|   |-- local-storage.yml # Configura la persistencia de datos en el despliegue.
|
|-- manifest/ # Contiene el manifiesto de ArgoCD para la gestión del despliegue
|   |-- application.yml # Configura ArgoCD para desplegar la aplicación desde el repositorio en GitHub y sincronizar automáticamente los cambios.
|
|-- install.sh # Script de instalación y configuración del entorno
|-- README.md # Documentación del proyecto.
```

## Requisitos

- [*Docker*](https://www.docker.com/)
- [*Kind*](https://kind.sigs.k8s.io/)
- [*kubectl*](https://kubernetes.io/docs/tasks/tools/)

## Despliegue

Clonamos el Repositorio del proyecto.

```bash
git clone https://github.com/juarru/devops11a-project-local-deploy.git
cd devops11a-project-local-deploy
```

Existe un fichero `install.sh` que realiza casi todo el proceso de manera automática. Damos permisos al fichero para poder ejecutarse y lo lanzamos.

```bash
sudo chmod +x install.sh
./install.sh
```

Se ejecutarán todas las acciones, y se devolverá al final una serie de instrucciones que hay que seguir para terminar con el proceso.

Como se indica en la salida del despliegue, ahora habrá que realizar los siguientes pasos:

- Hacer el *port-forward* para poder acceder a *ArgoCD*. Mantenerlo en ejecución.

```kubectl
kubectl port-forward svc/argocd-server -n argocd 8081:443
```

- Si no ha dado tiempo a desplegar el pod de *ArgoCD*, habrá fallado la devolución del password. Realizar la instrucción que se indica en la salida del ejecutable.

```kubectl
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath={.data.password} | base64 -d
```

- Ahora podemos acceder a *ArgoCD* en la dirección `http://localhost:8081`

- La aplicación aparecerá desplegada.

## Acceso a la aplicación

Para ver la aplicación funcionando, primero habrá que editar el fichero `hosts` de su máquina, y añadir la siguiente línea:

```bash
127.0.0.1       flask.local kibana.local prometheus.local grafana.local
```

Una vez configurado esto, podemos acceder a la aplicación en la url `http://flask.local` en el navegador. También podremos acceder al resto de servicios mediante `http://kibana.local` , `http://prometheus.local` y `http:// grafana.local` .

## Notas

- La sincronización en ArgoCD está configurada con auto-pruning y self-heal.
- La imagen de la aplicación Flask se obtiene desde `ghcr.io/juarru/devops11a-project-app:main`.
- El servicio de Redis se ejecuta en el namespace `flask`.
