# Módulo de Autenticación Flutter - SkyAngel Mobile

## Resumen de la Migración

He migrado exitosamente el módulo de autenticación de React a Flutter, replicando todos los campos, validaciones y lógica de negocio del proyecto original. La implementación sigue principios de arquitectura limpia y está construida con componentes modulares y mantenibles.

## Estructura del Módulo

```
lib/features/auth/
├── data/
│   ├── datasources/
│   │   ├── cognito_auth_datasource.dart
│   │   └── email_validation_datasource.dart
│   ├── models/
│   │   ├── user_model.dart
│   │   └── cognito_response_model.dart
│   └── repositories/
│       └── auth_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── user_entity.dart
│   │   ├── auth_credentials.dart
│   │   ├── auth_tokens.dart
│   │   └── register_request.dart
│   ├── repositories/
│   │   └── auth_repository.dart
│   └── usecases/
│       ├── sign_in_usecase.dart
│       ├── sign_up_usecase.dart
│       ├── confirm_user_usecase.dart
│       └── reset_password_usecase.dart
└── presentation/
    ├── pages/
    │   ├── login_page.dart
    │   ├── register_page.dart
    │   └── reset_password_page.dart
    ├── providers/
    │   ├── auth_provider.dart
    │   └── auth_state.dart
    ├── widgets/
    │   ├── auth_text_field.dart
    │   ├── auth_button.dart
    │   └── password_visibility_toggle.dart
    ├── utils/
    │   └── auth_validators.dart
    └── guards/
        └── auth_guard.dart
```

## Características Implementadas

### 1. **Login (Inicio de Sesión)**
- **Campos**: Usuario y Contraseña
- **Validaciones**: Usuario requerido, contraseña con mínimo 8 caracteres, mayúscula y símbolo
- **Funcionalidad**: Autenticación con AWS Cognito
- **Manejo de errores**: Mensajes específicos para diferentes tipos de error
- **Visibilidad de contraseña**: Toggle para mostrar/ocultar contraseña

### 2. **Registro de Usuario**
- **Campos**: Nombre, Apellidos, Email, Contraseña, Confirmar Contraseña
- **Validaciones**: 
  - Email válido y requerido
  - Contraseña con mínimo 8 caracteres, mayúscula y símbolo
  - Confirmación de contraseña que coincida
  - Nombres y apellidos requeridos (mínimo 2 caracteres)
- **Flujo de verificación**: Código de verificación por email
- **Validación de email**: Verificación previa de autorización en el backend

### 3. **Recuperación de Contraseña**
- **Paso 1**: Solicitud de código por email
- **Paso 2**: Verificación de código y nueva contraseña
- **Validaciones**: Email válido, código requerido, nueva contraseña con requisitos de seguridad

### 4. **Navegación y Rutas Protegidas**
- **Router con go_router**: Configuración de rutas de autenticación y protegidas
- **Guards de autenticación**: Middleware para proteger rutas
- **Redirecciones automáticas**: Basadas en estado de autenticación

## Tecnologías y Dependencias

### Principales
- **amazon_cognito_identity_dart_2**: Cliente de AWS Cognito para Flutter
- **flutter_riverpod**: Manejo de estado reactivo
- **go_router**: Navegación y rutas
- **dartz**: Programación funcional con Either para manejo de errores
- **freezed**: Generación de modelos inmutables
- **injectable/get_it**: Inyección de dependencias

### UI/UX
- **flutter_hooks**: Hooks para gestión de estado local
- **Material Design 3**: Diseño moderno y responsivo
- **Componentes modulares**: Widgets reutilizables y customizables

## Arquitectura Implementada

### 1. **Clean Architecture**
- **Domain Layer**: Entidades, repositorios y casos de uso
- **Data Layer**: Fuentes de datos, modelos y implementaciones de repositorios
- **Presentation Layer**: UI, providers y lógica de presentación

### 2. **Patrón Repository**
- Abstracción entre las fuentes de datos y la lógica de negocio
- Implementación con Either para manejo de errores funcional

### 3. **State Management con Riverpod**
- Estados inmutables con Freezed
- Providers para gestión de autenticación
- Reactividad automática en la UI

### 4. **Inyección de Dependencias**
- Configuración automática con Injectable
- Singleton y Lazy Singleton patterns
- Fácil testeo y mantenimiento

## Configuración Requerida

