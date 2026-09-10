#!/usr/bin/env bash

set -euo pipefail

readonly firefox_root="${HOME}/apps/firefox"
readonly apps_dir="${HOME}/apps"
readonly download_url="https://download.mozilla.org/?product=firefox-latest-ssl&os=linux64&lang=en-US"

for command_name in curl tar mktemp; do
    if ! command -v "$command_name" >/dev/null 2>&1; then
        printf 'Error: required command not found: %s\n' "$command_name" >&2
        exit 1
    fi
done

case "$(uname -m)" in
    x86_64)
        ;;
    *)
        printf 'Error: this installer currently supports x86_64 Linux only.\n' >&2
        exit 1
        ;;
esac

mkdir -p "$apps_dir"
work_dir="$(mktemp -d "${apps_dir}/.firefox-download.XXXXXX")"
archive_path="${work_dir}/firefox.archive"
staged_path="${work_dir}/firefox"
backup_path="${apps_dir}/.firefox-backup.$$"

cleanup() {
    rm -rf "$work_dir"
}
trap cleanup EXIT

printf 'Downloading Firefox from Mozilla...\n'
curl --fail --location --proto '=https' --tlsv1.2 --silent --show-error \
    "$download_url" --output "$archive_path"

printf 'Validating archive...\n'
tar --list --file "$archive_path" >/dev/null

printf 'Installing Firefox to %s...\n' "$firefox_root"
tar --extract --file "$archive_path" --directory "$work_dir"
if [ ! -x "${staged_path}/firefox" ]; then
    printf 'Error: downloaded archive does not contain an executable Firefox binary.\n' >&2
    exit 1
fi

if [[ -e "$firefox_root" ]]; then
    mv "$firefox_root" "$backup_path"
fi

if ! mv "$staged_path" "$firefox_root"; then
    if [[ -e "$backup_path" ]]; then
        mv "$backup_path" "$firefox_root"
    fi
    exit 1
fi

rm -rf "$backup_path"
printf 'Firefox installed successfully.\nRun: %s/firefox\n' "$firefox_root"