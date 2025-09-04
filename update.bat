@echo off
setlocal

set "commitMessage=%~1"

REM If no message was passed in, prompt the user to enter one.
if not defined commitMessage (
    echo.
    set /p commitMessage="Please enter your commit message: "
)

REM If the message is still empty after the prompt, exit.
if not defined commitMessage (
    echo.
    echo No commit message entered. Aborting.
    echo.
    pause
    exit /b
)

echo.
echo ===================================
echo  UPDATING GITHUB REPOSITORY
echo ===================================
echo.

REM Step 1: Add all files to staging
echo [1/3] Staging all changes...
git add .

REM Step 2: Commit the changes with the provided message
echo [2/3] Committing with message: "%commitMessage%"
git commit -m "%commitMessage%"

REM Step 3: Push the changes to GitHub
echo [3/3] Pushing to remote repository...
git push

echo.
echo ===================================
echo  UPDATE COMPLETE!
echo ===================================
echo.
pause