# DISEÑO DE SOLUCIÓN FRONTEND - SKYANGEL v2.0

## RESUMEN EJECUTIVO

Este documento presenta el diseño de solución completo para los frontends de la plataforma SkyAngel, incluyendo la aplicación web moderna y la aplicación móvil nativa. El diseño está alineado con las mejores prácticas de la industria, patrones modernos de desarrollo y optimizado para performance, escalabilidad y experiencia de usuario.

### Contexto del Proyecto
- **Plataforma**: Sistema integral de seguridad y análisis de riesgos para transporte
- **Usuarios**: Transportistas, empresas de logística, administradores
- **Funcionalidades principales**: Mapas interactivos, alertas en tiempo real, análisis de rutas, estadísticas delictivas
- **Requisitos especiales**: Funcionalidad offline, GPS continuo, optimización de recursos

## 1. ARQUITECTURA FRONTEND GENERAL

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           SKYANGEL FRONTEND ECOSYSTEM                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐  │
│  │                        PRESENTATION LAYER                            │  │
│  │                                                                     │  │
│  │  ┌──────────────────┐           ┌──────────────────┐              │  │
│  │  │   Web Frontend   │           │  Mobile Frontend │              │  │
│  │  │                  │           │                  │              │  │
│  │  │  ┌─────────────┐ │           │  ┌─────────────┐ │              │  │
│  │  │  │   Next.js   │ │           │  │   Flutter   │ │              │  │
│  │  │  │   React     │ │           │  │    Dart     │ │              │  │
│  │  │  │TypeScript   │ │           │  │ Material 3  │ │              │  │
│  │  │  │Redux Toolkit│ │           │  │  Riverpod   │ │              │  │
│  │  │  │TailwindCSS  │ │           │  │    Dio      │ │              │  │
│  │  │  └─────────────┘ │           │  └─────────────┘ │              │  │
│  │  └──────────────────┘           └──────────────────┘              │  │
│  └─────────────────────────────────────────────────────────────────────┘  │
│                                    │                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐  │
│  │                          SHARED LAYER                                │  │
│  │                                                                     │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌────────────┐ │  │
│  │  │ Design      │  │ Components  │  │ Utilities   │  │ Types      │ │  │
│  │  │ System      │  │ Library     │  │ & Helpers   │  │ & Models   │ │  │
│  │  │ (Figma)     │  │ (Shared)    │  │ (Common)    │  │ (Shared)   │ │  │
│  │  └─────────────┘  └─────────────┘  └─────────────┘  └────────────┘ │  │
│  └─────────────────────────────────────────────────────────────────────┘  │
│                                    │                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐  │
│  │                       API COMMUNICATION                              │  │
│  │                                                                     │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌────────────┐ │  │
│  │  │ HTTP        │  │ WebSocket   │  │ GraphQL     │  │ Offline    │ │  │
│  │  │ Clients     │  │ Clients     │  │ Clients     │  │ Storage    │ │  │
│  │  │ (Axios/Dio) │  │ (Socket.IO) │  │ (Apollo)    │  │ (SQLite)   │ │  │
│  │  └─────────────┘  └─────────────┘  └─────────────┘  └────────────┘ │  │
│  └─────────────────────────────────────────────────────────────────────┘  │
│                                    │                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐  │
│  │                         BACKEND SERVICES                             │  │
│  │                                                                     │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌────────────┐ │  │
│  │  │ Auth        │  │ Maps        │  │ Alerts      │  │ Analytics  │ │  │
│  │  │ Service     │  │ Service     │  │ Service     │  │ Service    │ │  │
│  │  └─────────────┘  └─────────────┘  └─────────────┘  └────────────┘ │  │
│  └─────────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────┘
```

## 2. APLICACIÓN WEB (NEXT.JS)

### 2.1 Arquitectura Técnica

#### **Stack Tecnológico**
```yaml
Core Framework:
  - Next.js 14+ (App Router)
  - React 18+ (Server Components)
  - TypeScript 5+
  - Node.js 20+

Estado y Datos:
  - Redux Toolkit 2.0+
  - RTK Query
  - Zustand (estado local)
  - React Hook Form 7+

