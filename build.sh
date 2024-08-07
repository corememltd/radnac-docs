#!/bin

SWAGGER_JSON=$(mktemp)
cleanup () {
	rm -f "$SWAGGER"
}
trap cleanup EXIT

yq < swagger.yaml > "$SWAGGER"

mv "$SWAGGER" assets/swagger.json

git add assets/swagger.json
git commit -m 'swagger' assets/swagger.json

exit 0
