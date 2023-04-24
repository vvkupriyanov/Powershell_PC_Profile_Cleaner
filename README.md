# Powershell_PC_Profile_Cleaner
Cleaning up old domain profiles on a Windows PC.

You need to run the script using the task scheduler.
Triggers for authorization and unlocking of an account.
Action: Start the program.
Program or script: powershell.exe
Arguments: -noprofile -executionpolicy bypass "path to script"

When working, the script creates a csv file, along the path "C:\log\userLog.csv", logging all inputs to the PC.
Accounts not logged in for more than 30 days will be deleted.