Estilos y UI:
  - Tailwind CSS 3.4+
  - Headless UI 2.0+
  - Framer Motion 11+
  - Lucide React (iconos)

Mapas y Geo:
  - Leaflet 1.9+
  - React Leaflet 4+
  - Mapbox GL JS 3+
  - D3.js 7+ (visualizaciones)

Testing:
  - Vitest
  - React Testing Library
  - Playwright (E2E)
  - MSW (mocking)

Build y Deploy:
  - Vite (development)
  - Turbopack (production)
  - Docker
  - Vercel/AWS
```

#### **Estructura de Directorios**
```
sky-frontend-web/
├── app/                      # App Router (Next.js 14)
│   ├── (auth)/              # Auth group
│   │   ├── login/
│   │   ├── register/
│   │   └── layout.tsx
│   ├── (dashboard)/         # Dashboard group
│   │   ├── maps/
│   │   ├── routes/
│   │   ├── alerts/
│   │   ├── analytics/
│   │   └── layout.tsx
│   ├── api/                 # API routes
│   ├── globals.css
│   ├── layout.tsx
│   └── page.tsx
├── components/              # Reusable components
│   ├── ui/                  # Base UI components
│   │   ├── button/
│   │   ├── input/
│   │   ├── modal/
│   │   └── index.ts
│   ├── maps/               # Map components
│   │   ├── BaseMap/
│   │   ├── RouteMap/
│   │   ├── AlertMap/
│   │   └── index.ts
│   ├── charts/             # Chart components
│   │   ├── BarChart/
│   │   ├── LineChart/
│   │   └── index.ts
│   └── forms/              # Form components
├── lib/                    # Utilities and configurations
│   ├── api/                # API clients
│   ├── auth/               # Authentication
│   ├── store/              # Redux store
│   ├── utils/              # Utility functions
│   └── constants/          # Constants
├── hooks/                  # Custom hooks
├── types/                  # TypeScript types
├── styles/                 # Global styles
└── public/                 # Static assets
```

### 2.2 Arquitectura de Componentes

#### **Componentes Base (Design System)**
```typescript
// components/ui/Button/Button.tsx
import { forwardRef } from 'react'
import { cva, type VariantProps } from 'class-variance-authority'
import { cn } from '@/lib/utils'

const buttonVariants = cva(
  'inline-flex items-center justify-center whitespace-nowrap rounded-md text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring disabled:pointer-events-none disabled:opacity-50',
  {
    variants: {
      variant: {
        default: 'bg-primary text-primary-foreground shadow hover:bg-primary/90',
        destructive: 'bg-destructive text-destructive-foreground shadow-sm hover:bg-destructive/90',
        outline: 'border border-input bg-background shadow-sm hover:bg-accent hover:text-accent-foreground',
        secondary: 'bg-secondary text-secondary-foreground shadow-sm hover:bg-secondary/80',
        ghost: 'hover:bg-accent hover:text-accent-foreground',
        link: 'text-primary underline-offset-4 hover:underline',
      },
      size: {
        default: 'h-9 px-4 py-2',
        sm: 'h-8 rounded-md px-3 text-xs',
        lg: 'h-10 rounded-md px-8',
        icon: 'h-9 w-9',
      },
    },
    defaultVariants: {
      variant: 'default',
      size: 'default',
    },
  }
)

export interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {
  asChild?: boolean
}

const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant, size, asChild = false, ...props }, ref) => {
    return (
      <button
        className={cn(buttonVariants({ variant, size, className }))}
        ref={ref}
        {...props}
      />
    )
  }
)
Button.displayName = 'Button'

export { Button, buttonVariants }
```

#### **Componentes de Mapas**
```typescript
// components/maps/BaseMap/BaseMap.tsx
'use client'

import dynamic from 'next/dynamic'
import { memo, useCallback } from 'react'
import { MapContainer, TileLayer, useMap } from 'react-leaflet'
import { useAppSelector, useAppDispatch } from '@/lib/store/hooks'
import { setMapCenter, setMapZoom } from '@/lib/store/slices/mapSlice'
import type { LatLng, LeafletMouseEvent } from 'leaflet'

