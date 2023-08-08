#!/bin/bash

# Command to connect to the database
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Function to fetch element details from the database
get_element_details() {
    local input=$1
    local element_info=""

    # Queries to check atomic_number, symbol, and name
    queries=(
        "SELECT e.atomic_number, e.name, e.symbol,t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius
         FROM elements e
         LEFT JOIN properties p ON e.atomic_number = p.atomic_number
         LEFT JOIN types t ON p.type_id = t.type_id
         WHERE e.atomic_number = '$input';"

        "SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius
         FROM elements e
         LEFT JOIN properties p ON e.atomic_number = p.atomic_number
         LEFT JOIN types t ON p.type_id = t.type_id
         WHERE e.symbol = '$input';"

        "SELECT e.atomic_number, e.name, e.symbol,t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius
         FROM elements e
         LEFT JOIN properties p ON e.atomic_number = p.atomic_number
         LEFT JOIN types t ON p.type_id = t.type_id
         WHERE e.name = '$input';"
    )

    # Loop through queries until an element is found
    for query in "${queries[@]}"; do
        element_info=$($PSQL "$query" 2>/dev/null)
        if [ -n "$element_info" ]; then
            break
        fi
    done

    # Return the element details or an empty string if not found
    echo "$element_info"
}

# Function to display the element details
display_element_details() {
    local element_info=$1

    if [ -z "$element_info" ]; then
        echo "I could not find that element in the database."
    else
        local atomic_number=$(echo "$element_info" | cut -d "|" -f 1)
        local name=$(echo "$element_info" | cut -d "|" -f 2)
        local symbol=$(echo "$element_info" | cut -d "|" -f 3)
        local category=$(echo "$element_info" | cut -d "|" -f 4)
        local atomic_mass=$(echo "$element_info" | cut -d "|" -f 5)
        local melting_point=$(echo "$element_info" | cut -d "|" -f 6)
        local boiling_point=$(echo "$element_info" | cut -d "|" -f 7)

        echo "The element with atomic number $atomic_number is $name ($symbol). It's a $category, with a mass of $atomic_mass amu. $name has a melting point of $melting_point celsius and a boiling point of $boiling_point celsius."
    fi
}

# Check if an argument was provided
if [ -z "$1" ]; then
    echo "Please provide an element as an argument."
else
    # Fetch element details from the database
    element_info=$(get_element_details "$1")

    # Display the element details
    display_element_details "$element_info"
fi
