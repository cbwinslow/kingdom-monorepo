#!/usr/bin/env bash
# Docker and Container Operations

# Docker ps
dps() {
    docker ps "$@"
}

# Docker ps all
dpsa() {
    docker ps -a
}

# Docker images
di() {
    docker images
}

# Docker build
db() {
    docker build -t "$@" .
}

# Docker run
dr() {
    docker run "$@"
}

# Docker run interactive
dri() {
    docker run -it "$@" /bin/bash
}

# Docker exec
dex() {
    docker exec -it "$1" /bin/bash
}

# Docker exec as root
dexr() {
    docker exec -it -u root "$1" /bin/bash
}

# Docker logs
dl() {
    docker logs "$@"
}

# Docker logs follow
dlf() {
    docker logs -f "$@"
}

# Docker stop
dst() {
    docker stop "$@"
}

# Docker stop all
dstop_all() {
    docker stop $(docker ps -q)
}

# Docker start
dstart() {
    docker start "$@"
}

# Docker restart
drestart() {
    docker restart "$@"
}

# Docker remove
drm() {
    docker rm "$@"
}

# Docker remove force
drmf() {
    docker rm -f "$@"
}

# Docker remove all stopped containers
drm_stopped() {
    docker container prune -f
}

# Docker remove image
drmi() {
    docker rmi "$@"
}

# Docker remove all images
drmi_all() {
    docker rmi $(docker images -q)
}

# Docker remove dangling images
drmi_dangling() {
    docker image prune -f
}

# Docker system prune
dprune() {
    docker system prune -af --volumes
}

# Docker inspect
dins() {
    docker inspect "$@"
}

# Docker stats
dstats() {
    docker stats
}

# Docker compose up
dcup() {
    docker-compose up "$@"
}

# Docker compose up detached
dcupd() {
    docker-compose up -d "$@"
}

# Docker compose down
dcdown() {
    docker-compose down "$@"
}

# Docker compose restart
dcrestart() {
    docker-compose restart "$@"
}

# Docker compose logs
dclogs() {
    docker-compose logs "$@"
}

# Docker compose logs follow
dclogsf() {
    docker-compose logs -f "$@"
}

# Docker compose build
dcbuild() {
    docker-compose build "$@"
}

# Docker compose ps
dcps() {
    docker-compose ps
}

# Docker compose exec
dcex() {
    docker-compose exec "$@" /bin/bash
}

# Docker volume list
dvls() {
    docker volume ls
}

# Docker volume remove
dvrm() {
    docker volume rm "$@"
}

# Docker volume prune
dvprune() {
    docker volume prune -f
}

# Docker network list
dnls() {
    docker network ls
}

# Docker network remove
dnrm() {
    docker network rm "$@"
}

# Docker network prune
dnprune() {
    docker network prune -f
}

# Get container IP
dip() {
    docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$1"
}

# Get container name from ID
dname() {
    docker inspect -f '{{.Name}}' "$1" | sed 's/^\///'
}

# Docker kill all
dkill_all() {
    docker kill $(docker ps -q)
}

# Docker shell into running container
dshell() {
    local container="$1"
    shift
    docker exec -it "$container" "${@:-/bin/bash}"
}

# Docker show container ports
dports() {
    docker port "$1"
}

# Docker copy file from container
dcp_from() {
    docker cp "$1":"$2" "$3"
}

# Docker copy file to container
dcp_to() {
    docker cp "$1" "$2":"$3"
}

# Docker run with current directory mounted
drun_here() {
    docker run -it -v "$(pwd)":/workspace -w /workspace "$@"
}

# Docker clean everything
dclean() {
    echo "Stopping all containers..."
    docker stop $(docker ps -aq) 2>/dev/null
    echo "Removing all containers..."
    docker rm $(docker ps -aq) 2>/dev/null
    echo "Removing all images..."
    docker rmi $(docker images -q) 2>/dev/null
    echo "Removing all volumes..."
    docker volume prune -f
    echo "Removing all networks..."
    docker network prune -f
    echo "System prune..."
    docker system prune -af --volumes
    echo "Docker cleaned!"
}

# Show docker disk usage
ddisk() {
    docker system df
}

# Docker build with no cache
dbuild_nc() {
    docker build --no-cache -t "$@" .
}

# Docker commit container
dcommit() {
    docker commit "$1" "$2"
}

# Docker tag image
dtag() {
    docker tag "$1" "$2"
}

# Docker push image
dpush() {
    docker push "$@"
}

# Docker pull image
dpull() {
    docker pull "$@"
}

# Docker search
dsearch() {
    docker search "$@"
}

# Docker history
dhist() {
    docker history "$@"
}

# Docker export container
dexport() {
    docker export "$1" > "$2"
}

# Docker import image
dimport() {
    docker import "$1" "$2"
}

# Docker save image
dsave() {
    docker save -o "$2" "$1"
}

# Docker load image
dload() {
    docker load -i "$1"
}

# Get container environment variables
denv() {
    docker exec "$1" env
}

# Docker top
dtop() {
    docker top "$@"
}

# Docker pause
dpause() {
    docker pause "$@"
}

# Docker unpause
dunpause() {
    docker unpause "$@"
}

# Docker wait
dwait() {
    docker wait "$@"
}

# Docker attach
dattach() {
    docker attach "$@"
}

# Docker rename
drename() {
    docker rename "$1" "$2"
}

# Docker update resources
dupdate() {
    docker update "$@"
}

# Show dockerfile of image
dfile() {
    docker history --no-trunc "$1" | tac | tr -s ' ' | cut -d ' ' -f 5- | sed 's,^/bin/sh -c #(nop) ,,g' | sed 's,^/bin/sh -c,RUN,g' | sed 's, && ,\n  && ,g' | sed 's,\s*[0-9]*[\.]*[0-9]*[kMG]*B\s*$,,g' | head -n -1
}

# Docker login
dlogin() {
    docker login "$@"
}

# Docker logout
dlogout() {
    docker logout
}

# Create docker network
dnet_create() {
    docker network create "$@"
}

# Connect container to network
dnet_connect() {
    docker network connect "$1" "$2"
}

# Disconnect container from network
dnet_disconnect() {
    docker network disconnect "$1" "$2"
}

# Inspect network
dnet_inspect() {
    docker network inspect "$@"
}

# Create docker volume
dvol_create() {
    docker volume create "$@"
}

# Inspect volume
dvol_inspect() {
    docker volume inspect "$@"
}

# Docker events
devents() {
    docker events "$@"
}

# Docker info
dinfo() {
    docker info
}

# Docker version
dver() {
    docker version
}

# Run docker with TTY
dtty() {
    docker run -it "$@"
}

# Run docker in background
ddetach() {
    docker run -d "$@"
}

# Docker stats for specific container
dstat() {
    docker stats "$1" --no-stream
}