const MapEvents = dynamic(() => import('./MapEvents'), { ssr: false })

interface BaseMapProps {
  className?: string
  center?: LatLng
  zoom?: number
  onMapClick?: (event: LeafletMouseEvent) => void
  children?: React.ReactNode
}

const BaseMap = memo(({ 
  className = 'h-full w-full',
  center,
  zoom,
  onMapClick,
  children 
}: BaseMapProps) => {
  const dispatch = useAppDispatch()
  const { center: storeCenter, zoom: storeZoom } = useAppSelector(state => state.map)

  const handleMapMove = useCallback((center: LatLng, zoom: number) => {
    dispatch(setMapCenter(center))
    dispatch(setMapZoom(zoom))
  }, [dispatch])

  return (
    <MapContainer
      center={center || storeCenter}
      zoom={zoom || storeZoom}
      className={className}
      attributionControl={false}
      zoomControl={false}
    >
      <TileLayer
        url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
        attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
      />
      
      <MapEvents 
        onMapMove={handleMapMove}
        onMapClick={onMapClick}
      />
      
      {children}
    </MapContainer>
  )
})

BaseMap.displayName = 'BaseMap'

export default BaseMap
```

#### **Gestión de Estado (Redux Toolkit)**
```typescript
// lib/store/slices/mapSlice.ts
import { createSlice, PayloadAction } from '@reduxjs/toolkit'
import type { LatLng } from 'leaflet'

interface MapState {
  center: LatLng
  zoom: number
  selectedLayers: string[]
  alerts: Alert[]
  routes: Route[]
  isLoading: boolean
  error: string | null
}

const initialState: MapState = {
  center: [19.4326, -99.1332], // Ciudad de México
  zoom: 10,
  selectedLayers: ['alerts', 'routes'],
  alerts: [],
  routes: [],
  isLoading: false,
  error: null
}

const mapSlice = createSlice({
  name: 'map',
  initialState,
  reducers: {
    setMapCenter: (state, action: PayloadAction<LatLng>) => {
      state.center = action.payload
    },
    setMapZoom: (state, action: PayloadAction<number>) => {
      state.zoom = action.payload
    },
    toggleLayer: (state, action: PayloadAction<string>) => {
      const layer = action.payload
      const index = state.selectedLayers.indexOf(layer)
      if (index > -1) {
        state.selectedLayers.splice(index, 1)
      } else {
        state.selectedLayers.push(layer)
      }
    },
    setAlerts: (state, action: PayloadAction<Alert[]>) => {
      state.alerts = action.payload
    },
    addAlert: (state, action: PayloadAction<Alert>) => {
      state.alerts.push(action.payload)
    },
    setLoading: (state, action: PayloadAction<boolean>) => {
      state.isLoading = action.payload
    },
    setError: (state, action: PayloadAction<string | null>) => {
      state.error = action.payload
    }
  }
})

export const {
  setMapCenter,
  setMapZoom,
  toggleLayer,
  setAlerts,
  addAlert,
  setLoading,
  setError
} = mapSlice.actions

export default mapSlice.reducer
```

#### **API Layer (RTK Query)**
```typescript
// lib/api/alertsApi.ts
import { createApi, fetchBaseQuery } from '@reduxjs/toolkit/query/react'
import type { Alert, CreateAlertRequest } from '@/types/alerts'

