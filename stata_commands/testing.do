*************************************************************************************************
*									TESTING MY ADO FILES										*
*************************************************************************************************
sysuse auto, clear

*** corr tex testing ***
cap program drop corr_tex
do "https://raw.githubusercontent.com/jaketg97/Jacob-Toner-Gosselin/main/stata_commands/corr_tex.ado"
corr_tex "headroom trunk weight length turn displacement" "C:\Users\jtg3519\Documents\GitHub\Jacob-Toner-Gosselin\stata_commands\corr_text_test.tex" 1.5
