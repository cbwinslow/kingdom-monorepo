#!/usr/bin/env bash
# Development Environment Helpers

# Node.js helpers
node_version() {
    node --version
}

npm_global() {
    npm list -g --depth=0
}

npm_outdated() {
    npm outdated -g
}

npm_update_all() {
    npm update -g
}

npm_clean() {
    rm -rf node_modules package-lock.json && npm install
}

yarn_clean() {
    rm -rf node_modules yarn.lock && yarn install
}

# Python helpers
py_version() {
    python --version 2>&1 || python3 --version
}

pip_list() {
    pip list 2>/dev/null || pip3 list
}

pip_outdated() {
    pip list --outdated 2>/dev/null || pip3 list --outdated
}

pip_upgrade_all() {
    pip list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1 | xargs -n1 pip install -U
}

venv_create() {
    python3 -m venv "${1:-venv}"
    echo "Virtual environment created: ${1:-venv}"
}

venv_activate() {
    source "${1:-venv}/bin/activate"
}

pyserver() {
    python3 -m http.server "${1:-8000}"
}

# Go helpers
go_version() {
    go version
}

go_mod_tidy() {
    go mod tidy
}

go_test() {
    go test ./...
}

go_build() {
    go build -o bin/ ./...
}

go_install_tools() {
    go install golang.org/x/tools/gopls@latest
    go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
}

# Ruby helpers
ruby_version() {
    ruby --version
}

gem_list() {
    gem list
}

gem_outdated() {
    gem outdated
}

bundle_clean() {
    rm -rf vendor/bundle Gemfile.lock && bundle install
}

# Java helpers
java_version() {
    java -version
}

mvn_clean() {
    mvn clean install
}

mvn_test() {
    mvn test
}

gradle_clean() {
    ./gradlew clean build
}

# Rust helpers
rust_version() {
    rustc --version
}

cargo_build() {
    cargo build
}

cargo_test() {
    cargo test
}

cargo_clean() {
    cargo clean
}

cargo_update() {
    cargo update
}

# PHP helpers
php_version() {
    php --version
}

composer_install() {
    composer install
}

composer_update() {
    composer update
}

composer_dump() {
    composer dump-autoload
}

# Database helpers
postgres_start() {
    pg_ctl -D /usr/local/var/postgres start
}

postgres_stop() {
    pg_ctl -D /usr/local/var/postgres stop
}

mysql_start() {
    mysql.server start 2>/dev/null || sudo systemctl start mysql
}

mysql_stop() {
    mysql.server stop 2>/dev/null || sudo systemctl stop mysql
}

redis_start() {
    redis-server 2>/dev/null || sudo systemctl start redis
}

redis_stop() {
    redis-cli shutdown 2>/dev/null || sudo systemctl stop redis
}

mongo_start() {
    mongod --config /usr/local/etc/mongod.conf 2>/dev/null || sudo systemctl start mongodb
}

mongo_stop() {
    mongod --shutdown 2>/dev/null || sudo systemctl stop mongodb
}

# Code formatting
format_json() {
    if [ -f "$1" ]; then
        python3 -m json.tool "$1"
    else
        echo "$1" | python3 -m json.tool
    fi
}

format_xml() {
    xmllint --format "$1"
}

format_yaml() {
    python3 -c "import yaml, sys; print(yaml.dump(yaml.safe_load(sys.stdin)))" < "$1"
}

# Code linting
lint_js() {
    eslint "$@"
}

lint_py() {
    pylint "$@" 2>/dev/null || flake8 "$@"
}

lint_sh() {
    shellcheck "$@"
}

# Build tools
make_clean() {
    make clean
}

make_build() {
    make all
}

make_install() {
    make install
}

cmake_build() {
    mkdir -p build && cd build && cmake .. && make
}

# Testing
test_all() {
    if [ -f "package.json" ]; then
        npm test
    elif [ -f "Cargo.toml" ]; then
        cargo test
    elif [ -f "go.mod" ]; then
        go test ./...
    elif [ -f "Gemfile" ]; then
        bundle exec rspec
    elif [ -f "pytest.ini" ] || [ -f "setup.py" ]; then
        pytest
    else
        echo "No test framework detected"
    fi
}

# Coverage
coverage_run() {
    if [ -f "package.json" ]; then
        npm run coverage
    elif [ -f "pytest.ini" ]; then
        pytest --cov
    elif [ -f "go.mod" ]; then
        go test -cover ./...
    fi
}

# Benchmarks
bench_run() {
    if [ -f "Cargo.toml" ]; then
        cargo bench
    elif [ -f "go.mod" ]; then
        go test -bench=. ./...
    fi
}

# Documentation
docs_serve() {
    if [ -d "docs" ]; then
        cd docs && python3 -m http.server 8080
    fi
}

# Code statistics
code_stats() {
    echo "=== Code Statistics ==="
    echo "Total files: $(find . -type f ! -path '*/\.*' | wc -l)"
    echo "Total lines: $(find . -type f ! -path '*/\.*' -exec wc -l {} + | tail -1 | awk '{print $1}')"
    echo ""
    echo "=== By Language ==="
    if command -v cloc > /dev/null; then
        cloc . --quiet
    else
        echo "Install 'cloc' for detailed statistics"
    fi
}

