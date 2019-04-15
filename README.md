# Infix-to-Postfix-converter-calculator
Written in assembly for Computer Architecture subject in my first year.

i'm running it on MARS 4.5 emulator, can be downloaded here: http://courses.missouristate.edu/kenvollmar/mars/download.htm

Restrictions: 
  -Both calculators:
     ->Only use integers;
     ->The division will only return the integer part.
     
  -InfixToPostfixWithPriorityRules.asm:
     ->IMPORTANT! GIVEN INPUT MUST FINISH WITH A ".", OTHERWISE IT WONT WORK!
     ->Some times when combining parentesis can give a wrong result, for exemple: ((a-b)*(c/d))*e
