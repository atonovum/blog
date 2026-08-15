# Blog

Hugo Blog Site

## 배포

`main` 브랜치에 변경 사항을 푸시하면 GitHub Actions가 Hugo 0.146.0으로 사이트를 빌드하고 `atonovum/atonovum.github.io` 저장소에 자동으로 배포합니다. 배포에는 `blog` 저장소의 `ACTIONS_DEPLOY_KEY` 시크릿과 배포 저장소에 등록된 쓰기 가능한 공개 키가 필요합니다.

로컬에서 변경 사항을 확인하려면 저장소 루트에서 `hugo server -D`를 실행합니다.

### 디자인 수정 시 배포 방법

디자인은 `themes/PaperMod` 서브모듈에서 관리합니다. 최초 한 번 테마를 초기화합니다.

```bash
git submodule update --init themes/PaperMod
```

변경 사항을 확인한 뒤 저장소 루트에서 배포 스크립트를 실행합니다.

```bash
scripts/deploy-design.sh --dry-run
scripts/deploy-design.sh
```

스크립트는 다음 순서를 보장합니다.

1. 원격 브랜치를 가져오고 로컬 브랜치가 뒤처지거나 분기되지 않았는지 확인합니다.
2. `themes/PaperMod`의 모든 변경 사항을 커밋하고 테마 저장소에 먼저 푸시합니다.
3. 게시된 테마 커밋만 `blog`의 서브모듈 포인터로 커밋하고 푸시합니다. 이때 블로그 저장소의 다른 변경 사항은 커밋에 포함하지 않습니다.

중간에 인증이나 네트워크 오류가 발생해도 이미 완료된 단계는 다시 만들지 않습니다. 문제를 해결한 뒤 같은 명령을 다시 실행하면 남은 단계부터 이어집니다. `--dry-run`은 원격 가져오기, 스테이징, 커밋, 푸시를 수행하지 않고 예정된 작업만 표시합니다.

커밋 메시지나 원격/브랜치를 바꾸려면 옵션을 지정할 수 있습니다.

```bash
scripts/deploy-design.sh \
  --theme-message "Improve post layout" \
  --blog-message "Update PaperMod theme"
```

전체 옵션은 `scripts/deploy-design.sh --help`에서 확인할 수 있습니다. 기본적으로 두 저장소 모두 `origin/main`을 사용하며, 현재 브랜치도 `main`이어야 합니다. 블로그에 아직 푸시하지 않은 다른 파일의 커밋이 있거나 로컬 브랜치가 원격보다 뒤처졌거나 분기된 경우에는 안전하게 중단합니다. 스크립트는 강제 푸시나 히스토리 재작성을 하지 않습니다.

### 글 수정 시 배포 방법

`content` 아래의 글을 수정한 뒤 `blog` 저장소의 `main` 브랜치에 푸시합니다.

```bash
git add content
git commit -m "Update blog post"
git push origin main
```

메뉴나 사이트 설정도 함께 변경했다면 `hugo.yaml`도 커밋에 포함합니다.
