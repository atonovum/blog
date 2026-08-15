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

테마를 수정하고 `hugo-PaperMod` 저장소에 먼저 푸시합니다.

```bash
cd themes/PaperMod
git add <수정한 파일>
git commit -m "Update theme design"
git push origin main
```

그다음 `blog` 저장소가 참조하는 테마 커밋을 갱신하고 푸시합니다. 테마 저장소만 푸시하면 블로그 배포는 실행되지 않습니다.

```bash
cd ../..
git add themes/PaperMod
git commit -m "Update PaperMod theme"
git push origin main
```

### 글 수정 시 배포 방법

`content` 아래의 글을 수정한 뒤 `blog` 저장소의 `main` 브랜치에 푸시합니다.

```bash
git add content
git commit -m "Update blog post"
git push origin main
```

메뉴나 사이트 설정도 함께 변경했다면 `hugo.yaml`도 커밋에 포함합니다.
