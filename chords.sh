#!/opt/homebrew/Cellar/bash/5.3.3/bin/bash
s
printWidth () {
    width=$(tput cols)
    i=0
    while [[ i -lt $width ]]
    do
        printf "-"
        ((i++))
    done
    printf "\n"
}

printWidth2 () {
    width=$(tput cols)
    i=0
    while [[ i -lt $width ]]
    do
        printf "="
        ((i++))
    done
    printf "\n"
}

printCenter () {
    width5=$(tput cols)
    stringArg=$@
    stringLen=${#stringArg}
    halfStringLen=$(($stringLen/2))
    width6=$(($width5/2-$halfStringLen-1))
    i=0
    while [[ i -lt $width6 ]]
    do
        printf "="
        ((i++))
    done
    printf " $@ "
    i=0
    while [[ i -lt $width6 ]]
    do
        printf "="
        ((i++))
    done
    printf "\n"
}

printCenter2 () {
    width5=$(tput cols)
    stringArg=$@
    stringLen=${#stringArg}
    halfStringLen=$(($stringLen/2))
    width6=$(($width5/2-$halfStringLen-1))
    i=1
    while [[ i -lt $width6 ]]
    do
        printf " "
        ((i++))
    done
    printf " $@ "
    i=0
    while [[ i -lt $width6 ]]
    do
        printf " "
        ((i++))
    done
    printf "\n"
}

# Define the notes in order (representing semitones from C)
NOTES=("C" "C#" "D" "D#" "E" "F" "F#" "G" "G#" "A" "A#" "B")

# Function to get the index of a note
get_note_index() {
    local note_name=$1
    for i in "${!NOTES[@]}"; do
        if [[ "${NOTES[$i]}" == "${note_name^^}" ]]; then
            echo $i
            return
        fi
    done
    echo "-1"
}

# Function to get the note name from its index
get_note_name() {
    local index=$1
    echo "${NOTES[$index]}"
}

# Function to get a scale (major or natural/harmonic/melodic minor) for a given root note
get_scale() {
    local root_note=$1
    local scale_type=$2
    local root_index=$(get_note_index "$root_note")
    if [[ "$root_index" -eq -1 ]]; then
        echo "Invalid root note: $root_note" >&2
        return
    fi

    local scale_pattern=()
    case "${scale_type,,}" in
        "major")
            scale_pattern=(0 2 4 5 7 9 11) # Major scale intervals
            ;;
        "natural minor")
            scale_pattern=(0 2 3 5 7 8 10) # Natural minor scale intervals
            ;;
        "harmonic minor")
            scale_pattern=(0 2 3 5 7 8 11) # Harmonic minor scale intervals (raised 7th)
            ;;
        "melodic minor") 
            # Ascending melodic minor, according to {Link: Skoove and Signaturesound https://emmablairpiano.com/major-minor-scales/} it's the same as natural minor when descending
            scale_pattern=(0 2 3 5 7 9 11) # Melodic minor scale intervals (raised 6th and 7th)
            ;;
        *)
            echo "Invalid scale type: ${scale_type}. Must be 'major', 'natural minor', 'harmonic minor', or 'melodic minor'." >&2
            return
            ;;
    esac

    local scale_notes=()
    for interval in "${scale_pattern[@]}"; do
        local note_index=$(( (root_index + interval) % 12 ))
        scale_notes+=("$(get_note_name "$note_index")")
    done
    echo "${scale_notes[@]}"
}

# Function to list the diatonic chords (triads) in a major or minor key
list_chords_in_key() {
    local key_note=$1
    local scale_type=$2
    local scale_notes=($(get_scale "$key_note" "$scale_type"))

    if [[ -z "$scale_notes" ]]; then
        return
    fi

    echo -e "\nDiatonic triads in ${key_note^^} ${scale_type^^}:"

    local chord_qualities=()
    case "${scale_type,,}" in
        "major")
            chord_qualities=("major" "minor" "minor" "major" "major" "minor" "diminished")
            ;;
        "natural minor")
            chord_qualities=("minor" "diminished" "major" "minor" "minor" "major" "major")
            ;;
        "harmonic minor")
            chord_qualities=("minor" "diminished" "augmented" "minor" "major" "major" "diminished")
            ;;
        "melodic minor") 
            # Ascending melodic minor chord qualities
            chord_qualities=("minor" "minor" "augmented" "major" "major" "diminished" "diminished")
            ;;
    esac

    local num_notes=${#scale_notes[@]}

    for i in "${!scale_notes[@]}"; do
        local root_of_chord="${scale_notes[$i]}"
        local chord_quality="${chord_qualities[$i]}"

        # Calculate the third and fifth notes of the triad
        local third_index=$(( (i + 2) % num_notes ))
        local fifth_index=$(( (i + 4) % num_notes ))
        
        local third_note=${scale_notes[$third_index]}
        local fifth_note=${scale_notes[$fifth_index]}

        # Output in the desired format: Chord Name Quality (Root,Third,Fifth)
        printf "%s %-10s (%s,%s,%s)\\n" "${root_of_chord}" "${chord_quality}" "${root_of_chord}" "${third_note}" "${fifth_note}"
    done
}

title () {
    printf "\n"
    printWidth2
    printCenter "WELCOME TO *CHORDS"
    printWidth2

    printf "\n"
    printWidth
    printCenter2 "1. Choose a root note: C, C#, D, D#, E, F, F#, G, G#, A, A#, B"
    printCenter2 "2. Choose a scale type: (1) Major, (2) Natural Minor, (3) Harmonic Minor, (4) Melodic Minor"
    printCenter2 "Enter \"q\" at any time to quit"
    printWidth
}

# Main code section
clear
title

# Prompt the user for the root note and scale type
while true; do
    echo ""
    read -p "Choose a root note: C, C#, D, D#, E, F, F#, G, G#, A, A#, B: " user_root_note

    if [[ "${user_root_note,,}" == "q" ]]; then
        clear
        echo "Exiting Chords... Have a great day!"
        break
    elif [[ "${user_root_note,,}" == "r" ]]; then
        echo "Resetting..."
	clear
        title   
	continue
    elif [[ -z "$user_root_note" ]]; then
        echo "Key cannot be empty. Please try again." >&2
        continue
    fi

    read -p "Choose a scale type: (1) Major, (2) Natural Minor, (3) Harmonic Minor, (4) Melodic Minor: " user_scale_type_number
    goodFlag=1
    
    if [[ "${user_scale_type_number,,}" == "q" ]]; then
        clear
        echo "Exiting Chords... Have a great day!"
        break
    elif [[ "${user_scale_type_number,,}" == "r" ]]; then
        echo "Resetting..."
        clear
        title
        continue
    elif [[ -z "$user_scale_type_number" ]]; then
        echo "Key cannot be empty. Please try again." >&2
        continue
    fi

    case "$user_scale_type_number" in
      "1")
            user_scale_type="major"
            ;;
        "2")
            user_scale_type="natural minor"
            ;;
        "3")
            user_scale_type="harmonic minor"
            ;;
        "4")
            user_scale_type="melodic minor"
            ;;
        *)
            echo "Invalid scale type: $user_scale_type_number"
            goodFlag=0
            ;;
    esac

    # Call the function to list the chords
    if [ "$goodFlag" -eq 1 ]; then
        list_chords_in_key "$user_root_note" "$user_scale_type"
    fi
done
