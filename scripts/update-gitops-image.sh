#!/bin/bash
set -euo pipefail

: "${GITHUB_TOKEN:?GitHub token is required}"
: "${ECR_REGISTRY:?}"
: "${ECR_REPOSITORY:?}"
: "${IMAGE_TAG:?}"

WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

git clone --quiet --branch main \
  https://github.com/Loky22p/devops-cicd-assignment-Copy.git \
  "$WORKDIR/repo"

cd "$WORKDIR/repo"

sed -i -E \
  "s|^([[:space:]]*image: ).*calculator-app:ci-[0-9]+$|\1${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}|" \
  k8s/deployment.yaml

if git diff --quiet -- k8s/deployment.yaml; then
  echo "GitOps image already up to date."
  exit 0
fi

git config user.name "Jenkins GitOps Bot"
git config user.email "jenkins@localhost"

git add k8s/deployment.yaml
git commit -m "Update calculator image to ${IMAGE_TAG} [gitops skip]"

cat > "$WORKDIR/askpass.sh" <<'ASKPASS'
#!/bin/sh
case "$1" in
  *Username*) printf '%s\n' "Loky22p" ;;
  *Password*) printf '%s\n' "$GITHUB_TOKEN" ;;
esac
ASKPASS

chmod 700 "$WORKDIR/askpass.sh"

GIT_ASKPASS="$WORKDIR/askpass.sh" \
GIT_TERMINAL_PROMPT=0 \
git push origin HEAD:main

echo "GitOps image updated to ${IMAGE_TAG}"
