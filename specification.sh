#!/bin

set -eu

SOURCE="specification/custom-provider.yaml.m4"

BRANCH=$(git branch | sed -n -e 's/^\* // p')
#[ "$BRANCH" = main ] || { echo this cannot be run on branch main >&2; exit 1; }

VERSION=$(sed -n -e 's/^\s\+version:\s\+// p' "$SOURCE" | head -n1)
#[ "$BRANCH" = "$VERSION" ] || { echo branch name mismatches version >&2; exit 1; }

SCP="specification/internal/custom-provider/$VERSION.json"
SMA="specification/user/managed-application/$VERSION.yaml"

FILEA=$(mktemp)
FILEB=$(mktemp)
cleanup () {
	rm -f "$FILEA" "$FILEB"
}
trap cleanup EXIT

m4 -E -DPREFIX='/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.CustomProviders/resourceProviders/{customrpname}/' "$SOURCE" \
	> "$FILEA"
yq < "$FILEA" > "$FILEB"
cp "$FILEB" "$SCP"
: > "$FILEA"
: > "$FILEB"

m4 -E -DPREFIX='/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Solutions/applications/{resourceName}/custom' -DMP=1 "$SOURCE" \
	> "$FILEA"
cp "$FILEA" "$SMA"
: > "$FILEA"

#git add "$SCP" "$SMA"
#git commit -m 'bump' "$SCP" "$SMA"

exit 0
