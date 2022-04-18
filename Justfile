PROJECT_NAME := "LitePing"
PROJECT_CLI := "ping"

alias arc := archive

set dotenv-load := false


@_default: _term-wipe
	just --list


# Archive GoReleaser dist
archive: _term-wipe
	#!/bin/sh
	tag="$(git tag --points-at main)"
	app="{{PROJECT_NAME}}"
	arc="${app}_${tag}"

	# echo "app = '${app}'"
	# echo "tag = '${tag}'"
	# echo "arc = '${arc}'"
	if [ ! -e distro ]; then
		mkdir distro
	fi
	if [ -e dist ]; then
		echo "Move dist -> distro/${arc}"
		mv dist "distro/${arc}"

		# echo "cd distro"
		cd distro

		printf "pwd = "
		pwd

		ls -Alh
	else
		echo "dist directory not found for archiving"
	fi


# Build and install app
build: _term-wipe
	go build -o {{PROJECT_CLI}} ./cmd/{{PROJECT_CLI}}/main.go
	mv {{PROJECT_CLI}} "${GOBIN}/"


# Build distro
distro:
	#!/bin/sh
	goreleaser
	just archive


# Run code
run +args='-udp 8.8.8.8': _term-wipe
	go run ./cmd/ping/ping.go {{args}}


_term-wipe:
	#!/usr/bin/env bash
	set -exo pipefail
	if [[ ${#VISUAL_STUDIO_CODE} -gt 0 ]]; then
		clear
	elif [[ ${KITTY_WINDOW_ID} -gt 0 ]] || [[ ${#TMUX} -gt 0 ]] || [[ "${TERM_PROGRAM}" = 'vscode' ]]; then
		printf '\033c'
	elif [[ "${TERM_PROGRAM}" = 'Apple_Terminal' ]] || [[ "${TERM_PROGRAM}" = 'iTerm.app' ]]; then
		osascript -e 'tell application "System Events" to keystroke "k" using command down'
	elif [[ -x "$(which tput)" ]]; then
		tput reset
	elif [[ -x "$(which tcap)" ]]; then
		tcap rs
	elif [[ -x "$(which reset)" ]]; then
		reset
	else
		clear
	fi

