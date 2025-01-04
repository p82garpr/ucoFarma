# UCO Farma

<p align="center"><img src="frontend/uco_farma/assets/images/logo-removebg.png" alt="Logo de UCO Farma" width="400"/></p>

## Descripción
**UCO Farma** es un proyecto universitario desarrollado para la asignatura de **Ingeniería de Sistemas Móviles** de la **Universidad de Córdoba**. Este proyecto consiste en una aplicación móvil diseñada para el **inventariado**, **gestión de medicamentos** y **programación de dosis**.

---

## Tecnologías utilizadas
### 🛠️ Tecnologías
- **Flutter**: Framework para el desarrollo de la interfaz móvil.
- **FastAPI**: Framework para el backend y la gestión de la API.

---

## Características principales
### 🌟 Características
- 📦 **Inventariado de medicamentos.**
- 📋 **Gestión de información relacionada con los medicamentos.**
- ⏰ **Programación y notificaciones para la toma de dosis.**

---

## Instalación y uso

### Backend
Para poner en funcionamiento el backend, sigue estos pasos:

#### Requisitos previos:
- Tener instalado **Python** en versión 3 o superior.
- Disponer de una base de datos **MongoDB**, ya sea en local o en **MongoAtlas** (gratuita).
- Crear un entorno virtual para gestionar las dependencias.
- Tener el paquete **pip** de Python instalado.

#### Pasos de instalación:

1. **Configuración del archivo `.env`**:
   - Edita el archivo `.env.example`, renómbralo como `.env` y escribe tu cadena de conexión para la base de datos MongoDB.

2. **Crear un entorno virtual**:
   Ejecuta el siguiente comando en la carpeta raíz del backend:
   ```bash
   python -m venv nombre_entorno
   ```

3. **Activar el entorno virtual**:
   - En **Windows**:
   ```bash
   ./nombre_entorno/Scripts/activate
   ```
   - En **Linux**:
   ```bash
   source nombre_entorno/bin/activate
   ```

4. **Instalar dependencias**:
   Ejecuta este comando para instalar las dependencias necesarias:
   ```bash
   pip install -r requirements.txt
   ```

5. **Ejecutar el backend**:
   Para iniciar el servidor, utiliza el siguiente comando:
   ```bash
   uvicorn main:app
   ```

---

### Frontend
Para ejecutar el frontend, sigue estos pasos:

#### Requisitos previos:
- Tener el **SDK de Flutter** instalado y configurado.
- Disponer de un emulador o dispositivo físico para pruebas.

#### Pasos de instalación:

1. **Verificar instalación de Flutter**:
   Asegúrate de que el SDK de Flutter está instalado correctamente ejecutando:
   ```bash
   flutter doctor
   ```

2. **Configurar emuladores y simuladores**:
   - **Android**:
     - Instala el SDK de Android y utiliza **Android Studio** para crear un emulador (AVD).
     - Inicia el emulador y verifica su detección con:
     ```bash
     flutter devices
     ```
   - **iOS**: (solo en macOS)
     - Instala **Xcode** y utiliza sus simuladores.
   - **Escritorio** (Linux, macOS o Windows):
     - Activa el soporte de escritorio con:
     ```bash
     flutter config --enable-linux-desktop
     flutter config --enable-macos-desktop
     flutter config --enable-windows-desktop
     ```

3. **Ejecutar en dispositivos físicos**:
   Conecta tu dispositivo físico mediante USB y habilita la depuración USB (Android) o confía en el dispositivo (iOS). Verifica su detección con:
   ```bash
   flutter devices
   ```

4. **Iniciar la aplicación**:
   Usa el siguiente comando para iniciar el frontend:
   ```bash
   flutter run
   ```

#### Depuración:
Durante el desarrollo, puedes utilizar:
- 🔄 **Hot reload**: Presiona `r` en la consola.
- 🔁 **Hot restart**: Presiona `R` para reiniciar.

---

## Autores
### ✍️ Autores
- **Rafael García Pérez**
- **Manuel Cabrera Crespo**
- **Francisco Javier Fernández Pastor**
- **Gabriel Ionuț Roncea**
- **José Manuel García del Prado Valenzuela**

