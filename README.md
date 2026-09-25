# Grade Calculator: x86 Assembly (NASM)

CS 66 final exam solution: a 32-bit NASM assembly program that converts numeric
scores into letter grades, including a bonus-point adjustment path. Written for
Linux (System V / cdecl), using the course's Along32 I/O support library.

## What it does

- Seeds the random number generator once at startup.
- Runs 10 test cases. Each one:
  - Generates a random score between 50 and 100.
  - Calls `CalcGrade` and prints the score alongside its letter grade (A-F).
  - Generates a random bonus (0-10 points).
  - Calls `CalcGradeWithBonus` and prints the adjusted letter grade.

## Implementation notes

- **`CalcGrade`** takes a score on the stack, returns a letter grade (A-F)
  in `AL` via a chain of threshold comparisons (`cmp` / `jge`).
- **`CalcGradeWithBonus`** takes a score and a bonus, adds them, clamps the
  total to 100, then re-uses `CalcGrade` on the adjusted value rather than
  duplicating the grading logic.
- Both procedures follow a standard stack-frame pattern (`push ebp` /
  `mov ebp, esp` / `pop ebp`), save all general-purpose registers with
  `pushad`/`popad`, and clean up their own stack arguments on return
  (`ret 4`, `ret 8`).

## Build & run

A fresh Codespace/container likely won't have `nasm` or 32-bit `libc`
installed. Install both first:

```bash
sudo apt-get update && sudo apt-get install -y nasm gcc-multilib
```

Then assemble, link, and run:

```bash
nasm -f elf32 finalterm_exam.asm -o finalterm_exam.o
ld -m elf_i386 --dynamic-linker /lib/ld-linux.so.2 \
   -o finalterm_exam finalterm_exam.o -L. -lAlong32 -lc -L/usr/lib32
LD_LIBRARY_PATH=. ./finalterm_exam
```

(`gcc-multilib` provides the 32-bit `libc` this links against; `ld`
comes from `binutils`, preinstalled on standard Ubuntu Codespace images.)

## Dependencies

`Along32.inc` / `libAlong32.so`: a small NASM I/O support library (console
read/write helpers, RNG) supplied for the course. Along32 is © Curtis Wong,
licensed under the LGPL: http://along32.sourceforge.net

## License

The course-provided material in this repository (template/build setup) is
MIT-licensed by the instructor, see `LICENSE`. The Along32 library itself
is LGPL (see above).
