#!/usr/bin/env bash

set -e

# ── ANSI ──
ESC=$'\e'
C_RESET="${ESC}[0m"
C_BOLD="${ESC}[1m"
C_DIM="${ESC}[2m"
C_GREEN="${ESC}[32m"
C_CYAN="${ESC}[36m"
C_YELLOW="${ESC}[33m"
C_RED="${ESC}[31m"
C_BG="${ESC}[44m"

DOTFILES_DIR="$HOME/dotfiles"

echo -e "${C_BOLD}${C_CYAN}Starting dotfiles setup...${C_RESET}"

# ── Check stow ──
if ! command -v stow &> /dev/null; then
    echo -e "${C_RED}GNU Stow is required but not installed.${C_RESET}"
    echo -e "${C_YELLOW}Install it first, e.g.: sudo pacman -S stow${C_RESET}"
    exit 1
fi

# ── Find packages ──
cd "$DOTFILES_DIR"
mapfile -t PACKAGES < <(find . -mindepth 1 -maxdepth 1 -type d ! -name '.git' -printf '%f\n' | sort)

if [ ${#PACKAGES[@]} -eq 0 ]; then
    echo -e "${C_RED}No packages found in $DOTFILES_DIR${C_RESET}"
    exit 0
fi

COUNT=${#PACKAGES[@]}

# ── State ──
declare -a CHECKS
for ((i = 0; i < COUNT; i++)); do CHECKS[$i]=0; done
CUR=0
DRAWN=0

# ── Render ──
draw() {
    if [ "$DRAWN" -eq 1 ]; then
        printf "${ESC}[%dA" $((COUNT + 7))
        printf "${ESC}[J"
    fi
    DRAWN=1

    printf "\n${C_BOLD}${C_CYAN}Dotfiles installer${C_RESET}\n"
    printf "${C_DIM}Select configs to restore:${C_RESET}\n"
    printf "${C_DIM}  ${ESC}[3mUp/Down: move   Space: toggle   a: all   Enter: confirm   q: quit${ESC}[0m${C_RESET}\n"
    printf "\n"

    for ((i = 0; i < COUNT; i++)); do
        local box="[${C_DIM} ${C_RESET}]"
        [ "${CHECKS[$i]}" -eq 1 ] && box="[${C_GREEN}✓${C_RESET}]"

        local marker="  "
        local line="${box} ${C_DIM}${PACKAGES[$i]}${C_RESET}"
        if [ "$i" -eq "$CUR" ]; then
            marker="${C_CYAN}▶${C_RESET}"
            line="${box} ${C_BOLD}${C_CYAN}${PACKAGES[$i]}${C_RESET}"
            printf "  %b %b\n" "$marker" "$line"
        else
            printf "  %b %b\n" "$marker" "$line"
        fi
    done

    printf "\n${C_DIM}Selected: ${C_RESET}"
    local sel=0
    for ((i = 0; i < COUNT; i++)); do
        [ "${CHECKS[$i]}" -eq 1 ] && { sel=1; printf "${C_GREEN}%s${C_RESET} " "${PACKAGES[$i]}"; }
    done
    [ "$sel" -eq 0 ] && printf "${C_DIM}(none)${C_RESET}"
    printf "\n${C_RESET}"
}

# ── Main loop ──
while true; do
    draw
    IFS= read -rsn1 k1
    if [ -z "$k1" ]; then
        break
    elif [ "$k1" = $'\x1b' ]; then
        IFS= read -rsn2 -t 0.1 k2 || k2=''
        case "$k2" in
            '[A') CUR=$(( (CUR - 1 + COUNT) % COUNT )) ;;
            '[B') CUR=$(( (CUR + 1) % COUNT )) ;;
        esac
    elif [ "$k1" = ' ' ]; then
        CHECKS[$CUR]=$((1 - CHECKS[CUR]))
    elif [ "$k1" = 'a' ] || [ "$k1" = 'A' ]; then
        any=0
        for ((i = 0; i < COUNT; i++)); do [ "${CHECKS[$i]}" -eq 1 ] && any=1; done
        for ((i = 0; i < COUNT; i++)); do CHECKS[$i]=$((1 - any)); done
    elif [ "$k1" = 'j' ]; then
        CUR=$(( (CUR + 1) % COUNT ))
    elif [ "$k1" = 'k' ]; then
        CUR=$(( (CUR - 1 + COUNT) % COUNT ))
    elif [ "$k1" = 'q' ] || [ "$k1" = 'Q' ]; then
        echo
        echo -e "${C_YELLOW}Aborted.${C_RESET}"
        exit 0
    fi
done

# ── Collect selection ──
SELECTED=()
for ((i = 0; i < COUNT; i++)); do
    [ "${CHECKS[$i]}" -eq 1 ] && SELECTED+=("${PACKAGES[$i]}")
done

if [ ${#SELECTED[@]} -eq 0 ]; then
    echo
    echo -e "${C_YELLOW}No packages selected. Nothing to do.${C_RESET}"
    exit 0
fi

echo
echo -e "${C_BOLD}Restoring:${C_RESET} ${C_GREEN}${SELECTED[*]}${C_RESET}"
echo

for pkg in "${SELECTED[@]}"; do
    echo -e "${C_CYAN}Stowing ${C_BOLD}$pkg${C_RESET}..."
    stow "$pkg"
done

echo
echo -e "${C_BOLD}${C_GREEN}Done! All selected configurations are successfully stowed.${C_RESET}"