export const alertsApi = createApi({
  reducerPath: 'alertsApi',
  baseQuery: fetchBaseQuery({
    baseUrl: '/api/alerts',
    prepareHeaders: (headers, { getState }) => {
      const token = (getState() as RootState).auth.token
      if (token) {
        headers.set('authorization', `Bearer ${token}`)
      }
      return headers
    },
  }),
  tagTypes: ['Alert'],
  endpoints: (builder) => ({
    getAlerts: builder.query<Alert[], { bounds?: string; limit?: number }>({
      query: (params) => ({
        url: '',
        params,
      }),
      providesTags: ['Alert'],
    }),
    createAlert: builder.mutation<Alert, CreateAlertRequest>({
      query: (alert) => ({
        url: '',
        method: 'POST',
        body: alert,
      }),
      invalidatesTags: ['Alert'],
    }),
    updateAlert: builder.mutation<Alert, { id: string; updates: Partial<Alert> }>({
      query: ({ id, updates }) => ({
        url: `/${id}`,
        method: 'PUT',
        body: updates,
      }),
      invalidatesTags: ['Alert'],
    }),
    deleteAlert: builder.mutation<void, string>({
      query: (id) => ({
        url: `/${id}`,
        method: 'DELETE',
      }),
      invalidatesTags: ['Alert'],
    }),
  }),
})

export const {
  useGetAlertsQuery,
  useCreateAlertMutation,
  useUpdateAlertMutation,
  useDeleteAlertMutation,
} = alertsApi
```

### 2.3 Funcionalidades Específicas

#### **Sistema de Alertas en Tiempo Real**
```typescript
// hooks/useRealtimeAlerts.ts
import { useEffect } from 'react'
import { useAppDispatch } from '@/lib/store/hooks'
import { addAlert } from '@/lib/store/slices/mapSlice'
import { toast } from 'sonner'
import { io, Socket } from 'socket.io-client'

export const useRealtimeAlerts = () => {
  const dispatch = useAppDispatch()

  useEffect(() => {
    const socket: Socket = io(process.env.NEXT_PUBLIC_WEBSOCKET_URL!, {
      auth: {
        token: localStorage.getItem('token')
      }
    })

    socket.on('new-alert', (alert) => {
      dispatch(addAlert(alert))
      toast.success('Nueva alerta recibida', {
        description: `${alert.type} - ${alert.location}`,
        action: {
          label: 'Ver',
          onClick: () => {
            // Navigate to alert location
          }
        }
      })
    })

    socket.on('alert-updated', (alert) => {
      // Handle alert updates
    })

    return () => {
      socket.disconnect()
    }
  }, [dispatch])
}
```

#### **Manejo de Offline**
```typescript
// lib/offline/syncManager.ts
import { openDB, DBSchema } from 'idb'

interface SkyAngelDB extends DBSchema {
  alerts: {
    key: string
    value: {
      id: string
      data: any
      timestamp: number
      synced: boolean
    }
  }
  routes: {
    key: string
    value: {
      id: string
      data: any
      timestamp: number
      synced: boolean
    }
  }
}

class SyncManager {
  private db: any

  async init() {
    this.db = await openDB<SkyAngelDB>('skyangel-offline', 1, {
      upgrade(db) {
        db.createObjectStore('alerts', { keyPath: 'id' })
        db.createObjectStore('routes', { keyPath: 'id' })
      }
    })
  }

  async saveForLaterSync(store: 'alerts' | 'routes', data: any) {
    const item = {
      id: crypto.randomUUID(),
      data,
      timestamp: Date.now(),
      synced: false
    }
    await this.db.put(store, item)
    return item.id
  }

  async syncPendingData() {
    const pendingAlerts = await this.db.getAll('alerts')
    const pendingRoutes = await this.db.getAll('routes')

    for (const alert of pendingAlerts.filter(a => !a.synced)) {
      try {
        await this.syncAlert(alert)
        await this.db.put('alerts', { ...alert, synced: true })
      } catch (error) {
        console.error('Failed to sync alert:', error)
      }
    }

    for (const route of pendingRoutes.filter(r => !r.synced)) {
      try {
        await this.syncRoute(route)
        await this.db.put('routes', { ...route, synced: true })
      } catch (error) {
        console.error('Failed to sync route:', error)
      }
    }
  }

  private async syncAlert(alert: any) {
    const response = await fetch('/api/alerts', {
      method: 'POST',
      body: JSON.stringify(alert.data),
      headers: { 'Content-Type': 'application/json' }
    })
    if (!response.ok) throw new Error('Sync failed')
  }

  private async syncRoute(route: any) {
    const response = await fetch('/api/routes', {
      method: 'POST',
      body: JSON.stringify(route.data),
      headers: { 'Content-Type': 'application/json' }
    })
    if (!response.ok) throw new Error('Sync failed')
  }
}