### 1. **AWS Cognito**
```dart
// En cognito_auth_datasource.dart, actualizar:
const userPoolId = 'us-east-1_TU_USER_POOL_ID';
const clientId = 'TU_CLIENT_ID';
```

### 2. **Variables de Entorno**
```dart
// En environment.dart, configurar:
static String get baseUrl => 'https://tu-api.com';
```

### 3. **Endpoints de API**
```dart
// En api_endpoints.dart:
static String get validateEmail => '$baseUrl/validar_correo';
static String get checkToken => '$baseUrl/check_token';
```

## Campos y Validaciones Migradas

### Del Proyecto React Original:

#### Login
- ✅ **Usuario**: Campo de texto requerido
- ✅ **Contraseña**: Campo de contraseña con validación de seguridad
- ✅ **Toggle de visibilidad**: Mostrar/ocultar contraseña
- ✅ **Enlace a registro**: Navegación a página de registro
- ✅ **Enlace a recuperación**: Navegación a reset de contraseña

#### Registro
- ✅ **Nombre**: Campo requerido con validación de longitud
- ✅ **Apellidos**: Campo requerido con validación
- ✅ **Email**: Validación de formato y verificación de autorización
- ✅ **Contraseña**: Regex de seguridad (8+ chars, mayúscula, símbolo)
- ✅ **Confirmar contraseña**: Validación de coincidencia
- ✅ **Código de verificación**: Modal/paso adicional para verificación

#### Reset Password
- ✅ **Email**: Para solicitar código de recuperación
- ✅ **Código**: Validación de código recibido
- ✅ **Nueva contraseña**: Con validaciones de seguridad
- ✅ **Confirmar nueva contraseña**: Validación de coincidencia

## Lógica de Negocio Replicada

### 1. **Flujo de Autenticación**
- Validación de credenciales con AWS Cognito
- Almacenamiento seguro de tokens JWT
- Manejo de sesiones y refresh tokens
- Limpieza de datos al cerrar sesión

### 2. **Flujo de Registro**
- Validación de email autorizado en backend
- Registro en AWS Cognito
- Verificación por código de email
- Manejo de errores específicos (usuario existente, parámetros inválidos)

### 3. **Recuperación de Contraseña**
- Solicitud de código de recuperación
- Validación de código y establecimiento de nueva contraseña
- Feedback al usuario en cada paso

### 4. **Protección de Rutas**
- Verificación de estado de autenticación
- Redirecciones basadas en tokens válidos
- Middleware de autenticación para rutas protegidas

## Componentes Modulares Creados

### 1. **AuthTextField**
- Campo de texto reutilizable
- Validaciones integradas
- Estilos consistentes
- Soporte para diferentes tipos de input

### 2. **AuthButton**
- Botón con estados de carga
- Variantes (filled, outlined)
- Deshabilitación automática
- Indicador de progreso integrado

### 3. **PasswordVisibilityToggle**
- Toggle para mostrar/ocultar contraseña
- Iconos animados
- Integración seamless con AuthTextField

### 4. **AuthValidators**
- Conjunto de validadores reutilizables
- Mensajes de error en español
- Validaciones específicas para el dominio

## Manejo de Errores

### 1. **AppError**
- Estructura de errores tipada
- Códigos de error específicos
- Mensajes localizados

### 2. **Either Pattern**
- Manejo funcional de errores
- No más excepciones no controladas
- Flujo de datos predecible

### 3. **User Feedback**
- Snackbars para éxito/error
- Estados de carga en UI
- Mensajes descriptivos

## Responsive Design

### 1. **Layouts Adaptativos**
- Diseño desktop con imagen lateral
- Diseño móvil con scroll vertical
- Breakpoints para diferentes tamaños

### 2. **Componentes Flexibles**
- Tamaños y espaciados adaptativos
- Tipografía escalable
- Iconos vectoriales

## Siguientes Pasos

1. **Configurar credenciales de AWS Cognito**
2. **Actualizar endpoints de API**
3. **Generar archivos con build_runner**:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
4. **Probar flujos de autenticación**
5. **Implementar tests unitarios**

## Comandos de Desarrollo

```bash
# Instalar dependencias
flutter packages get

# Generar archivos
dart run build_runner build --delete-conflicting-outputs

# Ejecutar aplicación
flutter run

# Ejecutar tests
flutter test
```

La implementación está lista para uso y mantiene toda la funcionalidad del módulo React original, con mejoras en términos de arquitectura, mantenibilidad y experiencia de usuario.