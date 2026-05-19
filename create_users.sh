#!/bin/bash

# Del 1: Kontrollera att scriptet körs som root
if [ "$EUID" -ne 0 ]; then 
    echo "Fel: Detta script måste köras som root."
    exit 1
fi

# Kontrollera att minst en användare har angetts
if [ "$#" -eq 0 ]; then
    echo "Användning: $0 användare1 användare2 ..."
    exit 1
fi

# Del 2: Skapa användare och mappar
for username in "$@"; do
    if id "$username" &>/dev/null; then
        echo "Användaren $username existerar redan, hoppar över."
        continue
    fi

    # Skapa användare med home directory
    useradd -m "$username"
    home_dir=$(getent passwd "$username" | cut -d: -f6) # Hämtar användarens hemkatalog

# Del 3: Skapa mappar i home directory
    
    mkdir -p "$home_dir/Documents" "$home_dir/Downloads" "$home_dir/Work"
    
    # Sätt ägare och rättigheter på mapparna
    chown -R "$username:$username" "$home_dir/Documents" "$home_dir/Downloads" "$home_dir/Work"
    chmod 700 "$home_dir/Documents" "$home_dir/Downloads" "$home_dir/Work"
done


# Del 4: Skapa välkomstfiler när alla är tillagda
for username in "$@"; do

    # Hoppa över om katalogen inte finns
    home_dir=$(getent passwd "$username" | cut -d: -f6)
    if [ ! -d "$home_dir" ]; then
        continue
    fi
    
    # Skapa välkomstfil med användarens namn och lista på alla andra användare
    {
        echo "Välkommen $username"
        cut -d: -f1 /etc/passwd | grep -v "^$username$" # Hämtar alla användare utom den nuvarande användaren
    } > "$home_dir/welcome.txt"

    chown "$username:$username" "$home_dir/welcome.txt" # Sätter ägare på välkomstfilen
done