export const syncManager = new SyncManager()
```

## 3. APLICACIÓN MÓVIL (FLUTTER)

### 3.1 Arquitectura Técnica

#### **Stack Tecnológico**
```yaml
Core Framework:
  - Flutter 3.16+
  - Dart 3.2+
  - Material 3 Design

Arquitectura:
  - Clean Architecture
  - Feature-based structure
  - Dependency Injection (GetIt)

Estado:
  - Riverpod 2.4+
  - StateNotifier
  - AsyncValue

Navegación:
  - Go Router 12+
  - Deep linking
  - Route guards

Mapas:
  - Flutter Map 6+
  - Geolocator 10+
  - Background location

Almacenamiento:
  - SQLite (sqflite)
  - Hive (cache)
  - Secure Storage

Networking:
  - Dio 5.3+
  - Retrofit
  - WebSocket

Background:
  - WorkManager
  - Background Service
  - Local Notifications

Testing:
  - Unit tests
  - Widget tests
  - Integration tests
```

#### **Estructura de Directorios**
```
sky_angel_mobile/
├── lib/
│   ├── core/                    # Core functionality
│   │   ├── di/                  # Dependency injection
│   │   ├── network/             # Network layer
│   │   ├── storage/             # Storage layer
│   │   ├── utils/               # Utilities
│   │   └── constants/           # Constants
│   ├── features/                # Feature modules
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   ├── models/
│   │   │   │   └── repositories/
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   ├── repositories/
│   │   │   │   └── usecases/
│   │   │   └── presentation/
│   │   │       ├── pages/
│   │   │       ├── widgets/
│   │   │       └── providers/
│   │   ├── maps/
│   │   ├── alerts/
│   │   ├── routes/
│   │   └── analytics/
│   ├── shared/                  # Shared components
│   │   ├── widgets/
│   │   ├── theme/
│   │   └── extensions/
│   └── main.dart
├── test/
├── android/
├── ios/
└── pubspec.yaml
```

### 3.2 Arquitectura de Funcionalidades

#### **Gestión de Estado con Riverpod**
```dart
// features/maps/presentation/providers/map_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/network/network_info.dart';
import '../../domain/entities/map_state.dart';
import '../../domain/usecases/get_alerts_usecase.dart';

part 'map_provider.g.dart';

@riverpod
class MapNotifier extends _$MapNotifier {
  @override
  MapState build() {
    return const MapState(
      center: LatLng(19.4326, -99.1332),
      zoom: 10.0,
      alerts: [],
      routes: [],
      isLoading: false,
    );
  }

  void updateCenter(LatLng center) {
    state = state.copyWith(center: center);
  }

  void updateZoom(double zoom) {
    state = state.copyWith(zoom: zoom);
  }

  Future<void> loadAlerts() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final networkInfo = ref.read(networkInfoProvider);
      final getAlertsUseCase = ref.read(getAlertsUseCaseProvider);
      
      if (await networkInfo.isConnected) {
        final alerts = await getAlertsUseCase.call(NoParams());
        state = state.copyWith(
          alerts: alerts,
          isLoading: false,
        );
      } else {
        // Load from local storage
        final localAlerts = await _loadLocalAlerts();
        state = state.copyWith(
          alerts: localAlerts,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<List<Alert>> _loadLocalAlerts() async {
    // Implementation for loading local alerts
    return [];
  }
}
```

#### **Servicio de Ubicación en Background**
```dart
// core/services/location_service.dart
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  final StreamController<Position> _positionController = 
      StreamController<Position>.broadcast();
  
  Stream<Position> get positionStream => _positionController.stream;

  Future<void> initialize() async {
    await _requestPermissions();
    await _configureBackgroundService();
  }

  Future<void> _requestPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }
  }

  Future<void> _configureBackgroundService() async {
    final service = FlutterBackgroundService();
    
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
        notificationChannelId: 'skyangel_location',
        initialNotificationTitle: 'SkyAngel Tracking',
        initialNotificationContent: 'Tracking location for safety',
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    return true;
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
      intervalDuration: Duration(seconds: 30),
    );

    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      service.invoke('update_location', {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': position.timestamp.millisecondsSinceEpoch,
      });
    });
  }

  Future<void> startTracking() async {
    await FlutterBackgroundService().startService();
  }

  Future<void> stopTracking() async {
    await FlutterBackgroundService().invoke('stop_service');
  }
}
```

#### **Gestión de Datos Offline**
```dart
// core/storage/offline_storage.dart
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/alert.dart';
import '../models/route.dart';

