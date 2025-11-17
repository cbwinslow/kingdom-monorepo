# Kingdom Monorepo

[build]
executor = "docker"

[ci]
language = "generic"

[git]
auto_commit = true
auto_push = true

[tools]
node = "20"
python = "3.11"
go = "1.21"

[workspaces]
apps = ["apps/*"]
libs = ["libs/*"]
tools = ["tools/*"]
services = ["services/*"]

[scripts]
bootstrap = "npm install && npm run build --workspaces"
dev = "npm run dev --workspaces"
build = "npm run build --workspaces"
test = "npm run test --workspaces"
lint = "npm run lint --workspaces"