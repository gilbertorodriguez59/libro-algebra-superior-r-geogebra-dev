@echo off
setlocal EnableExtensions
chcp 65001 >nul
title Algebra Superior con R y GeoGebra - desarrollo
pushd "%~dp0" >nul 2>&1
if errorlevel 1 goto :error

if not exist "_quarto.yml" (
  echo ERROR: Este BAT debe estar junto a _quarto.yml.
  goto :error_carpeta
)
where quarto >nul 2>&1 || (
  echo ERROR: Windows no encuentra Quarto.
  goto :error_carpeta
)

if not exist ".nojekyll" type nul > ".nojekyll"
echo Generando HTML, PDF, figuras e interactivos en docs...
quarto render
if errorlevel 1 goto :error_render
if not exist "docs\index.html" (
  echo ERROR: No se genero docs\index.html.
  goto :error_carpeta
)

echo.
echo Libro generado correctamente.
start "" "docs\index.html"
echo.
choice /C SN /N /M "Deseas subir esta version al repositorio de desarrollo? [S/N]: "
if errorlevel 2 goto :fin

where git >nul 2>&1 || (
  echo ERROR: Windows no encuentra Git.
  goto :error_carpeta
)
git rev-parse --is-inside-work-tree >nul 2>&1 || (
  echo ERROR: Esta carpeta no es un repositorio Git clonado.
  goto :error_carpeta
)
git remote get-url origin | findstr /I /C:"libro-algebra-superior-r-geogebra-dev" >nul || (
  echo ERROR: El remoto origin no corresponde al repositorio de desarrollo esperado.
  git remote -v
  goto :error_carpeta
)

git add .
git diff --cached --quiet
if not errorlevel 1 (
  echo No hay cambios nuevos para subir.
  goto :fin
)
git commit -m "Amplia capitulo 1 con figuras, interactivos y Colab"
if errorlevel 1 goto :error_git
git push origin main
if errorlevel 1 goto :error_git
echo.
echo Publicacion terminada correctamente.
goto :fin

:error_render
echo ERROR: Quarto detuvo la generacion. Revisa las lineas anteriores.
goto :error_carpeta
:error_git
echo ERROR: Git no pudo completar la publicacion. No se borraron archivos.
:error_carpeta
popd >nul 2>&1
:error
pause
exit /b 1
:fin
popd >nul 2>&1
pause
exit /b 0