class OfflineStorage {
  static final OfflineStorage _instance = OfflineStorage._internal();
  factory OfflineStorage() => _instance;
  OfflineStorage._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'skyangel.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE alerts (
            id TEXT PRIMARY KEY,
            data TEXT NOT NULL,
            synced INTEGER NOT NULL DEFAULT 0,
            created_at INTEGER NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE routes (
            id TEXT PRIMARY KEY,
            data TEXT NOT NULL,
            synced INTEGER NOT NULL DEFAULT 0,
            created_at INTEGER NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE locations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            timestamp INTEGER NOT NULL,
            synced INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
  }

  Future<void> saveAlert(Alert alert) async {
    final db = await database;
    await db.insert(
      'alerts',
      {
        'id': alert.id,
        'data': jsonEncode(alert.toJson()),
        'synced': 0,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Alert>> getUnsyncedAlerts() async {
    final db = await database;
    final maps = await db.query(
      'alerts',
      where: 'synced = ?',
      whereArgs: [0],
    );

    return maps.map((map) {
      final data = jsonDecode(map['data'] as String);
      return Alert.fromJson(data);
    }).toList();
  }

  Future<void> markAlertAsSynced(String id) async {
    final db = await database;
    await db.update(
      'alerts',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> saveLocation(double latitude, double longitude) async {
    final db = await database;
    await db.insert('locations', {
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'synced': 0,
    });
  }

  Future<void> syncPendingData() async {
    final alerts = await getUnsyncedAlerts();
    final routes = await getUnsyncedRoutes();
    
    for (final alert in alerts) {
      try {
        await _syncAlert(alert);
        await markAlertAsSynced(alert.id);
      } catch (e) {
        print('Failed to sync alert: $e');
      }
    }

    for (final route in routes) {
      try {
        await _syncRoute(route);
        await markRouteAsSynced(route.id);
      } catch (e) {
        print('Failed to sync route: $e');
      }
    }
  }

  Future<void> _syncAlert(Alert alert) async {
    // Implementation for syncing alert to server
  }

  Future<void> _syncRoute(Route route) async {
    // Implementation for syncing route to server
  }
}
```

### 3.3 Widgets Reutilizables

#### **Mapa Base Flutter**
```dart
// shared/widgets/skyangel_map.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SkyAngelMap extends ConsumerStatefulWidget {
  final LatLng center;
  final double zoom;
  final List<Widget> children;
  final VoidCallback? onMapReady;
  final Function(LatLng)? onTap;

  const SkyAngelMap({
    super.key,
    required this.center,
    this.zoom = 10.0,
    this.children = const [],
    this.onMapReady,
    this.onTap,
  });

  @override
  ConsumerState<SkyAngelMap> createState() => _SkyAngelMapState();
}

class _SkyAngelMapState extends ConsumerState<SkyAngelMap> {
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onMapReady?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: widget.center,
        initialZoom: widget.zoom,
        onTap: widget.onTap != null
            ? (tapPosition, point) => widget.onTap!(point)
            : null,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.skyangel.mobile',
        ),
        ...widget.children,
      ],
    );
  }
}
```

#### **Botón de Alerta Flotante**
```dart
// shared/widgets/alert_fab.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AlertFAB extends ConsumerWidget {
  final VoidCallback onPressed;

  const AlertFAB({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.warning),
      label: const Text('Reportar Alerta'),
      heroTag: 'alert_fab',
    );
  }
}
```

## 4. CARACTERÍSTICAS TRANSVERSALES

### 4.1 Sistema de Diseño

#### **Tokens de Diseño**
```typescript
// Web (Tailwind Config)
module.exports = {
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#eff6ff',
          500: '#3b82f6',
          900: '#1e3a8a',
        },
        danger: {
          50: '#fef2f2',
          500: '#ef4444',
          900: '#7f1d1d',
        },
        success: {
          50: '#f0fdf4',
          500: '#22c55e',
          900: '#14532d',
        },
        warning: {
          50: '#fffbeb',
          500: '#f59e0b',
          900: '#78350f',
        },
      },
      spacing: {
        '18': '4.5rem',
        '88': '22rem',
      },
      fontSize: {
        'xs': '0.75rem',
        'sm': '0.875rem',
        'base': '1rem',
        'lg': '1.125rem',
        'xl': '1.25rem',
        '2xl': '1.5rem',
      },
    },
  },
}
```

```dart
// Mobile (Flutter Theme)
class SkyAngelTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF3B82F6),
        secondary: Color(0xFF6B7280),
        error: Color(0xFFEF4444),
        background: Color(0xFFF9FAFB),
        surface: Color(0xFFFFFFFF),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Color(0xFF111827),
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Color(0xFF111827),
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: Color(0xFF374151),
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: Color(0xFF6B7280),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3B82F6),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
```

### 4.2 Performance y Optimización

#### **Lazy Loading (Web)**
```typescript
// app/dashboard/layout.tsx
import dynamic from 'next/dynamic'
import { Suspense } from 'react'