# Project initialization
init_node() {
    npm init -y
    echo "Node.js project initialized"
}

init_python() {
    touch requirements.txt
    echo "Python project initialized"
}

init_go() {
    go mod init "$(basename "$PWD")"
    echo "Go module initialized"
}

init_rust() {
    cargo init
    echo "Rust project initialized"
}

# Dependency management
deps_install() {
    if [ -f "package.json" ]; then
        npm install
    elif [ -f "requirements.txt" ]; then
        pip install -r requirements.txt
    elif [ -f "go.mod" ]; then
        go mod download
    elif [ -f "Cargo.toml" ]; then
        cargo build
    elif [ -f "Gemfile" ]; then
        bundle install
    elif [ -f "composer.json" ]; then
        composer install
    fi
}

deps_update() {
    if [ -f "package.json" ]; then
        npm update
    elif [ -f "requirements.txt" ]; then
        pip install --upgrade -r requirements.txt
    elif [ -f "go.mod" ]; then
        go get -u ./...
    elif [ -f "Cargo.toml" ]; then
        cargo update
    elif [ -f "Gemfile" ]; then
        bundle update
    elif [ -f "composer.json" ]; then
        composer update
    fi
}

# Watch for changes
watch_test() {
    if command -v fswatch > /dev/null; then
        fswatch -o . | xargs -n1 -I{} make test
    elif command -v inotifywait > /dev/null; then
        while inotifywait -r -e modify,create,delete .; do
            make test
        done
    else
        echo "Install fswatch or inotify-tools"
    fi
}

# Quick REPLs
repl_node() {
    node
}

repl_python() {
    python3
}

repl_ruby() {
    irb
}

repl_php() {
    php -a
}

# Version managers
nvm_use() {
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" && nvm use "$@"
}

pyenv_use() {
    eval "$(pyenv init -)" && pyenv shell "$@"
}

rbenv_use() {
    eval "$(rbenv init -)" && rbenv shell "$@"
}

# API testing
curl_post() {
    curl -X POST -H "Content-Type: application/json" -d "$2" "$1"
}

curl_get() {
    curl -X GET "$1"
}

curl_put() {
    curl -X PUT -H "Content-Type: application/json" -d "$2" "$1"
}

curl_delete() {
    curl -X DELETE "$1"
}

# JWT decode
jwt_decode() {
    jq -R 'split(".") | .[1] | @base64d | fromjson' <<< "$1"
}

# Base64 encode/decode
b64_encode() {
    echo -n "$1" | base64
}

b64_decode() {
    echo -n "$1" | base64 -d
}

# URL encode/decode
url_encode() {
    python3 -c "import urllib.parse; print(urllib.parse.quote('$1'))"
}

url_decode() {
    python3 -c "import urllib.parse; print(urllib.parse.unquote('$1'))"
}

# JSON pretty print
json_pretty() {
    echo "$1" | python3 -m json.tool
}

# YAML to JSON
yaml2json() {
    python3 -c "import sys, yaml, json; json.dump(yaml.safe_load(sys.stdin), sys.stdout, indent=2)" < "$1"
}

# JSON to YAML
json2yaml() {
    python3 -c "import sys, yaml, json; yaml.dump(json.load(sys.stdin), sys.stdout)" < "$1"
}

# Generate random data
random_string() {
    cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w "${1:-32}" | head -n 1
}

random_number() {
    shuf -i 1-"${1:-100}" -n 1
}

# Color codes
color_test() {
    for i in {0..255}; do
        printf "\x1b[38;5;${i}mcolour${i}\x1b[0m\n"
    done
}

# Hex to RGB
hex2rgb() {
    printf "%d %d %d\n" 0x${1:0:2} 0x${1:2:2} 0x${1:4:2}
}

# RGB to Hex
rgb2hex() {
    printf "%02x%02x%02x\n" "$1" "$2" "$3"
}

# Calculate
calc() {
    python3 -c "print($*)"
}

# QR code generation (requires qrencode)
qrcode() {
    echo "$1" | qrencode -t UTF8
}

# Get public SSH key
sshkey() {
    cat ~/.ssh/id_rsa.pub 2>/dev/null || cat ~/.ssh/id_ed25519.pub
}

# Copy SSH key to clipboard
sshkey_copy() {
    if command -v pbcopy > /dev/null; then
        cat ~/.ssh/id_rsa.pub 2>/dev/null | pbcopy || cat ~/.ssh/id_ed25519.pub | pbcopy
    elif command -v xclip > /dev/null; then
        cat ~/.ssh/id_rsa.pub 2>/dev/null | xclip -selection clipboard || cat ~/.ssh/id_ed25519.pub | xclip -selection clipboard
    fi
    echo "SSH key copied to clipboard"
}

# Generate SSH key
sshkey_gen() {
    ssh-keygen -t ed25519 -C "${1:-$(whoami)@$(hostname)}"
}

# SSH tunnel
ssh_tunnel() {
    ssh -L "$1":localhost:"$2" "$3"
}

# HTTP status code
http_status() {
    curl -s -o /dev/null -w "%{http_code}" "$1"
}

# Download file
download() {
    curl -O "$1" || wget "$1"
}

# Speed test
speedtest_cli() {
    curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3 -
}
