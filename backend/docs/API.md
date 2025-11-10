# 📚 Letterboxd de Alfajores — API Backend

API REST construida con Node.js + Express + MongoDB (TypeScript, ES Modules). A continuación se describen los módulos disponibles, sus endpoints y cómo probarlos manualmente.

## 📘 Autenticación (`/api/auth`)

### `POST /register`
Crea un usuario nuevo.

**Body**
```json
{ "email": "agus@test.com", "password": "123456", "nombreVisible": "Agus" }
```

**Respuesta – 201 Created**
```json
{ "data": { "_id": "...", "email": "agus@test.com", "nombreVisible": "Agus" } }
```

### `POST /login`
Devuelve un token JWT válido por 7 días.

**Body**
```json
{ "email": "agus@test.com", "password": "123456" }
```

**Respuesta**
```json
{ "data": { "user": { "_id": "...", "email": "agus@test.com", "nombreVisible": "Agus" }, "token": "JWT..." } }
```

## 🍫 Alfajores (`/api/alfajores`)

### `GET /`
Lista paginada de alfajores. Filtros opcionales:
```
?q=havanna&type=dulce&pais=argentina&cobertura=chocolate&sort=rating&page=1&limit=10
```

### `GET /:id`
Detalle de un alfajor, incluyendo `promedioPuntuacion` y `totalReseñas`.

### `POST /` _(requiere JWT)_
Crea un nuevo alfajor.

**Body**
```json
{
  "nombre": "Havanna Clásico",
  "marca": "Havanna",
  "pais": "Argentina",
  "tipo": "Dulce de leche",
  "cobertura": "Chocolate con leche",
  "descripcion": "Triple clásico",
  "imagen": "https://..."
}
```

## 📝 Reseñas (`/api/reviews`)

### `GET /alfajor/:alfajorId`
Lista reseñas de un alfajor con datos públicos del usuario (`nombreVisible`, `avatarUrl`). Soporta `?page=1&limit=10`.

### `POST /` _(requiere JWT)_
Crea una reseña.

**Body**
```json
{ "alfajorId": "64...", "puntuacion": 4.5, "texto": "Muy bueno" }
```

### `PUT /:id` _(requiere JWT)_
Edita la reseña propia (campos `puntuacion`, `texto`, `fechaConsumo`).

### `DELETE /:id` _(requiere JWT)_
Elimina la reseña propia. Todos los cambios recalculan automáticamente el promedio y el total de reseñas del alfajor asociado.

## 📊 Estadísticas (`/api/stats`)

### `GET /top-rated?minReviews=5&limit=10`
Ranking global de alfajores mejor puntuados (solo los que superan `minReviews`).

### `GET /most-reviewed?limit=10`
Ranking global de alfajores con más reseñas.

### `GET /me` _(requiere JWT)_
Estadísticas personales del usuario autenticado (`totalReseñas`, `totalAlfajoresDistintos`, `promedioPuntuacionDada`).

## 🧪 Pruebas manuales

Asegurate de tener la API corriendo en `http://localhost:4000` y de haber cargado datos con `npm run seed` (opcional).

### Requests rápidos con `curl`

```bash
# Registrar usuario
curl -X POST http://localhost:4000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email": "agus@test.com", "password": "123456", "nombreVisible": "Agus"}'

# Loguear usuario
curl -X POST http://localhost:4000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "agus@test.com", "password": "123456"}'

# Listar alfajores
curl http://localhost:4000/api/alfajores
```

### Flujo completo sugerido

1. **Registrar usuario** (POST `/api/auth/register`).
2. **Loguear usuario** (POST `/api/auth/login`) y guardar el token JWT.
3. **Crear un alfajor** (POST `/api/alfajores`) usando `Authorization: Bearer <TOKEN>`.
4. **Crear reseña** para ese alfajor (POST `/api/reviews`).
5. **Consultar rankings** (GET `/api/stats/top-rated` o `/api/stats/most-reviewed`).
6. **Ver estadísticas personales** (GET `/api/stats/me` con el mismo JWT).

Cada request puede probarse desde Thunder Client/Postman exportando estos ejemplos o copiando los snippets de `curl` anteriores.
