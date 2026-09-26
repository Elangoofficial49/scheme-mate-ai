#!/usr/bin/env bash
set -euo pipefail

flutter_version="${FLUTTER_VERSION:-3.47.2}"
flutter_root="${HOME}/.cache/flutter-${flutter_version}"

if [[ ! -x "${flutter_root}/bin/flutter" ]]; then
  release_info="$(curl -fsSL https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json \
    | python3 -c 'import json, sys; version = sys.argv[1]; data = json.load(sys.stdin); release = next(item for item in data["releases"] if item["channel"] == "stable" and item["version"] == version); print(release["archive"], release["sha256"])' "${flutter_version}")"
  read -r archive checksum <<< "${release_info}"
  archive_path="$(mktemp --suffix=.tar.xz)"

  curl -fsSL "https://storage.googleapis.com/flutter_infra_release/releases/${archive}" -o "${archive_path}"
  printf '%s  %s\n' "${checksum}" "${archive_path}" | sha256sum --check --status
  mkdir -p "${flutter_root}"
  tar -xJf "${archive_path}" --strip-components=1 -C "${flutter_root}"
  rm -f "${archive_path}"
fi

export PATH="${flutter_root}/bin:${PATH}"
flutter --version

pushd mobile/flutter_app >/dev/null
flutter pub get
flutter build web --release
popd >/dev/null

mkdir -p backend/app/static
cp -a mobile/flutter_app/build/web/. backend/app/static/