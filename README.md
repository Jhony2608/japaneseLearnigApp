# 🌸 TFG DAM

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/firebase-ffca28?style=for-the-badge&logo=firebase&logoColor=black)

Aplicación educativa multiplataforma (Android y Windows) orientada al aprendizaje gamificado de la escritura y lectura del idioma japonés desde un nivel inicial (N5). 

Este proyecto constituye el Trabajo de Fin de Grado (TFG) para el ciclo superior de **Desarrollo de Aplicaciones Multiplataforma (DAM)**.

## 🎯 Objetivo del Proyecto

La aplicación busca reducir la barrera de entrada al idioma japonés resolviendo una carencia común en el sector EdTech: la falta de práctica motriz. A diferencia de otras herramientas basadas únicamente en cuestionarios de opción múltiple, este proyecto integra un motor de validación de trazado táctil para enseñar el orden y dirección correctos de los caracteres (*kakijun*).

## ✨ Características Principales (MVP)

* **Autenticación en la nube:** Sistema de registro e inicio de sesión seguro gestionado con Firebase Auth.
* **Aprendizaje Gamificado:** Mapa de niveles interactivo, sistema de puntuación y progreso persistente en tiempo real.
* **Módulo de Escritura Interactiva (Elemento Diferenciador):** Lienzo digital (*Canvas*) con validación algorítmica de trazos por coordenadas para el aprendizaje de los silabarios Hiragana y Katakana.
* **Ejercicios Dinámicos:** Módulos de opción múltiple, traducción inversa y emparejamiento de conceptos.
* **Cross-Platform:** Interfaz fluida y responsiva compilada nativamente tanto para ecosistemas móviles (táctil) como de escritorio (ratón).

## 🛠️ Stack Tecnológico y Arquitectura

* **Frontend:** Flutter (Dart).
* **Backend & Base de Datos:** Firebase (Authentication & Cloud Firestore).
* **Gestión de Estados:** Riverpod.
* **Enrutamiento:** GoRouter.
* **Arquitectura:** Diseño basado en separación de responsabilidades (Clean Architecture / MVC), aislando estrictamente la lógica de negocio de la interfaz de usuario.

## 🚀 Instalación y Despliegue

Sigue estos pasos para ejecutar el proyecto en un entorno local:

1. **Clonar el repositorio:**
   ```bash
   git clone [URL_DE_TU_REPOSITORIO]
   cd [nombre_de_la_carpeta]