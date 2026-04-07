@echo off
title Iniciando Aplicação Haskell Scotty...

:: ====== CONFIGURAÇÕES DO USUÁRIO ======
set APP_DIR=C:\Users\amand\OneDrive\Documentos\GitHub\perso-2025b-mateus250402
set RUN_CMD=cabal run
set APP_PORT=3000

:: ====== NÃO ALTERAR A PARTIR DAQUI ======

echo Acessando diretório da aplicação...
cd /d "%APP_DIR%"

echo Iniciando servidor Scotty...
start cmd /k "%RUN_CMD%"

echo Aguardando o servidor subir...
timeout /t 5 >nul

echo Abrindo navegador no Scotty...
start chrome http://localhost:%APP_PORT%

echo Aplicação rodando. Divirta-se!
exit
