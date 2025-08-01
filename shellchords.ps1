# PowerShell script to calculate diatonic chords and triads

function centerText ($string1) {

    $width1 = $Host.UI.RawUI.WindowSize.Width - 4
    $blankSpaces = $width1/2 - $string1.length/2
    $writeBlanks = " " * $blankSpaces
    Write-Host $writeBlanks $string1 $writeBlanks

}

function centerTextStars ($string2) {

    $width2 = $Host.UI.RawUI.WindowSize.Width - 4
    $stars = $width2/2 - $string2.length/2
    $writeStars = "*" * $stars
    Write-Host "$writeStars $string2 $writeStars*"

}

function title {
    $shellchordsver = "v25.8"

    $width = $Host.UI.RawUI.WindowSize.Width - 1
    $widthHyphens = "-" * $width 
    $widthStars = "*" * $width

    Write-Host "`n$widthStars"
    centerTextStars -string2 "WELCOME TO SHELLCHORDS"
    Write-Host "$widthStars"

    Write-Host "`n$widthHyphens"
    centerText -string1 "1. Choose a root note: C, C#, D, D#, E, F, F#, G, G#, A, A#, B"
    centerText -string1 "2. Choose a scale type: (1) Major, (2) Natural Minor, (3) Harmonic Minor, (4) Melodic Minor"
    centerText -string1 "Enter `"r`" at any time to reset."
    centerText -string1 "Enter `"q`" at any time to quit."
    Write-Host "$widthHyphens`n"
}

function Get-DiatonicChords {
    Param (
        [ValidateSet("C", "C#", "Db", "D", "D#", "Eb", "E", "F", "F#", "Gb", "G", "G#", "Ab", "A", "A#", "Bb", "B")]
        [string]$RootNote,

        [ValidateSet("Major", "Natural Minor", "Harmonic Minor", "Melodic Minor")]
        [string]$ScaleType
    )

    # Define the chromatic scale for reference
    $chromaticScale = @(
        "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"
    )

    # Define the intervals for major and minor scales
    $majorScaleIntervals = @(0, 2, 4, 5, 7, 9, 11) # Whole, whole, half, whole, whole, whole, half
    $naturalminorScaleIntervals = @(0, 2, 3, 5, 7, 8, 10) # Whole, half, whole, whole, half, whole, whole
    $harmonicminorScaleIntervals = @(0, 2, 3, 5, 7, 8, 11) 
    $melodicminorScaleIntervals = @(0, 2, 3, 5, 7, 9, 11) 
    
    

    # Determine the scale intervals based on the ScaleType
    $scaleIntervals = switch ($ScaleType) {
        "Major" { $majorScaleIntervals }
        "Natural Minor" { $naturalminorScaleIntervals }
        "Harmonic Minor" { $harmonicminorScaleIntervals }
        "Melodic Minor" { $melodicminorScaleIntervals }
    }

    # Find the index of the root note in the chromatic scale
    $rootNoteIndex = $chromaticScale.IndexOf($RootNote)

    # Construct the scale notes
    $scaleNotes = @()
    foreach ($interval in $scaleIntervals) {
        $scaleNotes += $chromaticScale[($rootNoteIndex + $interval) % $chromaticScale.Count]
    }

    # Generate the diatonic chords and triads
    $diatonicChords = @()
    for ($i = 0; $i -lt $scaleNotes.Count; $i++) {
        $rootChordNote = $scaleNotes[$i]
        $thirdChordNote = $scaleNotes[($i + 2) % $scaleNotes.Count]
        $fifthChordNote = $scaleNotes[($i + 4) % $scaleNotes.Count]

        $chordNotes = "$rootChordNote, $thirdChordNote, $fifthChordNote"

        # Determine the triad quality
        # A simple method for triads in major keys is:
        # I - Major, ii - minor, iii - minor, IV - Major, V - Major, vi - minor, vii - diminished
        # Reference

        $triadQuality = ""
        if ($ScaleType -eq "Major") {
            switch ($i) {
                0 { $triadQuality = "Major" } # I chord
                1 { $triadQuality = "minor" } # ii chord
                2 { $triadQuality = "minor" } # iii chord
                3 { $triadQuality = "Major" } # IV chord
                4 { $triadQuality = "Major" } # V chord
                5 { $triadQuality = "minor" } # vi chord
                6 { $triadQuality = "diminished" } # vii° chord
            }
        } elseif ($ScaleType -eq "Natural Minor") {
            # For minor keys, the pattern is slightly different (natural minor):
            # i - minor, ii - diminished, III - Major, iv - minor, v - minor (or V - Major for harmonic/melodic), VI - Major, VII - Major
            switch ($i) {
                0 { $triadQuality = "minor" } # i chord
                1 { $triadQuality = "diminished" } # ii° chord
                2 { $triadQuality = "Major" } # III chord
                3 { $triadQuality = "minor" } # iv chord
                4 { $triadQuality = "minor" } # v chord (often major in practice for dominant function)
                5 { $triadQuality = "Major" } # VI chord
                6 { $triadQuality = "Major" } # VII chord
            }
        } elseif ($ScaleType -eq "Harmonic Minor") {
            # For minor keys, the pattern is slightly different (natural minor):
            # i - minor, ii - diminished, III - Major, iv - minor, v - minor (or V - Major for harmonic/melodic), VI - Major, VII - Major
            switch ($i) {
                0 { $triadQuality = "minor" } # i chord
                1 { $triadQuality = "diminished" } # ii° chord
                2 { $triadQuality = "augmented" } # III chord
                3 { $triadQuality = "minor" } # iv chord
                4 { $triadQuality = "Major" } # v chord (often major in practice for dominant function)
                5 { $triadQuality = "Major" } # VI chord
                6 { $triadQuality = "diminished" } # VII chord
            }
        } elseif ($ScaleType -eq "Melodic Minor") {
            # For minor keys, the pattern is slightly different (natural minor):
            # i - minor, ii - diminished, III - Major, iv - minor, v - minor (or V - Major for harmonic/melodic), VI - Major, VII - Major
            switch ($i) {
                0 { $triadQuality = "minor" } # i chord
                1 { $triadQuality = "minor" } # ii° chord
                2 { $triadQuality = "augmented" } # III chord
                3 { $triadQuality = "Major" } # iv chord
                4 { $triadQuality = "Major" } # v chord (often major in practice for dominant function)
                5 { $triadQuality = "diminished" } # VI chord
                6 { $triadQuality = "diminished" } # VII chord
            }
        }
    
        $diatonicChords += [PSCustomObject]@{
            #"Scale Degree" = $i + 1
            "Root Note" = $rootChordNote
            "Triad Type" = $triadQuality
            "Chord Notes" = $chordNotes
        }
    }
    $diatonicChords
}

