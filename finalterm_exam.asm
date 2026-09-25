;=========================================================================================================================
; CS66 Final Exam Coding Question
; Description:
;       The program demonstrates two procedures:
;   - CalcGrade:
;           Takes a score (0-100) and returnsa letter grade from A - F in AL.
;   - CalcGradeWithBonus:
;           Take a score and a bonus and adds its to the score and then returns the letter grade for the adjusted score.
;
;
;
;
;
;       Main Program:
;           - initializes the random number generator
;           - runs 10 test cases
;           - for each case:
;                       > Generates a random score between 50 and 100 
;                       > Calls CalcGrade and prints score + the original grade
;                       > Generates a random bonus between 0 and 10
;                       > Calls CalcGradeWithBonus and prints the bonus + adjusted letter grade
;=========================================================================================================================

%include "Along32.inc"

section .data
;-------------------------- Messages for console input=--------------------------------;
msgTitle    db      "Final Term Grade Calculator", 0
msgBreak    db      "================================", 0

msgTestLabel db     "Test #", 0

msgOgScore db       "Original score: ", 0
msgOgLetterGrade db     "Orignial letter grade: ", 0

msgBonusPoints db       "Bonus points: ", 0
msgNewLetterGrade db    "Adjusted grade: ", 0

;------------------------ Program Variables needed for testing--------------------------;

numTests dd     10 ; Number of total test cases
testIndex dd    1  ; 1-10

scoreValue dd   0 ; our random score 50 to 100
bonusValue dd   0 ; random bonus from 0 to 10

letterRaw   db  0 ; letter from CalcGrade
letterBonus db  0 ; new letter from CalcGradeWithBonus

section .text
    global _start
    extern exit


;-------------------------------------------------------------------------------------------------
; _start
;   Entry point
;   Prints header, seeds rng, and loops through the test cases.
;-------------------------------------------------------------------------------------------------

_start:

;------------print title-----------;

mov edx, msgTitle
call WriteString
call Crlf

mov edx, msgBreak
call WriteString
call Crlf
call Crlf

;------------Seed the random num generator once----------------;

call Randomize

; make sure the loop counters are initialized correctly
mov dword [numTests], 10
mov dword [testIndex], 1

MainLoop:
; Stop when numTests reachs 0
cmp dword [numTests], 0
jle AllDone

;-------------Print Test Header--------------------;
; "Test #"
;--------------------------------------------------;

mov edx, msgTestLabel ; EAX = Current test number
call WriteString ; Print number

mov eax, [testIndex]
call WriteDec
call Crlf


;---------Generate Random Scores between 50 and 100---------;
;
;       RandomRange:
;           In: EAX = Range
;           Out: EAX = Random number
;------------------------------------------------------------;

mov eax, 51             ; 51 Possible values between 50 and 100
call RandomRange        ; EAX = 0 - 50
add eax, 50             ; EAX = 50 - 100

mov [scoreValue], eax   ; store the generated scores

; Printing "Original Score : <score>"

mov edx, msgOgScore
call WriteString
mov eax, [scoreValue]
call WriteDec
call Crlf

;--------------------Call CalcGrade------------------------;
;   - Push Score
;   - AL will contain the Letter grade
;----------------------------------------------------------;

push dword [scoreValue]         ; arguement 1 (score)
call CalcGrade                  ; AL = A - F
; CalcGrade Uses 'ret 4' to pop its single arguement

; Save the returned letter so we can print it later
mov [letterRaw], al

; Printing "Original letter grade: <letter grade>"

mov edx, msgOgLetterGrade
call WriteString
mov al, [letterRaw]
call WriteChar
call Crlf


;------------------Generate random amount of bonus points-----------------;
;   chooses between 0 and 10
;-------------------------------------------------------------------------;

mov eax, 11
call RandomRange        ; EAX = 0 - 10
mov [bonusValue], eax

; Printing "Bonus Points: <bonus points>"
mov edx, msgBonusPoints
call WriteString
mov eax, [bonusValue]
call WriteDec
call Crlf



;-----------------------Call CalcGradeWithBonus--------------------------;
;      OgScore + Bonus Points
;
;
;      Stack (top --> bottom) when the call occurs:
;          [ESP]       = Score value
;          [ESP+4]     = bonus value
;
;      Inside the Procedure;
;          [EBP+8]     = Score Value
;          [EBP+12]    = bonus value
;-------------------------------------------------------------------------;

push dword [bonusValue]     ; second parameter
push dword [scoreValue]     ; first parameter
call CalcGradeWithBonus     ; AL = adjusted letter grade

; Printing "Adjusted Grade: <letter>"
mov [letterBonus], al
mov edx, msgNewLetterGrade
call WriteString
mov al, [letterBonus]
call WriteChar
call Crlf
call Crlf

;--------move to the next test-------------------;

inc dword [testIndex]           ; next test number
dec dword [numTests]            ; one fewer test to go (countdown of sorts)
jmp MainLoop

;------------------All Done-------------------------;
; terminates program cleanly
;---------------------------------------------------;
AllDone:
    push 0
    call exit

;=====================================================================================
; CalcGrade Procedure
;
; Purpose: 
;   Convert a numeric score 0 - 100 into a letter grade 
;=====================================================================================

CalcGrade:
    push ebp
    mov ebp, esp
    ; reserve 4 bytes for local storage
    sub esp, 4
    ; save all general-purpose registers
    pushad

    ;----------------Load score into EAX----------------------;
    mov eax, [ebp + 8]          ;EAX = score

    ;-------------Compare against our cutoffs------------------;

    cmp eax, 90
    jge .GotA                   ; score >= 90 --> 'A'

    cmp eax, 80                 
    jge .GotB                   ;  80 - 89 --> 'B'

    cmp eax, 70
    jge .GotC                   ;  70 - 79 --> 'C'

    cmp eax, 60                 
    jge .GotD                   ; 60 - 69 --> 'D'

    ; if we made it here then score < 60 --> 'F'
    
    mov al, 'F'
    jmp .StoreLetter

.GotD:
    mov al, 'D'
    jmp .StoreLetter

.GotC:
    mov al, 'C'
    jmp .StoreLetter

.GotB:
    mov al, 'B'
    jmp .StoreLetter

.GotA:
    mov al, 'A'
    jmp .StoreLetter

.StoreLetter:
    ; Store the letter grade in a local byte before restoring the registers

    mov [ebp - 1], al

    popad

    mov al, [ebp - 1]

    mov esp, ebp
    pop ebp

    ret 4

;==========================================================================================
; CalcGradeWithBonus Procedure
;
; Purpose: 
;   Apply a bonus to our original score, clamp to 100 and then return the new letter grade.
;==========================================================================================

CalcGradeWithBonus:
    push ebp
    mov ebp, esp

    sub esp, 4

    pushad 

    ; load our parameters
    mov eax, [ebp + 8]              ; eax = og score
    mov edx, [ebp + 12]             ; eax = bonus

    ; Add bonus
    add eax, edx                    ; eax = bonus + score

    ; Clamp to 100 if needed
    cmp eax, 100
    jle .NoClamp
    mov eax, 100

.NoClamp:

    ; we can reuse CalcGrade for the final letter grade
    push eax
    call CalcGrade

    mov [ebp - 1], al

    popad
    

    mov al, [ebp - 1]

    mov esp, ebp
    pop ebp

    ret 8

; finally done.



 

