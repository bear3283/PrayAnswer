fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios check

```sh
[bundle exec] fastlane ios check
```

버전·빌드 번호와 App Store Connect 연결 상태만 확인 (업로드 없음)

### ios bump_build

```sh
[bundle exec] fastlane ios bump_build
```

빌드 번호를 TestFlight 최신 +1 로 맞춘다

### ios build_only

```sh
[bundle exec] fastlane ios build_only
```

아카이브만 만든다 (업로드 없음). 서명·빌드 문제를 미리 잡기 위한 레인

### ios beta

```sh
[bundle exec] fastlane ios beta
```

빌드해서 TestFlight에 업로드

### ios release

```sh
[bundle exec] fastlane ios release
```

TestFlight에 올라간 현재 빌드를 App Store 심사에 제출 (빌드 업로드 없음)

업데이트 노트는 fastlane/release_notes/<locale>.txt 에서 읽는다

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
