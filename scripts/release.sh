#!/bin/bash
# ================================================================
# RMC Virtual Lab - GitHub Release 자동 생성 스크립트
# 사용법: bash scripts/release.sh [버전] [릴리즈노트]
# 예시:   bash scripts/release.sh 1.1.0 "버그 수정 및 UI 개선"
# ================================================================

set -e

REPO_OWNER="jaewonny93-glitch"
REPO_NAME="RMC-Virtual-Lab"
PUBSPEC="pubspec.yaml"
CHANGELOG="CHANGELOG.md"

# ── 색상 출력 ──────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

info()    { echo -e "${CYAN}[INFO]${RESET} $1"; }
success() { echo -e "${GREEN}[OK]${RESET}  $1"; }
warn()    { echo -e "${YELLOW}[WARN]${RESET} $1"; }
error()   { echo -e "${RED}[ERR]${RESET}  $1"; exit 1; }

# ── 인자 파싱 ──────────────────────────────────────────────────
NEW_VERSION="${1:-}"
RELEASE_NOTES="${2:-}"

if [ -z "$NEW_VERSION" ]; then
  # pubspec.yaml에서 현재 버전 읽기
  CURRENT=$(grep '^version:' "$PUBSPEC" | head -1 | sed 's/version: *//' | sed 's/+.*//' | tr -d ' ')
  echo -e "${BOLD}현재 버전: v${CURRENT}${RESET}"
  echo -n "새 버전 입력 (예: 1.1.0): "
  read -r NEW_VERSION
fi

if [ -z "$NEW_VERSION" ]; then
  error "버전을 입력하세요."
fi

TAG="v${NEW_VERSION}"

# ── 버전 형식 검증 ─────────────────────────────────────────────
if ! echo "$NEW_VERSION" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'; then
  error "버전 형식이 올바르지 않습니다. (예: 1.2.3)"
fi

# ── CHANGELOG에서 이번 버전 릴리즈 노트 추출 ──────────────────
if [ -z "$RELEASE_NOTES" ] && [ -f "$CHANGELOG" ]; then
  RELEASE_NOTES=$(awk "/^## v${NEW_VERSION}/,/^## v[0-9]/" "$CHANGELOG" \
    | grep -v "^## v[0-9]" | sed '/^$/d' | head -30 | tr '\n' '\n')
fi

if [ -z "$RELEASE_NOTES" ]; then
  RELEASE_NOTES="RMC Virtual Lab v${NEW_VERSION} 릴리즈"
fi

info "릴리즈 준비: ${TAG}"
info "릴리즈 노트: ${RELEASE_NOTES:0:80}..."

# ── pubspec.yaml 버전 업데이트 ────────────────────────────────
CURRENT_BUILD=$(grep '^version:' "$PUBSPEC" | head -1 | sed 's/.*+//' | tr -d ' ')
NEW_BUILD=$((CURRENT_BUILD + 1))
NEW_FULL="${NEW_VERSION}+${NEW_BUILD}"

info "pubspec.yaml 버전 업데이트: ${NEW_FULL}"
# macOS/Linux 호환 sed
if [[ "$OSTYPE" == "darwin"* ]]; then
  sed -i '' "s/^version: .*/version: ${NEW_FULL}/" "$PUBSPEC"
else
  sed -i "s/^version: .*/version: ${NEW_FULL}/" "$PUBSPEC"
fi
success "pubspec.yaml 업데이트 완료"

# ── Git commit & tag ──────────────────────────────────────────
info "변경사항 커밋 중..."
git add "$PUBSPEC" "$CHANGELOG"
git commit -m "chore: bump version to ${NEW_FULL}"
git tag -a "$TAG" -m "Release ${TAG}"
git push origin main
git push origin "$TAG"
success "Git 커밋 및 태그 push 완료: ${TAG}"

# ── GitHub Release 생성 (gh CLI 사용) ────────────────────────
info "GitHub Release 생성 중..."

if command -v gh &> /dev/null; then
  gh release create "$TAG" \
    --title "RMC Virtual Lab ${TAG}" \
    --notes "$RELEASE_NOTES" \
    --repo "${REPO_OWNER}/${REPO_NAME}"
  success "GitHub Release 생성 완료!"
  echo ""
  echo -e "${GREEN}${BOLD}✅ 릴리즈 완료: https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/tag/${TAG}${RESET}"
else
  # gh CLI 없을 때 API 직접 호출
  warn "gh CLI 없음 → GitHub API 직접 호출"
  if [ -z "$GITHUB_TOKEN" ]; then
    error "GITHUB_TOKEN 환경변수를 설정하세요: export GITHUB_TOKEN=ghp_xxxx"
  fi
  PAYLOAD=$(python3 -c "
import json, sys
notes = sys.argv[1]
tag   = sys.argv[2]
print(json.dumps({'tag_name': tag, 'name': 'RMC Virtual Lab ' + tag,
  'body': notes, 'draft': False, 'prerelease': False}))
" "$RELEASE_NOTES" "$TAG")

  RESP=$(curl -s -X POST \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases" \
    -d "$PAYLOAD")

  HTML_URL=$(echo "$RESP" | python3 -c "import sys,json; print(json.load(sys.stdin).get('html_url','ERROR'))")
  if [[ "$HTML_URL" == "ERROR" ]]; then
    error "GitHub Release 생성 실패: $RESP"
  fi
  success "GitHub Release 생성 완료!"
  echo -e "${GREEN}${BOLD}✅ 릴리즈: ${HTML_URL}${RESET}"
fi
