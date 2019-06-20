#!/bin/sh

BASEDIR=$(dirname "$0")

ENV="dev"
REF="master"
PAYLOAD='{}'

usage() {
  echo
  echo "Usage: github-deployer [--help] [--owner repo_owner] [--repo repository] [--env environment] [--ref branch] [--token token]"
  echo
  echo "Send a deployment event to trigger the deployment workflow."
  echo
  echo "Optional arguments:"
  echo "  -h, --help      Show this help message and exit"
  echo "  -o, --owner     The repository owner"
  echo "  -r, --repo      The target repository"
  echo "  -e, --env       Name for the target deployment environment. Defaults to 'dev' environment"
  echo "  -f, --ref       The ref to deploy. This can be a branch, tag or SHA. Defaults to 'master' branch"
  echo "  -t, --token     The Github authentication token, if not provided the token will be taken from 'GITHUB_TOKEN' env variable"
  echo "  -p, --payload   The payload object"
  echo
  echo "Example:"
  echo "  github-deployer --owner owner --repo repo --env production --ref master"
}

parse_options() {
  # set -- "$@"
  local ARGN="$#"
  while [ "$ARGN" -ne 0 ]
  do
    case $1 in
      -h|--help) usage
      exit 0
      ;;
      -o|--owner)
      OWNER="$2"
      shift
      shift
      ;;
      -r|--repo)
      REPO="$2"
      shift
      shift
      ;;
      -e|--env)
      ENV="$2"
      shift
      shift
      ;;
      -f|--ref)
      REF="$2"
      shift
      shift
      ;;
      -t|--token)
      TOKEN="$2"
      shift
      shift
      -p|--payload)
      PAYLOAD="$2"
      shift
      shift
      ;;
      ?*)
      echo "Error: Unknown option. $1"
      usage
      exit 0
      ;;
    esac
    ARGN=$((ARGN-1))
  done
}

is_valid_env() {
  local CURR_ENV="$1"
  case "$CURR_ENV" in
    dev|develop|prod|production|stag|staging|test|testing)
    return 0
    ;;
    *)
    return 1
  esac
}

get_env() {
  local CURR_ENV="$1"
  if is_valid_env "$CURR_ENV";
  then
    case "$CURR_ENV" in
      dev) echo "develop"
      ;;
      prod) echo "production"
      ;;
      stag) echo "staging"
      ;;
      test) echo "testing"
      ;;
      *) echo "$CURR_ENV"
    esac
  fi
}

parse_options "$@"

if [ -z "$OWNER" ]; then
  echo "Error: 'Owner' option is required."
  usage
  exit 0
fi

if [ -z "$REPO" ]; then
  echo "Error: 'Repository' option is required."
  usage
  exit 0
fi

GITHUB_TOKEN=${TOKEN:-$GITHUB_TOKEN}

if [ -z "$GITHUB_TOKEN" ]; then
  echo "Error: 'GITHUB_TOKEN' not set."
  usage
  exit 0
fi

is_valid_env "$ENV"
VALID_ENV=$?

if [ $VALID_ENV -eq 1 ]; then
  echo "Error: 'env' value should be one of:"
  echo "  'dev', 'develop', 'prod', 'production', 'stag', 'staging', 'test', 'testing'"
  usage
  exit 0
fi

ENVIRONMENT=$(get_env "$ENV")

GITHUB_API_URL="https://api.github.com"
DEPLOYMENTS_URL="$GITHUB_API_URL/repos/$OWNER/$REPO/deployments"

echo "Create Deployment to $DEPLOYMENTS_URL"
echo
echo "ref         = $REF"
echo "task        = deploy"
echo "environment = $ENVIRONMENT"
echo

curl --silent --show-error --fail \
  -X POST "$DEPLOYMENTS_URL" \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Content-Type: application/json" \
  --retry 3 \
  --data @- <<EOF
{
  "ref": "${REF}",
  "task": "deploy",
  "environment": "${ENVIRONMENT}",
  "description": "Deployment for ${ENVIRONMENT} environemnt",
  "auto_merge": false,
  "required_contexts": [],
  "payload": ${PAYLOAD}
}
EOF
