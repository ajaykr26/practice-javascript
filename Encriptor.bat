@ECHO OFF
title Run Encryptor
set fileSeparator=\
set envDirectory=%~dp0src%fileSeparator%test%FileSeparator%resources%fileSeparator%config%fileSeparator%environments%FileSeparator%
java -cp %CD%\lib\runner\Encryptor.jar;..\lib\* com.naqe.Encryptor %envDirectory%
PAUSE