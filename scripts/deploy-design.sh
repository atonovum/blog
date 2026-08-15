#!/usr/bin/env bash

set -Eeuo pipefail

command -v git >/dev/null 2>&1 || {
  printf 'Error: git is required\n' >&2
  exit 1
}

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(git -C "${SCRIPT_DIR}/.." rev-parse --show-toplevel)"
readonly THEME_RELATIVE_PATH="themes/PaperMod"
readonly THEME_DIR="${REPO_ROOT}/${THEME_RELATIVE_PATH}"

DRY_RUN=false
THEME_REMOTE="origin"
THEME_BRANCH="main"
BLOG_REMOTE="origin"
BLOG_BRANCH="main"
THEME_MESSAGE="Update PaperMod design"
BLOG_MESSAGE="Update PaperMod theme"
CURRENT_STEP="initial checks"

usage() {
  cat <<'EOF'
Usage: scripts/deploy-design.sh [options]

Commit and push PaperMod changes, then commit and push the blog's submodule
pointer. The operation is ordered and resumable: rerun the same command after
fixing a failed push or other transient error.

Options:
  --dry-run                 Show the planned work without fetching, staging,
                            committing, or pushing
  --theme-message MESSAGE   Theme commit message
                            (default: "Update PaperMod design")
  --blog-message MESSAGE    Blog pointer commit message
                            (default: "Update PaperMod theme")
  --theme-remote NAME       Theme remote (default: origin)
  --theme-branch NAME       Theme branch (default: main)
  --blog-remote NAME        Blog remote (default: origin)
  --blog-branch NAME        Blog branch (default: main)
  -h, --help                Show this help
EOF
}

die() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

log() {
  printf '==> %s\n' "$*"
}

on_error() {
  local exit_code=$?
  printf '\nDeployment stopped during: %s\n' "${CURRENT_STEP}" >&2
  printf 'No history was rewritten. Fix the error and rerun the same command to resume.\n' >&2
  exit "${exit_code}"
}

trap on_error ERR

require_value() {
  local option=$1
  local value=${2-}
  [[ -n "${value}" ]] || die "${option} requires a value"
}

while (($# > 0)); do
  case "$1" in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --theme-message)
      require_value "$1" "${2-}"
      THEME_MESSAGE=$2
      shift 2
      ;;
    --blog-message)
      require_value "$1" "${2-}"
      BLOG_MESSAGE=$2
      shift 2
      ;;
    --theme-remote)
      require_value "$1" "${2-}"
      THEME_REMOTE=$2
      shift 2
      ;;
    --theme-branch)
      require_value "$1" "${2-}"
      THEME_BRANCH=$2
      shift 2
      ;;
    --blog-remote)
      require_value "$1" "${2-}"
      BLOG_REMOTE=$2
      shift 2
      ;;
    --blog-branch)
      require_value "$1" "${2-}"
      BLOG_BRANCH=$2
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "unknown option: $1 (use --help for usage)"
      ;;
  esac
done

[[ -f "${REPO_ROOT}/.gitmodules" ]] || die "${REPO_ROOT} has no .gitmodules file"
[[ "$(git -C "${REPO_ROOT}" config -f .gitmodules --get submodule.${THEME_RELATIVE_PATH}.path || true)" == "${THEME_RELATIVE_PATH}" ]] ||
  die "${THEME_RELATIVE_PATH} is not registered as a submodule"
git -C "${THEME_DIR}" rev-parse --is-inside-work-tree >/dev/null 2>&1 ||
  die "theme submodule is not initialized; run: git submodule update --init ${THEME_RELATIVE_PATH}"

current_branch() {
  local repository=$1
  git -C "${repository}" symbolic-ref --quiet --short HEAD ||
    die "detached HEAD in ${repository}; check out the deployment branch first"
}

require_branch_and_remote() {
  local repository=$1
  local expected_branch=$2
  local remote=$3
  local label=$4
  local actual_branch

  actual_branch=$(current_branch "${repository}")
  [[ "${actual_branch}" == "${expected_branch}" ]] ||
    die "${label} is on branch ${actual_branch}, expected ${expected_branch}"
  git -C "${repository}" remote get-url "${remote}" >/dev/null 2>&1 ||
    die "${label} remote '${remote}' does not exist"
}

remote_ref() {
  local remote=$1
  local branch=$2
  printf 'refs/remotes/%s/%s' "${remote}" "${branch}"
}

require_not_behind() {
  local repository=$1
  local remote=$2
  local branch=$3
  local label=$4
  local tracking_ref
  local ahead
  local behind

  tracking_ref=$(remote_ref "${remote}" "${branch}")
  git -C "${repository}" show-ref --verify --quiet "${tracking_ref}" ||
    die "${label} has no ${remote}/${branch} tracking ref"
  read -r ahead behind < <(
    git -C "${repository}" rev-list --left-right --count "HEAD...${tracking_ref}"
  )
  ((behind == 0)) ||
    die "${label} is behind or diverged from ${remote}/${branch}; reconcile it before deploying"
}

ahead_count() {
  local repository=$1
  local remote=$2
  local branch=$3
  local tracking_ref

  tracking_ref=$(remote_ref "${remote}" "${branch}")
  git -C "${repository}" rev-list --count "${tracking_ref}..HEAD"
}

