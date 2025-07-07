import '../../features/auth/domain/entities/user_entity.dart';

enum UserRole {
  admin('admin'),
  moderator('moderator'), 
  user('user'),
  guest('guest');

  const UserRole(this.value);
  final String value;
  
  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'moderator':
        return UserRole.moderator;
      case 'user':
        return UserRole.user;
      default:
        return UserRole.guest;
    }
  }
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
  aiCopilot,
}

class PermissionService {
  static const Map<UserRole, Set<Permission>> _rolePermissions = {
    UserRole.admin: {
      Permission.viewDashboard,
      Permission.viewMaps,
      Permission.createAlerts,
      Permission.editAlerts,
      Permission.deleteAlerts,
      Permission.viewAlerts,
      Permission.viewRoutes,
      Permission.createRoutes,
      Permission.viewStatistics,
      Permission.exportData,
      Permission.manageUsers,
      Permission.systemSettings,
      Permission.viewProfile,
      Permission.editProfile,
      Permission.aiCopilot,
    },
    UserRole.moderator: {
      Permission.viewDashboard,
      Permission.viewMaps,
      Permission.createAlerts,
      Permission.editAlerts,
      Permission.viewAlerts,
      Permission.viewRoutes,
      Permission.createRoutes,
      Permission.viewStatistics,
      Permission.exportData,
      Permission.viewProfile,
      Permission.editProfile,
      Permission.aiCopilot,
    },
    UserRole.user: {
      Permission.viewDashboard,
      Permission.viewMaps,
      Permission.createAlerts,
      Permission.viewAlerts,
      Permission.viewRoutes,
      Permission.createRoutes,
      Permission.viewProfile,
      Permission.editProfile,
      Permission.aiCopilot,
    },
    UserRole.guest: {
      Permission.viewMaps,
      Permission.viewAlerts,
      Permission.viewRoutes,
    },
  };

  static bool hasPermission(UserEntity? user, Permission permission) {
    if (user == null) return _rolePermissions[UserRole.guest]?.contains(permission) ?? false;
    
    final userRole = UserRole.fromString(user.role ?? 'guest');
    return _rolePermissions[userRole]?.contains(permission) ?? false;
  }

  static Set<Permission> getUserPermissions(UserEntity? user) {
    if (user == null) return _rolePermissions[UserRole.guest] ?? {};
    
    final userRole = UserRole.fromString(user.role ?? 'guest');
    return _rolePermissions[userRole] ?? {};
  }

  static UserRole getUserRole(UserEntity? user) {
    if (user == null) return UserRole.guest;
    return UserRole.fromString(user.role ?? 'guest');
  }
}