const MapWidget = dynamic(() => import('@/components/maps/MapWidget'), {
  ssr: false,
  loading: () => <div className="animate-pulse bg-gray-200 rounded-lg h-64" />
})

const ChartsWidget = dynamic(() => import('@/components/charts/ChartsWidget'), {
  ssr: false,
  loading: () => <div className="animate-pulse bg-gray-200 rounded-lg h-32" />
})

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <div className="lg:col-span-2">
        <Suspense fallback={<div>Loading map...</div>}>
          <MapWidget />
        </Suspense>
      </div>
      <div>
        <Suspense fallback={<div>Loading charts...</div>}>
          <ChartsWidget />
        </Suspense>
      </div>
      {children}
    </div>
  )
}
```

#### **Optimización de Memoria (Mobile)**
```dart
// shared/utils/memory_manager.dart
class MemoryManager {
  static const int _maxCacheSize = 100;
  static final Map<String, dynamic> _cache = {};

  static void cacheData(String key, dynamic data) {
    if (_cache.length >= _maxCacheSize) {
      // Remove oldest entries
      final oldestKey = _cache.keys.first;
      _cache.remove(oldestKey);
    }
    _cache[key] = data;
  }

  static T? getCachedData<T>(String key) {
    return _cache[key] as T?;
  }

  static void clearCache() {
    _cache.clear();
  }

  static void clearLowMemory() {
    final keysToRemove = _cache.keys.take(_cache.length ~/ 2).toList();
    for (final key in keysToRemove) {
      _cache.remove(key);
    }
  }
}
```

### 4.3 Testing

#### **Testing Web**
```typescript
// components/maps/BaseMap.test.tsx
import { render, screen } from '@testing-library/react'
import { Provider } from 'react-redux'
import { store } from '@/lib/store'
import BaseMap from './BaseMap'

const MockMapContainer = ({ children }: { children: React.ReactNode }) => (
  <div data-testid="map-container">{children}</div>
)

jest.mock('react-leaflet', () => ({
  MapContainer: MockMapContainer,
  TileLayer: () => <div data-testid="tile-layer" />,
}))

describe('BaseMap', () => {
  it('renders correctly', () => {
    render(
      <Provider store={store}>
        <BaseMap />
      </Provider>
    )

    expect(screen.getByTestId('map-container')).toBeInTheDocument()
    expect(screen.getByTestId('tile-layer')).toBeInTheDocument()
  })

  it('handles map click events', () => {
    const mockOnClick = jest.fn()
    render(
      <Provider store={store}>
        <BaseMap onMapClick={mockOnClick} />
      </Provider>
    )

    // Test click handling
  })
})
```

#### **Testing Mobile**
```dart
// test/features/maps/presentation/pages/map_page_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skyangel_mobile/features/maps/presentation/pages/map_page.dart';

