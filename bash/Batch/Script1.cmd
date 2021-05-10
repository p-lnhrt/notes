@ECHO OFF

SET a=A
SETLOCAL
SET b=B

script2.cmd

ECHO Script1 a: %a%

ENDLOCAL
ECHO Script1 b: %b%

CALL script2.cmd

ECHO ON