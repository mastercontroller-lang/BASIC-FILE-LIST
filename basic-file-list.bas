DECLARE SUB ShowDirectory(path AS STRING)
DECLARE SUB DrawMenu(path AS STRING, dirs() AS STRING, currentDir AS INTEGER)
DECLARE SUB GetDirectories(path AS STRING, dirs() AS STRING)
DECLARE SUB RunExecutable(path AS STRING, isRoot AS INTEGER)

' Main program
DIM AS STRING currentPath = "."
DIM AS STRING dirs(100)
DIM AS INTEGER currentDir = 0
DIM AS INTEGER dirCount = 0
DIM AS INTEGER gameOver = 0

' Show initial directory contents
DO
    ' Get directories
    GetDirectories(currentPath, dirs())

    ' Display current directory and menu
    CLS
    ShowDirectory(currentPath)
    DrawMenu(currentPath, dirs(), currentDir)

    ' Wait for key press and handle it
    key = INKEY$

    ' If user presses ESC, exit the program
    IF key = CHR$(27) THEN ' Escape key to exit
        EXIT
    ' If user presses ENTER, run executable in the selected directory
    ELSEIF key = CHR$(13) AND dirs(currentDir) <> "" THEN ' Enter key to enter directory
        IF currentPath = "." THEN
            currentPath = dirs(currentDir)
        ELSE
            currentPath = currentPath + "\" + dirs(currentDir)
        END IF
        currentDir = 0
    ' If user presses UP Arrow, move the selection up
    ELSEIF key = CHR$(224) + CHR$(72) THEN ' Up Arrow
        IF currentDir > 0 THEN currentDir = currentDir - 1
    ' If user presses DOWN Arrow, move the selection down
    ELSEIF key = CHR$(224) + CHR$(80) THEN ' Down Arrow
        IF currentDir < dirCount - 1 THEN currentDir = currentDir + 1
    ' If user presses F1, run executable as root (on Linux)
    ELSEIF key = CHR$(0) + CHR$(59) THEN ' F1 to run as root (Linux)
        RunExecutable(currentPath, 1)
    ' If user presses F2, run executable without root (on Linux)
    ELSEIF key = CHR$(0) + CHR$(60) THEN ' F2 to run as non-root (Linux)
        RunExecutable(currentPath, 0)
    END IF

LOOP UNTIL key = CHR$(27) ' Escape key to quit

' Sub to get list of directories
SUB GetDirectories(path AS STRING, dirs() AS STRING)
    DIM As INTEGER i = 0
    dirCount = 0
    ' Initialize directory array to blank strings
    FOR i = 0 TO 99
        dirs(i) = ""
    NEXT

    ' Get the list of directories in the current path
    OPEN path + "\*.*" FOR INPUT AS #1
    DO
        LINE INPUT #1, dirs(dirCount)
        IF LEN(dirs(dirCount)) > 0 THEN
            IF (dirs(dirCount) <> "." AND dirs(dirCount) <> "..") AND (LEN(dirs(dirCount)) > 0) THEN
                dirCount = dirCount + 1
            END IF
        END IF
    LOOP UNTIL EOF(1)
    CLOSE #1
END SUB

' Sub to draw the menu with directory listings
SUB DrawMenu(path AS STRING, dirs() AS STRING, currentDir AS INTEGER)
    PRINT "Current Directory: "; path
    PRINT "Use UP and DOWN arrows to navigate, ENTER to select, ESC to quit"
    PRINT "F1: Run executable as root, F2: Run executable without root"
    FOR i = 0 TO dirCount - 1
        LOCATE i + 2, 1
        IF i = currentDir THEN
            PRINT "-> "; dirs(i)
        ELSE
            PRINT "   "; dirs(i)
        END IF
    NEXT
END SUB

' Sub to show current directory
SUB ShowDirectory(path AS STRING)
    PRINT "Listing directories for: "; path
    PRINT ""
END SUB

' Sub to run executable as root or non-root
SUB RunExecutable(path AS STRING, isRoot AS INTEGER)
    DIM As STRING executable
    DIM As STRING command

    ' Ask for the executable to run
    PRINT "Enter the name of the executable to run (e.g., myprogram): ";
    INPUT executable

    ' Prepare the full path of the executable
    executable = path + "\" + executable

    ' Check if the executable exists
    IF LEN(executable) > 0 AND LEN(DIR(executable)) > 0 THEN
        IF isRoot = 1 THEN
            ' Run as root (Linux example: using sudo)
            PRINT "Running as root..."
            command = "sudo " + executable
        ELSE
            ' Run as non-root (Linux or Windows)
            PRINT "Running without root..."
            command = executable
        END IF

        ' Execute the command
        SHELL command
    ELSE
        PRINT "Executable not found: "; executable
    END IF

    ' Wait for the user to press a key before continuing
    PRINT "Press any key to continue."
    INKEY$
END SUB