void main() {
  group('MapPage', () {
    testWidgets('should display map correctly', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MapPage(),
          ),
        ),
      );

      expect(find.byType(FlutterMap), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('should show alert dialog when FAB is pressed', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MapPage(),
          ),
        ),
      );

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Reportar Alerta'), findsOneWidget);
    });
  });
}
```

## 5. PLAN DE IMPLEMENTACIÓN

### Fase 1: Fundamentos (6 semanas)
```yaml
Web:
  - Setup Next.js 14 con App Router
  - Configuración de Tailwind CSS
  - Implementación de design system
  - Configuración de Redux Toolkit
  - Integración con API Gateway

Mobile:
  - Setup Flutter project
  - Configuración de Clean Architecture
  - Implementación de design system
  - Configuración de Riverpod
  - Setup de dependencias principales

Común:
  - Definición de tipos TypeScript/Dart
  - Configuración de CI/CD
  - Setup de testing
```

### Fase 2: Funcionalidades Core (8 semanas)
```yaml
Mapas:
  - Implementación de mapas base
  - Integración con datos GeoJSON
  - Sistemas de capas
  - Controles de navegación

Alertas:
  - Sistema de alertas en tiempo real
  - Formularios de reporte
  - Notificaciones push
  - WebSocket integration

Autenticación:
  - Login/Register screens
  - Biometric authentication (mobile)
  - Session management
  - Token refresh
```

### Fase 3: Funcionalidades Avanzadas (6 semanas)
```yaml
Rutas:
  - Cálculo de rutas
  - Análisis de riesgo
  - Optimización de rutas
  - Historial de rutas

Analytics:
  - Dashboards interactivos
  - Gráficas y visualizaciones
  - Reportes exportables
  - Análisis temporal

Offline:
  - Sync manager
  - Local storage
  - Background sync
  - Offline indicators
```

### Fase 4: Optimización y Pulido (4 semanas)
```yaml
Performance:
  - Lazy loading
  - Code splitting
  - Image optimization
  - Memory management

UX/UI:
  - Animations
  - Loading states
  - Error handling
  - Accessibility

Testing:
  - Unit tests
  - Integration tests
  - E2E tests
  - Performance tests
```

## 6. MÉTRICAS DE ÉXITO

### 6.1 Performance
```yaml
Web:
  - First Contentful Paint: < 1.5s
  - Largest Contentful Paint: < 2.5s
  - Cumulative Layout Shift: < 0.1
  - Time to Interactive: < 3s
  - Bundle size: < 1MB

Mobile:
  - App startup time: < 2s
  - Frame rate: 60fps
  - Memory usage: < 150MB
  - Battery usage: < 5%/hour
  - APK size: < 50MB
```

### 6.2 Usabilidad
```yaml
Métricas:
  - Task completion rate: > 90%
  - Error rate: < 2%
  - User satisfaction: > 4.5/5
  - Feature adoption: > 70%
  - Session duration: > 5 min
```

### 6.3 Técnicas
```yaml
Calidad:
  - Code coverage: > 80%
  - Bug density: < 1 bug/1000 LoC
  - Accessibility score: > 90%
  - Security score: > 95%
  - SEO score: > 90% (web)
```

## CONCLUSIÓN

Esta solución frontend proporciona una base sólida y moderna para la plataforma SkyAngel, con:

✅ **Arquitectura escalable** para ambas plataformas
✅ **Experiencia de usuario consistente** entre web y mobile
✅ **Performance optimizado** para diferentes dispositivos
✅ **Funcionalidad offline robusta** para áreas sin cobertura
✅ **Sistema de testing completo** para garantizar calidad
✅ **Patrones modernos** alineados con las mejores prácticas
✅ **Mantenibilidad** a largo plazo con código limpio

El diseño permite evolucionar la plataforma según las necesidades del negocio mientras mantiene la calidad y performance esperadas por los usuarios.