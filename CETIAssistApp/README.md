# 🧩 Runbook Técnico — CETIAssistApp

## 1️⃣ Descripción General
**CETIAssistApp** es una aplicación móvil iOS desarrollada en **Swift / SwiftUI** que permite la gestión de asesorías académicas entre alumnos y profesores.  
Su arquitectura combina **MVVM (Model-View-ViewModel)** con **Firebase** (Auth + Firestore) para ofrecer sincronización en tiempo real y autenticación basada en correo institucional.

---

## 2️⃣ Componentes Principales

| Componente | Descripción | Ubicación |
|-------------|--------------|------------|
| **Frontend (SwiftUI)** | Interfaz de usuario declarativa. Maneja vistas dinámicas y binding con los ViewModels. | `/Views` |
| **ViewModels (MVVM)** | Lógica de negocio y comunicación con los servicios. | `/ViewModels` |
| **Modelos de datos** | Representan las entidades de Firestore. | `/Models` |
| **Servicios Firebase** | Encapsulan la comunicación con FirebaseAuth y Firestore. | `/FirebaseManager` |
| **Persistencia remota (Firestore)** | Base de datos NoSQL en tiempo real. | Cloud Firestore |
| **Autenticación (FirebaseAuth)** | Autenticación de usuarios (email/password) con validación de dominio institucional. | Cloud FirebaseAuth |

---

## 3️⃣ Arquitectura General (Nivel alto)

+-----------------------------+
| SwiftUI Views |
| (UI declarativa, Binding) |
+-------------+---------------+
|
▼
+-----------------------------+
| ViewModels (MVVM) |
| Auth, Availability, Calendar|
| Reservation, etc. |
+-------------+---------------+
|
▼
+-----------------------------+
| FirebaseManager & Services|
| - FirebaseAuth |
| - Firestore (CRUD / Queries)|
+-------------+---------------+
|
▼
+-----------------------------+
| Firebase Cloud |
| Auth | Firestore |
| (users, asesorias, reservas)|
+-----------------------------+

---

## 4️⃣ Colecciones Principales en Firestore

| Colección | Campos relevantes | Descripción |
|------------|-------------------|--------------|
| `users` | `uid`, `email`, `role` (student/professor), `displayName` | Perfil del usuario autenticado. |
| `asesorias` / `availability` | `id`, `professorId`, `date`, `startTime`, `modality`, `subject`, `isBooked` | Disponibilidades creadas por profesores. |
| `reservations` | `id`, `studentId`, `availabilityId`, `createdAt` | Reservas realizadas por los alumnos. |

---

## 5️⃣ Flujo de Autenticación

### 🔹 Registro:
1. El usuario completa el formulario de registro.  
2. Se valida el dominio `@ceti.mx`.  
3. Se crea el usuario en FirebaseAuth.  
4. Se genera un documento `users/{uid}` en Firestore con su rol.  
5. Se envía correo de verificación (opcional).  
6. AuthStateListener detecta la sesión y redirige según el rol.

### 🔹 Inicio de Sesión:
1. El usuario ingresa credenciales.  
2. FirebaseAuth verifica.  
3. Se carga el documento `users/{uid}`.  
4. Se guarda `currentUser` en el `AuthViewModel`.  
5. Redirección:
   - Rol `profesor` → `ProfessorHomeView`
   - Rol `alumno` → `StudentHomeView`

---

## 6️⃣ Flujo de Publicación de Disponibilidad (Profesor)

1. Profesor abre `NewAvailabilityView`.  
2. Llena formulario: fecha, hora, modalidad, materia.  
3. `AvailabilityViewModel` valida datos.  
4. Crea documento en Firestore (`asesorias`).  
5. Los `listeners` de `CalendarViewModel` actualizan automáticamente las vistas de alumnos y profesores.

---

## 7️⃣ Flujo de Reserva (Alumno)

1. Alumno abre `CalendarView`.  
2. Selecciona una disponibilidad libre (`isBooked == false`).  
3. `ReservationViewModel` crea documento en `reservations`.  
4. Marca la disponibilidad como `isBooked: true`.  
5. Los `listeners` actualizan en tiempo real ambas vistas.  

---

## 8️⃣ Roles y Permisos

| Rol | Permisos |
|------|-----------|
| **Alumno** | Visualizar asesorías disponibles, reservar, cancelar. |
| **Profesor** | Crear asesorías, actualizar disponibilidad, ver reservas. |
| **Admin (opcional futuro)** | Moderar, crear reportes, gestionar usuarios. |

---

## 9️⃣ Seguridad y Reglas de Firestore

**Reglas recomendadas:**
```js
match /users/{uid} {
  allow read, write: if request.auth.uid == uid;
}
match /asesorias/{id} {
  allow read: if true;
  allow write: if resource.data.professorId == request.auth.uid;
}
match /reservations/{id} {
  allow read, write: if request.auth.uid != null;
}

---

## 🔟 Dependencias Técnicas

| Componente | Función |
|-------------|----------|
| **SwiftUI** | UI declarativa |
| **FirebaseAuth** | Autenticación |
| **FirebaseFirestore** | Base de datos |
| **Combine** | Observadores y bindings reactivos |
| **Xcode 15+** | IDE y compilación |
| **iOS 17 SDK** | Entorno de ejecución objetivo |

---

## 1️⃣1️⃣ Recomendaciones de Mejora

✅ Estandarizar nombre de colecciones (`availability` ↔ `asesorias`).  
✅ Implementar Cloud Function para reservas atómicas.  
✅ Añadir flujo de recuperación de contraseña.  
✅ Añadir verificación de email obligatoria.  
✅ Manejar errores de red / conexión en ViewModels.  
✅ Crear tests unitarios para `AuthViewModel` y `AvailabilityViewModel`.  
✅ Agregar logging estructurado para depuración.

---

## 1️⃣2️⃣ Monitoreo y Mantenimiento

| Tarea | Frecuencia | Herramienta |
|--------|-------------|--------------|
| Revisión de errores Firebase | Semanal | Firebase Console |
| Revisión de autenticaciones fallidas | Diario | Firebase Auth dashboard |
| Limpieza de cuentas huérfanas | Mensual | Cloud Function o script |
| Pruebas de regresión | Antes de cada release | Xcode Unit Tests |

---

## 1️⃣3️⃣ Diagrama Resumen Simplificado (Arquitectura lógica)

Usuarios
│
▼
SwiftUI Views ──────► ViewModels (MVVM)
│ │
▼ ▼
FirebaseManager ───────► Firebase (Auth + Firestore)
│ │
▼ ▼
Listeners realtime Colecciones: users, asesorias, reservations


---

## 1️⃣4️⃣ Contacto y Responsabilidades

| Área | Responsable | Descripción |
|-------|--------------|-------------|
| Arquitectura | Rolando Loza | Diseño y revisión de arquitectura |
| Desarrollo iOS | Samantha Dominguez | Implementación y pruebas |
| Backend Firebase | Rolando Loza | Seguridad y mantenimiento |
| QA / Testing | Mohamed Mendoza | Casos de prueba y validación |
