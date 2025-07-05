# Sistema de Menú Unificado - SkyAngel Mobile

## Resumen

Se ha implementado un sistema de menú unificado que centraliza la navegación y adapta las opciones disponibles según el perfil y permisos del usuario. El sistema elimina la duplicación de código y garantiza una experiencia consistente en toda la aplicación.

## Arquitectura del Sistema

### 1. Servicio de Permisos (`PermissionService`)
**Ubicación**: `lib/core/services/permission_service.dart`

Define roles de usuario y permisos:

```dart
enum UserRole {
  admin('admin'),
  moderator('moderator'), 
  user('user'),
  guest('guest');
}

enum Permission {
  viewDashboard,
  viewMaps,
  createAlerts,
  editAlerts,
  deleteAlerts,
  viewAlerts,
  viewRoutes,
  createRoutes,
  viewStatistics,
  exportData,
  manageUsers,
  systemSettings,
  viewProfile,
  editProfile,
}
```

**Funcionalidades clave**:
- `hasPermission(UserEntity? user, Permission permission)`: Verifica si un usuario tiene un permiso específico
- `getUserPermissions(UserEntity? user)`: Obtiene todos los permisos del usuario
- `getUserRole(UserEntity? user)`: Determina el rol del usuario

### 2. Configuración de Menús (`MenuConfig`)
**Ubicación**: `lib/shared/models/menu_item.dart`

Define la estructura de elementos de menú con permisos requeridos:

```dart
class MenuItem {
  final String id;
  final String title;
  final IconData icon;
  final Permission? requiredPermission;
  final int? tabIndex;
  // ...
}
```

**Configuraciones predefinidas**:
- `bottomNavigationItems`: Elementos de la barra de navegación inferior
- `drawerMenuItems`: Elementos del drawer lateral

### 3. Widgets de Menú Unificados
**Ubicación**: `lib/shared/widgets/unified_menu.dart`

#### `UnifiedBottomNavigation`
- Adapta automáticamente los elementos según permisos del usuario
- Mapea índices entre elementos disponibles y navegación real
- Integra con el `NavigationProvider` para gestión de estado

#### `UnifiedDrawer`
- Drawer lateral que se adapta según el rol del usuario
- Muestra iconos específicos por rol en el header
- Filtra opciones según permisos
- Incluye funcionalidades especiales (estadísticas, gestión de usuarios, etc.)

### 4. Provider de Navegación
**Ubicación**: `lib/features/app/presentation/providers/navigation_provider.dart`

Gestiona el estado de navegación de forma centralizada:

```dart
class NavigationState {
  final int currentIndex;
  final List<Widget> availablePages;
  final List<MenuItem> availableMenuItems;
}
```

**Funcionalidades**:
- `setCurrentIndex(int index)`: Actualiza el índice actual
- `navigateToTab(int originalTabIndex)`: Navega a una pestaña específica
- `refreshNavigation()`: Actualiza las páginas disponibles según permisos

## Permisos por Rol

### Admin
- Acceso completo a todas las funcionalidades
- Gestión de usuarios y configuración del sistema
- Exportación de datos y estadísticas avanzadas

### Moderator
- Todas las funciones excepto gestión de usuarios
- Puede editar y crear alertas
- Acceso a estadísticas y exportación

### User
- Funciones básicas: dashboard, mapa, alertas, rutas, perfil
- Puede crear alertas pero no editarlas
- Sin acceso a estadísticas avanzadas

### Guest
- Solo visualización: mapa, alertas, rutas
- Sin capacidad de crear contenido
- Acceso limitado al perfil

## Integración en Páginas

### Actualización de Páginas Existentes

Todas las páginas principales han sido actualizadas para usar el sistema unificado:

```dart
// Antes
drawer: const AppDrawer(),

// Después  
drawer: UnifiedDrawer(),
```

Las páginas afectadas:
- `DashboardPage`
- `MapsPage` 
- `AlertsPage`
- `RoutesPage`

### Refactorización de AppPage

El `AppPage` principal ahora usa el provider de navegación:

```dart
return Scaffold(
  body: ref.watch(currentPageProvider),
  bottomNavigationBar: UnifiedBottomNavigation(
    currentIndex: navigation.currentIndex,
    onTap: (index) => ref.read(navigationProvider.notifier).setCurrentIndex(index),
  ),
);
```

## Ventajas del Sistema

### 1. **Seguridad Mejorada**
- Control granular de acceso basado en roles
- Validación automática de permisos
- Ocultación de funciones no autorizadas

### 2. **Mantenibilidad**
- Código centralizado y reutilizable
- Fácil adición de nuevos permisos o roles
- Consistencia en toda la aplicación

### 3. **Experiencia de Usuario**
- Menús adaptativos según el contexto del usuario
- Navegación intuitiva y coherente
- No exposición de funciones inaccesibles

### 4. **Escalabilidad**
- Sistema modular para agregar nuevas funcionalidades
- Configuración flexible de permisos
- Arquitectura preparada para crecimiento

## Configuración de Desarrollo

### Agregar Nuevo Permiso

1. Añadir el permiso al enum `Permission`
2. Actualizar `_rolePermissions` en `PermissionService`
3. Configurar en `MenuConfig` si es necesario

### Agregar Nuevo Rol

1. Añadir al enum `UserRole`
2. Definir permisos en `_rolePermissions`
3. Actualizar métodos de visualización en `UnifiedDrawer`

### Agregar Nueva Opción de Menú

1. Crear `MenuItem` en `MenuConfig`
2. Implementar manejo en `_handleSpecialActions` si es acción especial
3. Actualizar navegación si es nueva página

## Pruebas y Validación

✅ **Compilación Exitosa**: El proyecto compila sin errores  
✅ **Arquitectura Modular**: Mantiene la estructura Clean Architecture  
✅ **Permisos Funcionales**: Sistema de roles implementado correctamente  
✅ **Navegación Consistente**: Menús unificados en toda la aplicación  
✅ **Estado Centralizado**: Provider de navegación funcionando  

## Archivos Principales

- `lib/core/services/permission_service.dart` - Lógica de permisos
- `lib/shared/models/menu_item.dart` - Modelos y configuración de menús
- `lib/shared/widgets/unified_menu.dart` - Widgets de menú unificados
- `lib/features/app/presentation/providers/navigation_provider.dart` - Gestión de estado
- `lib/features/app/presentation/pages/app_page.dart` - Página principal actualizada

El sistema está completamente implementado y listo para uso en producción.