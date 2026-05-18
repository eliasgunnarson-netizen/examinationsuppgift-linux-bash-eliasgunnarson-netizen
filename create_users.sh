#!/bin/bash

# kolla att scriptet körs som root
if [ "$EUID" -ne 0 ]; then
    echo "Fel: Detta script måste köras som root."
    exit 1
fi

if [ "$#" -eq 0 ]; then
    echo "Användning: $0 användare1 användare2 ..."
    exit 1
fi

# Loop 1 Skapa användare och mappar
for username in "$@"; do
    if id "$username" &>/dev/null; then
        echo "Användaren $username existerar redan, hoppar över."
        continue
    fi

    useradd -m "$username"
    home_dir=$(getent passwd "$username" | cut -d: -f6)

    mkdir -p "$home_dir/Documents" "$home_dir/Downloads" "$home_dir/Work"
    
    chown -R "$username:$username" "$home_dir/Documents" "$home_dir/Downloads" "$home_dir/Work"
    chmod 700 "$home_dir/Documents" "$home_dir/Downloads" "$home_dir/Work"
done

# Loop 2 Skapa välkomstfiler när alla är tillagda
for username in "$@"; do
    # Hoppa över om katalogen inte finns
    home_dir=$(getent passwd "$username" | cut -d: -f6)
    if [ ! -d "$home_dir" ]; then
        continue
    fi
    
    {
        echo "Välkommen $username"
        cut -d: -f1 /etc/passwd | grep -v "^$username$"
    } > "$home_dir/welcome.txt"

    chown "$username:$username" "$home_dir/welcome.txt"
done