push_if_ahead() {
  local repository=$1
  local remote=$2
  local branch=$3
  local label=$4
  local ahead

  ahead=$(ahead_count "${repository}" "${remote}" "${branch}")
  if ((ahead == 0)); then
    log "${label}: nothing to push"
    return
  fi

  if [[ "${DRY_RUN}" == true ]]; then
    log "[dry-run] ${label}: would push ${ahead} commit(s) to ${remote}/${branch}"
  else
    CURRENT_STEP="pushing ${label}"
    git -C "${repository}" push "${remote}" "HEAD:refs/heads/${branch}"
  fi
}

require_blog_ahead_is_resumable() {
  local tracking_ref
  local ahead
  local changed_path

  tracking_ref=$(remote_ref "${BLOG_REMOTE}" "${BLOG_BRANCH}")
  ahead=$(ahead_count "${REPO_ROOT}" "${BLOG_REMOTE}" "${BLOG_BRANCH}")
  if ((ahead == 0)); then
    return 0
  fi

  while IFS= read -r changed_path; do
    [[ -z "${changed_path}" || "${changed_path}" == "${THEME_RELATIVE_PATH}" ]] ||
      die "blog has unpublished changes to '${changed_path}'; publish or reconcile them separately before design deployment"
  done < <(
    git -C "${REPO_ROOT}" log -m --format= --name-only "${tracking_ref}..HEAD" |
      sed '/^$/d' |
      sort -u
  )

  log "blog: found ${ahead} unpublished theme-pointer commit(s); will resume their push"
}

require_branch_and_remote "${THEME_DIR}" "${THEME_BRANCH}" "${THEME_REMOTE}" "theme"
require_branch_and_remote "${REPO_ROOT}" "${BLOG_BRANCH}" "${BLOG_REMOTE}" "blog"

if [[ "${DRY_RUN}" == true ]]; then
  log "Dry run: using existing remote-tracking refs (fetch skipped)"
else
  CURRENT_STEP="fetching remote branches"
  git -C "${THEME_DIR}" fetch --prune "${THEME_REMOTE}"
  git -C "${REPO_ROOT}" fetch --prune "${BLOG_REMOTE}"
fi

require_not_behind "${THEME_DIR}" "${THEME_REMOTE}" "${THEME_BRANCH}" "theme"
require_not_behind "${REPO_ROOT}" "${BLOG_REMOTE}" "${BLOG_BRANCH}" "blog"
require_blog_ahead_is_resumable

theme_status=$(git -C "${THEME_DIR}" status --porcelain=v1 --untracked-files=all)
if [[ -n "${theme_status}" ]]; then
  if [[ "${DRY_RUN}" == true ]]; then
    log "[dry-run] theme: would commit all changes with message: ${THEME_MESSAGE}"
    printf '%s\n' "${theme_status}"
  else
    CURRENT_STEP="committing theme changes"
    git -C "${THEME_DIR}" add -A -- .
    git -C "${THEME_DIR}" commit -m "${THEME_MESSAGE}"
  fi
else
  log "theme: no uncommitted changes"
fi

if [[ "${DRY_RUN}" == true && -n "${theme_status}" ]]; then
  log "[dry-run] theme: would push the resulting commit to ${THEME_REMOTE}/${THEME_BRANCH}"
else
  push_if_ahead "${THEME_DIR}" "${THEME_REMOTE}" "${THEME_BRANCH}" "theme"
fi

if [[ "${DRY_RUN}" == false ]]; then
  [[ -z "$(git -C "${THEME_DIR}" status --porcelain=v1 --untracked-files=all)" ]] ||
    die "theme became dirty during commit; refusing to update the blog pointer"
  [[ "$(git -C "${THEME_DIR}" rev-parse HEAD)" == "$(git -C "${THEME_DIR}" rev-parse "$(remote_ref "${THEME_REMOTE}" "${THEME_BRANCH}")")" ]] ||
    die "theme HEAD was not published; refusing to update the blog pointer"
fi

recorded_theme_head=$(git -C "${REPO_ROOT}" rev-parse "HEAD:${THEME_RELATIVE_PATH}")
current_theme_head=$(git -C "${THEME_DIR}" rev-parse HEAD)

blog_pointer_would_change=false
if [[ "${DRY_RUN}" == true && -n "${theme_status}" ]]; then
  log "[dry-run] blog: would commit the resulting theme pointer with message: ${BLOG_MESSAGE}"
  blog_pointer_would_change=true
elif [[ "${recorded_theme_head}" != "${current_theme_head}" ]]; then
  if [[ "${DRY_RUN}" == true ]]; then
    log "[dry-run] blog: would update ${THEME_RELATIVE_PATH} from ${recorded_theme_head:0:12} to ${current_theme_head:0:12}"
    log "[dry-run] blog: would commit with message: ${BLOG_MESSAGE}"
    blog_pointer_would_change=true
  else
    CURRENT_STEP="committing blog submodule pointer"
    git -C "${REPO_ROOT}" add -- "${THEME_RELATIVE_PATH}"
    git -C "${REPO_ROOT}" commit --only -m "${BLOG_MESSAGE}" -- "${THEME_RELATIVE_PATH}"
  fi
else
  log "blog: theme pointer is already current"
fi

if [[ "${DRY_RUN}" == true && "${blog_pointer_would_change}" == true ]]; then
  log "[dry-run] blog: would push the resulting pointer commit to ${BLOG_REMOTE}/${BLOG_BRANCH}"
else
  push_if_ahead "${REPO_ROOT}" "${BLOG_REMOTE}" "${BLOG_BRANCH}" "blog"
fi

if [[ "${DRY_RUN}" == true ]]; then
  log "Dry run complete; repository state was not changed"
else
  log "Design deployment complete"
fi