function getUserRootNote {
    $userRootNote = ""
    while ($userRootNote -eq "") {
        $userRootNote = Read-Host "Choose a root note: C, C#, D, D#, E, F, F#, G, G#, A, A#, B: "
        $userRootNote = $userRootNote.ToUpper()
        if ($userRootNote -in "C","C#","D","D#","E","F","F#","G","G#","A","A#","B") {
            #Write-Host "Root note is good"
        }
        elseif ($userRootNote -like "R") {
            Clear-Host
            title
            $userRootNote = ""
        }
        elseif ($userRootNote -like "Q") {
            Clear-Host
            Write-Host "Exiting Shellchords... Have a great day!"
            exit
        }
        else {
            Write-Host "The input you provided is not valid. Please try again.`n"
            $userRootNote = ""
        }
    }
    $userRootNote
} #end of function

function getUserScaleType {
    $userScaleType = ""
    while ($userScaleType -eq "") {
        $userScaleType = Read-Host "Choose a scale type: (1) Major, (2) Natural Minor, (3) Harmonic Minor, (4) Melodic Minor: "
        $userScaleType = $userScaleType.ToUpper()
        if ($userScaleType -in "1","2","3","4") {
            #Write-Host "User scale is good"
        }
        elseif ($userScaleType -like "R") {
            Clear-Host
            title
            $userScaleType = ""
        }
        elseif ($userScaleType -like "Q") {
            Clear-Host
            Write-Host "Exiting Shellchords... Have a great day!"
            exit
        }
        else {
            Write-Host "The input you provided is not valid. Please try again.`n"
            $userScaleType = ""
        }
    }
    switch ($userScaleType) {
        1 { 
            $ScaleType = "Major"
        }
        2 { 
            $ScaleType = "Natural Minor" 
        }
        3 { 
            $ScaleType = "Harmonic Minor" 
        }
        4 { 
            $ScaleType = "Melodic Minor" 
        }
    }
    $ScaleType
} #end of function

# Main Code
title
while ($true) {
    $userRootNote1 = getUserRootNote
    $ScaleType1 = getUserScaleType
    Write-Host " "
    Write-Host "Diatonic triads in $userRootNote1 $ScaleType1`:"
    Get-DiatonicChords -RootNote $userRootNote1 -ScaleType $ScaleType1 | Out-Host
}
