#!/bin/bash

# Kontrollera att scriptet körs som root eftersom useradd 
if [ "$EUID" -ne 0 ]; then
    echo "Fel: Detta script måste köras som root."
    exit 1
fi

# Avsluta om inga användarnamn skickas in som argument
if [ "$#" -eq 0 ]; then
    echo "Användning: $0 användare1 användare2 ..."
    exit 1
fi

# Skapa varje användare som skickas in till scriptet
for username in "$@"; do
    
    # Avbryt och hoppa till nästa om användaren redan existerar
    if id "$username" &>/dev/null; then
        echo "Användaren $username existerar redan, hoppar över."
        continue
    fi

    useradd -m "$username"
    
    home_dir=$(getent passwd "$username" | cut -d: -f6)

    # Skapa de mappar som varje ny användare ska ha i sin hemkatalog
    mkdir -p "$home_dir/Documents" "$home_dir/Downloads" "$home_dir/Work"

    # Sätt ägare och lås rättigheterna så att bara användaren kan läsa och skriva
    chown -R "$username:$username" "$home_dir/Documents" "$home_dir/Downloads" "$home_dir/Work"
    chmod 700 "$home_dir/Documents" "$home_dir/Downloads" "$home_dir/Work"

    # Skapa en personlig välkomstfil och lista andra användare som finns i systemet
    {
        echo "Välkommen $username"
        cut -d: -f1 /etc/passwd | grep -v "^$username$"
    } > "$home_dir/welcome.txt"

    chown "$username:$username" "$home_dir/welcome.txt"
done

