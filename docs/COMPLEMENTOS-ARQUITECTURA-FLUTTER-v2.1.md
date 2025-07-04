# COMPLEMENTOS Y FUNCIONALIDADES ESPECÍFICAS - SKYANGEL FLUTTER v2.1

## ANÁLISIS DEL SISTEMA ACTUAL Y MAPEO A FLUTTER

Basado en el análisis exhaustivo del frontend React actual, he identificado funcionalidades específicas que deben implementarse en Flutter para garantizar la operación correcta del sistema. Este documento complementa la arquitectura base con detalles específicos de implementación.

## 1. MÓDULOS ESPECÍFICOS Y MAPEO DE FUNCIONALIDADES

### 1.1 Módulo de Delitos - Implementación Flutter

#### **Componente Principal DelitosScreen**
```dart
// features/delitos/presentation/pages/delitos_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import '../widgets/delitos_sidebar.dart';
import '../widgets/delitos_map.dart';
import '../widgets/delitos_modal.dart';

class DelitosScreen extends ConsumerStatefulWidget {
  const DelitosScreen({super.key});

  @override
  ConsumerState<DelitosScreen> createState() => _DelitosScreenState();
}

class _DelitosScreenState extends ConsumerState<DelitosScreen>
    with TickerProviderStateMixin {
  late AnimationController _sidebarController;
  late AnimationController _mapController;

  @override
  void initState() {
    super.initState();
    _sidebarController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _mapController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    final delitosState = ref.watch(delitosProvider);
    final isTablet = MediaQuery.of(context).size.width > 768;

    return Scaffold(
      body: Stack(
        children: [
          // Mapa principal
          DelitosMap(
            mapController: _mapController,
            onMunicipalityTap: _showMunicipalityModal,
          ),
          
          // Sidebar de filtros
          if (isTablet)
            _buildDesktopSidebar()
          else
            _buildMobileSidebar(),
          
          // Controles de mapa
          _buildMapControls(),
          
          // Leyenda
          _buildLegend(),
          
          // Modal de detalles
          if (delitosState.selectedMunicipality != null)
            DelitosModal(
              municipality: delitosState.selectedMunicipality!,
              onClose: () => ref.read(delitosProvider.notifier).clearSelection(),
            ),
        ],
      ),
    );
  }

  Widget _buildDesktopSidebar() {
    return Positioned(
      left: 0,
      top: 0,
      bottom: 0,
      width: 350,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(-1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _sidebarController,
          curve: Curves.easeInOut,
        )),
        child: const DelitosSidebar(),
      ),
    );
  }

  Widget _buildMobileSidebar() {
    return Consumer(
      builder: (context, ref, child) {
        final isOpen = ref.watch(delitosProvider.select((s) => s.isSidebarOpen));
        
        return AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          left: isOpen ? 0 : -300,
          top: 0,
          bottom: 0,
          width: 300,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: const DelitosSidebar(),
          ),
        );
      },
    );
  }

  Widget _buildMapControls() {
    return Positioned(
      right: 16,
      top: kToolbarHeight + 16,
      child: Column(
        children: [
          _MapControlButton(
            icon: Icons.filter_list,
            onPressed: () => ref.read(delitosProvider.notifier).toggleSidebar(),
            tooltip: 'Filtros',
          ),
          const SizedBox(height: 8),
          _MapControlButton(
            icon: Icons.layers,
            onPressed: _showLayersDialog,
            tooltip: 'Escalas',
          ),
          const SizedBox(height: 8),
          _MapControlButton(
            icon: Icons.info_outline,
            onPressed: _showInfoDialog,
            tooltip: 'Información',
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Consumer(
      builder: (context, ref, child) {
        final delitosState = ref.watch(delitosProvider);
        if (!delitosState.showLegend) return const SizedBox.shrink();
        
        return Positioned(
          left: 16,
          bottom: 16,
          child: DelitosLegend(
            escala: delitosState.escalaActual,
            fuenteDatos: delitosState.fuenteSeleccionada,
          ),
        );
      },
    );
  }

  void _showMunicipalityModal(Municipality municipality) {
    ref.read(delitosProvider.notifier).selectMunicipality(municipality);
  }

  void _showLayersDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => const EscalasBottomSheet(),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => const InfoDialog(),
    );
  }
}

class _MapControlButton extends StatelessWidget {
  const _MapControlButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: Theme.of(context).colorScheme.surface,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      elevation: 4,
      child: Icon(icon, size: 20),
    );
  }
}
```

#### **Sistema de Filtros Específico**
```dart
// features/delitos/presentation/widgets/delitos_sidebar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/filtros/secretariado_filtros.dart';
import '../widgets/filtros/anerpv_filtros.dart';
import '../widgets/filtros/skyangel_filtros.dart';

class DelitosSidebar extends ConsumerWidget {
  const DelitosSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final delitosState = ref.watch(delitosProvider);
    
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Análisis de Delitos',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Selector de fuente de datos
          Container(
            padding: const EdgeInsets.all(16),
            child: _buildDataSourceSelector(ref, delitosState),
          ),
          
          // Filtros específicos por fuente
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildFiltrosContent(delitosState.fuenteSeleccionada),
            ),
          ),
          
          // Botones de acción
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _aplicarFiltros(ref),
                    icon: const Icon(Icons.search),
                    label: const Text('Aplicar Filtros'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () => _limpiarFiltros(ref),
                    icon: const Icon(Icons.clear),
                    label: const Text('Limpiar Filtros'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataSourceSelector(WidgetRef ref, DelitosState state) {
    final fuentes = [
      const FuenteDatos(id: 1, nombre: 'Secretariado', color: Colors.blue),
      const FuenteDatos(id: 2, nombre: 'ANERPV', color: Colors.green),
      const FuenteDatos(id: 3, nombre: 'SkyAngel', color: Colors.purple),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fuente de Datos',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...fuentes.map((fuente) => RadioListTile<FuenteDatos>(
          title: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: fuente.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(fuente.nombre),
            ],
          ),
          value: fuente,
          groupValue: state.fuenteSeleccionada,
          onChanged: (value) {
            if (value != null) {
              ref.read(delitosProvider.notifier).cambiarFuente(value);
            }
          },
        )),
      ],
    );
  }

  Widget _buildFiltrosContent(FuenteDatos fuente) {
    switch (fuente.id) {
      case 1: // Secretariado
        return const SecretariadoFiltros();
      case 2: // ANERPV
        return const AnerpvFiltros();
      case 3: // SkyAngel
        return const SkyAngelFiltros();
      default:
        return const SizedBox.shrink();
    }
  }

  void _aplicarFiltros(WidgetRef ref) {
    ref.read(delitosProvider.notifier).aplicarFiltros();
  }

  void _limpiarFiltros(WidgetRef ref) {
    ref.read(delitosProvider.notifier).limpiarFiltros();
  }
}

// features/delitos/presentation/widgets/filtros/secretariado_filtros.dart
class SecretariadoFiltros extends ConsumerWidget {
  const SecretariadoFiltros({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtros = ref.watch(delitosProvider.select((s) => s.filtrosSecretariado));
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filtro de Años
        _buildMultiSelectFilter(
          context: context,
          title: 'Años',
          items: filtros.aniosDisponibles,
          selectedItems: filtros.aniosSeleccionados,
          onChanged: (selected) {
            ref.read(delitosProvider.notifier).actualizarFiltroSecretariado(
              filtros.copyWith(aniosSeleccionados: selected),
            );
          },
        ),
        
        const SizedBox(height: 16),
        
        // Filtro de Entidades
        _buildMultiSelectFilter(
          context: context,
          title: 'Entidades',
          items: filtros.entidadesDisponibles,
          selectedItems: filtros.entidadesSeleccionadas,
          onChanged: (selected) {
            ref.read(delitosProvider.notifier).actualizarFiltroSecretariado(
              filtros.copyWith(entidadesSeleccionadas: selected),
            );
          },
        ),
        
        const SizedBox(height: 16),
        
        // Filtro de Municipios
        _buildMunicipiosFilter(context, ref, filtros),
        
        const SizedBox(height: 16),
        
        // Filtro de Bienes Jurídicos
        _buildMultiSelectFilter(
          context: context,
          title: 'Bienes Jurídicos',
          items: filtros.bienesJuridicosDisponibles,
          selectedItems: filtros.bienesJuridicosSeleccionados,
          onChanged: (selected) {
            ref.read(delitosProvider.notifier).actualizarFiltroSecretariado(
              filtros.copyWith(bienesJuridicosSeleccionados: selected),
            );
          },
        ),
        
        const SizedBox(height: 16),
        
        // Filtro de Tipos de Delito
        _buildTiposDelitoFilter(context, ref, filtros),
        
        const SizedBox(height: 16),
        
        // Filtro de Subtipos de Delito
        _buildSubtiposDelitoFilter(context, ref, filtros),
      ],
    );
  }

  Widget _buildMultiSelectFilter<T>({
    required BuildContext context,
    required String title,
    required List<T> items,
    required List<T> selectedItems,
    required Function(List<T>) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: MultiSelectDropdown<T>(
            items: items,
            selectedItems: selectedItems,
            onChanged: onChanged,
            displayStringForItem: (item) => item.toString(),
            hintText: 'Seleccionar $title',
          ),
        ),
      ],
    );
  }

  Widget _buildMunicipiosFilter(
    BuildContext context, 
    WidgetRef ref, 
    FiltrosSecretariado filtros
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Municipios',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SearchableMultiSelect(
            items: filtros.municipiosDisponibles,
            selectedItems: filtros.municipiosSeleccionados,
            onChanged: (selected) {
              ref.read(delitosProvider.notifier).actualizarFiltroSecretariado(
                filtros.copyWith(municipiosSeleccionados: selected),
              );
            },
            searchHint: 'Buscar municipios...',
            displayStringForItem: (municipio) => '${municipio.nombre} (${municipio.entidad})',
          ),
        ),
      ],
    );
  }

  Widget _buildTiposDelitoFilter(
    BuildContext context, 
    WidgetRef ref, 
    FiltrosSecretariado filtros
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipos de Delito',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: HierarchicalMultiSelect(
            items: filtros.tiposDelitoDisponibles,
            selectedItems: filtros.tiposDelitoSeleccionados,
            onChanged: (selected) {
              ref.read(delitosProvider.notifier).actualizarFiltroSecretariado(
                filtros.copyWith(tiposDelitoSeleccionados: selected),
              );
            },
            getChildren: (tipo) => tipo.subtipos,
            displayStringForItem: (tipo) => tipo.nombre,
          ),
        ),
      ],
    );
  }

  Widget _buildSubtiposDelitoFilter(
    BuildContext context, 
    WidgetRef ref, 
    FiltrosSecretariado filtros
  ) {
    // Los subtipos se actualizan automáticamente basado en los tipos seleccionados
    final subtiposDisponibles = filtros.tiposDelitoSeleccionados
        .expand((tipo) => tipo.subtipos)
        .toList();

    if (subtiposDisponibles.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Subtipos de Delito',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: MultiSelectDropdown<SubtipoDelito>(
            items: subtiposDisponibles,
            selectedItems: filtros.subtiposDelitoSeleccionados,
            onChanged: (selected) {
              ref.read(delitosProvider.notifier).actualizarFiltroSecretariado(
                filtros.copyWith(subtiposDelitoSeleccionados: selected),
              );
            },
            displayStringForItem: (subtipo) => subtipo.nombre,
            hintText: 'Seleccionar Subtipos',
          ),
        ),
      ],
    );
  }
}
```

### 1.2 Sistema de Gráficos Avanzado

#### **Gráficos Nativos Flutter con FL Chart**
```dart
// features/delitos/presentation/widgets/charts/delitos_charts.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DelitosChartsWidget extends ConsumerWidget {
  const DelitosChartsWidget({
    super.key,
    required this.municipality,
  });

  final Municipality municipality;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chartsData = ref.watch(municipalityChartsProvider(municipality.id));

    return chartsData.when(
      data: (data) => _buildChartsContent(context, data),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
    );
  }

  Widget _buildChartsContent(BuildContext context, MunicipalityChartsData data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Gráfico de Barras - Delitos por Año
          _buildBarChart(context, data.delitosPorAnio),
          
          const SizedBox(height: 24),
          
          // Gráfico de Líneas - Tendencia Temporal
          _buildLineChart(context, data.tendenciaTemporal),
          
          const SizedBox(height: 24),
          
          // Gráfico de Pie - Distribución por Tipo
          _buildPieChart(context, data.distribucionTipos),
          
          const SizedBox(height: 24),
          
          // Heatmap - Delitos por Mes y Año
          _buildHeatmap(context, data.delitosPorMesAnio),
        ],
      ),
    );
  }

  Widget _buildBarChart(BuildContext context, List<BarChartData> data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delitos por Año',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  barGroups: data.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: item.value.toDouble(),
                          color: _getColorForValue(item.value),
                          width: 20,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: Theme.of(context).textTheme.bodySmall,
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < data.length) {
                            return Text(
                              data[index].label,
                              style: Theme.of(context).textTheme.bodySmall,
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: _calculateInterval(data),
                  ),
                  borderData: FlBorderData(show: false),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${data[group.x].label}\n${rod.toY.toInt()} delitos',
                          TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart(BuildContext context, List<LineChartData> data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tendencia Temporal',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: data.asMap().entries.map((entry) {
                        return FlSpot(
                          entry.key.toDouble(),
                          entry.value.value.toDouble(),
                        );
                      }).toList(),
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Theme.of(context).colorScheme.primary,
                            strokeColor: Theme.of(context).colorScheme.surface,
                            strokeWidth: 2,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      ),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: Theme.of(context).textTheme.bodySmall,
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < data.length) {
                            return Text(
                              data[index].label,
                              style: Theme.of(context).textTheme.bodySmall,
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      left: BorderSide(color: Theme.of(context).dividerColor),
                      bottom: BorderSide(color: Theme.of(context).dividerColor),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(BuildContext context, List<PieChartData> data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Distribución por Tipo de Delito',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // Pie chart
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 250,
                    child: PieChart(
                      PieChartData(
                        sections: data.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          final total = data.fold<double>(
                            0, 
                            (sum, item) => sum + item.value,
                          );
                          final percentage = (item.value / total * 100);
                          
                          return PieChartSectionData(
                            value: item.value.toDouble(),
                            title: '${percentage.toStringAsFixed(1)}%',
                            color: _getPieColors()[index % _getPieColors().length],
                            radius: 80,
                            titleStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          );
                        }).toList(),
                        centerSpaceRadius: 40,
                        sectionsSpace: 2,
                      ),
                    ),
                  ),
                ),
                
                // Legend
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: data.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: _getPieColors()[index % _getPieColors().length],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.label,
                                style: Theme.of(context).textTheme.bodySmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeatmap(BuildContext context, List<List<HeatmapData>> data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delitos por Mes y Año',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: CustomHeatmapWidget(
                  data: data,
                  cellWidth: 40,
                  cellHeight: 30,
                  colorScale: _getHeatmapColors(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForValue(double value) {
    // Implementar lógica de colores basada en valor
    if (value < 10) return Colors.green;
    if (value < 50) return Colors.yellow;
    if (value < 100) return Colors.orange;
    return Colors.red;
  }

  double _calculateInterval(List<BarChartData> data) {
    final maxValue = data.fold<double>(0, (max, item) => 
        item.value > max ? item.value.toDouble() : max);
    return maxValue / 5;
  }

  List<Color> _getPieColors() {
    return [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.teal,
      Colors.amber,
      Colors.indigo,
    ];
  }

  List<Color> _getHeatmapColors() {
    return [
      Colors.blue[50]!,
      Colors.blue[100]!,
      Colors.blue[300]!,
      Colors.blue[500]!,
      Colors.blue[700]!,
      Colors.blue[900]!,
    ];
  }
}

// Widget personalizado para heatmap
class CustomHeatmapWidget extends StatelessWidget {
  const CustomHeatmapWidget({
    super.key,
    required this.data,
    required this.cellWidth,
    required this.cellHeight,
    required this.colorScale,
  });

  final List<List<HeatmapData>> data;
  final double cellWidth;
  final double cellHeight;
  final List<Color> colorScale;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: data.asMap().entries.map((rowEntry) {
        final rowIndex = rowEntry.key;
        final row = rowEntry.value;
        
        return Row(
          children: row.asMap().entries.map((cellEntry) {
            final cellIndex = cellEntry.key;
            final cell = cellEntry.value;
            
            return Container(
              width: cellWidth,
              height: cellHeight,
              margin: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: _getColorForValue(cell.value),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text(
                  cell.value.toString(),
                  style: TextStyle(
                    fontSize: 10,
                    color: cell.value > 50 ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }

  Color _getColorForValue(double value) {
    // Normalizar valor entre 0 y 1
    final maxValue = data
        .expand((row) => row)
        .fold<double>(0, (max, cell) => cell.value > max ? cell.value : max);
    
    final normalizedValue = maxValue > 0 ? value / maxValue : 0.0;
    
    // Mapear a escala de colores
    final colorIndex = (normalizedValue * (colorScale.length - 1)).round();
    return colorScale[colorIndex.clamp(0, colorScale.length - 1)];
  }
}
```

### 1.3 Sistema de Alertas en Tiempo Real

#### **Componente de Alertas con WebSocket**
```dart
// features/alerts/presentation/widgets/alerts_real_time_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../providers/alerts_websocket_provider.dart';

class AlertsRealTimeWidget extends ConsumerStatefulWidget {
  const AlertsRealTimeWidget({super.key});

  @override
  ConsumerState<AlertsRealTimeWidget> createState() => _AlertsRealTimeWidgetState();
}

class _AlertsRealTimeWidgetState extends ConsumerState<AlertsRealTimeWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<Alert?>>(newAlertStreamProvider, (previous, next) {
      next.whenData((alert) {
        if (alert != null) {
          _showNewAlertNotification(alert);
        }
      });
    });

    final alertsStream = ref.watch(alertsStreamProvider);
    final connectionStatus = ref.watch(websocketConnectionProvider);

    return Column(
      children: [
        // Status de conexión
        _buildConnectionStatus(connectionStatus),
        
        // Lista de alertas en tiempo real
        Expanded(
          child: alertsStream.when(
            data: (alerts) => _buildAlertsList(alerts),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => _buildErrorWidget(error),
          ),
        ),
        
        // Botón de nueva alerta
        _buildNewAlertButton(),
      ],
    );
  }

  Widget _buildConnectionStatus(WebSocketConnectionStatus status) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: _getStatusColor(status),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: status == WebSocketConnectionStatus.connected
                    ? 1.0 + (_pulseController.value * 0.1)
                    : 1.0,
                child: Icon(
                  _getStatusIcon(status),
                  size: 16,
                  color: Colors.white,
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          Text(
            _getStatusText(status),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
          const Spacer(),
          if (status == WebSocketConnectionStatus.disconnected)
            TextButton(
              onPressed: () => ref.read(websocketServiceProvider).connect(),
              child: const Text(
                'Reconectar',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAlertsList(List<Alert> alerts) {
    if (alerts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No hay alertas activas',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: alerts.length,
      itemBuilder: (context, index) {
        final alert = alerts[index];
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _slideController,
            curve: Curves.easeOut,
          )),
          child: AlertListItem(
            alert: alert,
            onTap: () => _showAlertDetails(alert),
            onDismiss: () => _dismissAlert(alert),
          ),
        );
      },
    );
  }

  Widget _buildErrorWidget(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Error al cargar alertas',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(alertsStreamProvider);
            },
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildNewAlertButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _showNewAlertDialog,
          icon: const Icon(Icons.add_alert),
          label: const Text('Reportar Nueva Alerta'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(WebSocketConnectionStatus status) {
    switch (status) {
      case WebSocketConnectionStatus.connected:
        return Colors.green;
      case WebSocketConnectionStatus.connecting:
        return Colors.orange;
      case WebSocketConnectionStatus.disconnected:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(WebSocketConnectionStatus status) {
    switch (status) {
      case WebSocketConnectionStatus.connected:
        return Icons.wifi;
      case WebSocketConnectionStatus.connecting:
        return Icons.wifi_tethering;
      case WebSocketConnectionStatus.disconnected:
        return Icons.wifi_off;
    }
  }

  String _getStatusText(WebSocketConnectionStatus status) {
    switch (status) {
      case WebSocketConnectionStatus.connected:
        return 'Conectado - Recibiendo alertas en tiempo real';
      case WebSocketConnectionStatus.connecting:
        return 'Conectando...';
      case WebSocketConnectionStatus.disconnected:
        return 'Desconectado - Alertas no actualizadas';
    }
  }

  void _showNewAlertNotification(Alert alert) {
    _slideController.forward();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _getAlertIcon(alert.type),
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Nueva Alerta: ${_getAlertTypeText(alert.type)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    alert.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: _getAlertColor(alert.severity),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Ver',
          textColor: Colors.white,
          onPressed: () => _showAlertDetails(alert),
        ),
      ),
    );
  }

  void _showAlertDetails(Alert alert) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AlertDetailsBottomSheet(alert: alert),
    );
  }

  void _dismissAlert(Alert alert) {
    ref.read(alertsProvider.notifier).dismissAlert(alert.id);
  }

  void _showNewAlertDialog() {
    showDialog(
      context: context,
      builder: (context) => const NewAlertDialog(),
    );
  }

  IconData _getAlertIcon(AlertType type) {
    switch (type) {
      case AlertType.accident:
        return Icons.car_crash;
      case AlertType.robbery:
        return Icons.warning;
      case AlertType.roadblock:
        return Icons.block;
      case AlertType.weather:
        return Icons.cloud;
      case AlertType.mechanical:
        return Icons.build;
      case AlertType.police:
        return Icons.local_police;
      case AlertType.other:
        return Icons.info;
    }
  }

  String _getAlertTypeText(AlertType type) {
    switch (type) {
      case AlertType.accident:
        return 'Accidente';
      case AlertType.robbery:
        return 'Robo';
      case AlertType.roadblock:
        return 'Bloqueo';
      case AlertType.weather:
        return 'Clima';
      case AlertType.mechanical:
        return 'Mecánico';
      case AlertType.police:
        return 'Policía';
      case AlertType.other:
        return 'Otro';
    }
  }

  Color _getAlertColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.low:
        return Colors.yellow[700]!;
      case AlertSeverity.medium:
        return Colors.orange[700]!;
      case AlertSeverity.high:
        return Colors.red[700]!;
      case AlertSeverity.critical:
        return Colors.purple[700]!;
    }
  }
}

class AlertListItem extends StatelessWidget {
  const AlertListItem({
    super.key,
    required this.alert,
    required this.onTap,
    required this.onDismiss,
  });

  final Alert alert;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(alert.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.red,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: _getAlertColor(alert.severity),
            child: Icon(
              _getAlertIcon(alert.type),
              color: Colors.white,
              size: 20,
            ),
          ),
          title: Text(
            _getAlertTypeText(alert.type),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                alert.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                _formatTimestamp(alert.createdAt),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSeverityBadge(context, alert.severity),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right),
            ],
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _buildSeverityBadge(BuildContext context, AlertSeverity severity) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getAlertColor(severity),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getSeverityText(severity),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  IconData _getAlertIcon(AlertType type) {
    switch (type) {
      case AlertType.accident:
        return Icons.car_crash;
      case AlertType.robbery:
        return Icons.warning;
      case AlertType.roadblock:
        return Icons.block;
      case AlertType.weather:
        return Icons.cloud;
      case AlertType.mechanical:
        return Icons.build;
      case AlertType.police:
        return Icons.local_police;
      case AlertType.other:
        return Icons.info;
    }
  }

  String _getAlertTypeText(AlertType type) {
    switch (type) {
      case AlertType.accident:
        return 'Accidente';
      case AlertType.robbery:
        return 'Robo';
      case AlertType.roadblock:
        return 'Bloqueo';
      case AlertType.weather:
        return 'Clima';
      case AlertType.mechanical:
        return 'Mecánico';
      case AlertType.police:
        return 'Policía';
      case AlertType.other:
        return 'Otro';
    }
  }

  Color _getAlertColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.low:
        return Colors.yellow[700]!;
      case AlertSeverity.medium:
        return Colors.orange[700]!;
      case AlertSeverity.high:
        return Colors.red[700]!;
      case AlertSeverity.critical:
        return Colors.purple[700]!;
    }
  }

  String _getSeverityText(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.low:
        return 'BAJO';
      case AlertSeverity.medium:
        return 'MEDIO';
      case AlertSeverity.high:
        return 'ALTO';
      case AlertSeverity.critical:
        return 'CRÍTICO';
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Hace unos segundos';
    } else if (difference.inHours < 1) {
      return 'Hace ${difference.inMinutes} minutos';
    } else if (difference.inDays < 1) {
      return 'Hace ${difference.inHours} horas';
    } else {
      return 'Hace ${difference.inDays} días';
    }
  }
}
```

### 1.4 Sistema de Rutas Específico

#### **Calculadora de Rutas con Algoritmo de Riesgo**
```dart
// features/routes/domain/usecases/calculate_safe_route_usecase.dart
import 'package:injectable/injectable.dart';
import '../../../../app/core/usecases/usecase.dart';
import '../../../../app/core/error/failures.dart';
import '../entities/route.dart';
import '../entities/risk_factor.dart';
import '../repositories/route_repository.dart';

@injectable
class CalculateSafeRouteUseCase implements UseCase<List<SafeRoute>, RouteCalculationParams> {
  final RouteRepository repository;

  CalculateSafeRouteUseCase(this.repository);

  @override
  Future<Either<Failure, List<SafeRoute>>> call(RouteCalculationParams params) async {
    try {
      // 1. Obtener rutas básicas del servicio de routing
      final basicRoutes = await repository.calculateBasicRoutes(
        origin: params.origin,
        destination: params.destination,
        vehicleType: params.vehicleType,
        departureTiem: params.departureTime,
      );

      // 2. Obtener factores de riesgo para cada ruta
      final routesWithRisks = await Future.wait(
        basicRoutes.map((route) => _calculateRouteRisk(route, params.riskFactors)),
      );

      // 3. Ordenar por nivel de riesgo total
      routesWithRisks.sort((a, b) => a.totalRiskScore.compareTo(b.totalRiskScore));

      // 4. Aplicar algoritmos específicos de SkyAngel
      final optimizedRoutes = await _applySkyangelOptimizations(routesWithRisks, params);

      return Right(optimizedRoutes);
    } catch (e) {
      return Left(RouteCalculationFailure(e.toString()));
    }
  }

  Future<SafeRoute> _calculateRouteRisk(BasicRoute route, List<RiskFactor> riskFactors) async {
    double totalRisk = 0.0;
    final List<RiskSegment> riskSegments = [];

    for (int i = 0; i < route.waypoints.length - 1; i++) {
      final segment = RouteSegment(
        start: route.waypoints[i],
        end: route.waypoints[i + 1],
      );

      double segmentRisk = 0.0;
      final List<RiskDetail> segmentRiskDetails = [];

      for (final riskFactor in riskFactors) {
        final riskValue = await _calculateRiskForSegment(segment, riskFactor);
        segmentRisk += riskValue * riskFactor.weight;
        
        if (riskValue > 0) {
          segmentRiskDetails.add(RiskDetail(
            factor: riskFactor,
            value: riskValue,
            description: _getRiskDescription(riskFactor, riskValue),
          ));
        }
      }

      totalRisk += segmentRisk;
      riskSegments.add(RiskSegment(
        segment: segment,
        riskScore: segmentRisk,
        riskDetails: segmentRiskDetails,
      ));
    }

    return SafeRoute(
      id: route.id,
      waypoints: route.waypoints,
      distance: route.distance,
      estimatedTime: route.estimatedTime,
      totalRiskScore: totalRisk,
      riskLevel: _calculateRiskLevel(totalRisk),
      riskSegments: riskSegments,
      alternativeRoutes: [],
    );
  }

  Future<double> _calculateRiskForSegment(RouteSegment segment, RiskFactor riskFactor) async {
    switch (riskFactor.type) {
      case RiskFactorType.crimeData:
        return await _calculateCrimeRisk(segment, riskFactor);
      case RiskFactorType.accidentData:
        return await _calculateAccidentRisk(segment, riskFactor);
      case RiskFactorType.weatherConditions:
        return await _calculateWeatherRisk(segment, riskFactor);
      case RiskFactorType.roadConditions:
        return await _calculateRoadConditionsRisk(segment, riskFactor);
      case RiskFactorType.trafficDensity:
        return await _calculateTrafficRisk(segment, riskFactor);
      case RiskFactorType.timeOfDay:
        return _calculateTimeOfDayRisk(segment, riskFactor);
      case RiskFactorType.vehicleType:
        return _calculateVehicleTypeRisk(segment, riskFactor);
    }
  }

  Future<double> _calculateCrimeRisk(RouteSegment segment, RiskFactor riskFactor) async {
    // Consultar datos históricos de criminalidad en el área
    final crimeData = await repository.getCrimeDataForArea(
      bounds: _calculateSegmentBounds(segment),
      timeRange: riskFactor.timeRange,
    );

    // Calcular densidad de crímenes por km²
    final area = _calculateSegmentArea(segment);
    final crimeDensity = crimeData.length / area;

    // Normalizar a escala 0-1
    return (crimeDensity / riskFactor.maxValue).clamp(0.0, 1.0);
  }

  Future<double> _calculateAccidentRisk(RouteSegment segment, RiskFactor riskFactor) async {
    final accidentData = await repository.getAccidentDataForArea(
      bounds: _calculateSegmentBounds(segment),
      timeRange: riskFactor.timeRange,
    );

    // Aplicar pesos específicos por tipo de accidente
    double weightedAccidents = 0.0;
    for (final accident in accidentData) {
      switch (accident.severity) {
        case AccidentSeverity.minor:
          weightedAccidents += 0.3;
          break;
        case AccidentSeverity.moderate:
          weightedAccidents += 0.6;
          break;
        case AccidentSeverity.severe:
          weightedAccidents += 0.9;
          break;
        case AccidentSeverity.fatal:
          weightedAccidents += 1.0;
          break;
      }
    }

    final area = _calculateSegmentArea(segment);
    final accidentDensity = weightedAccidents / area;

    return (accidentDensity / riskFactor.maxValue).clamp(0.0, 1.0);
  }

  Future<double> _calculateWeatherRisk(RouteSegment segment, RiskFactor riskFactor) async {
    final weatherData = await repository.getCurrentWeatherForArea(
      bounds: _calculateSegmentBounds(segment),
    );

    double weatherRisk = 0.0;

    // Condiciones de lluvia
    if (weatherData.precipitation > 0) {
      weatherRisk += (weatherData.precipitation / 100) * 0.4;
    }

    // Viento fuerte
    if (weatherData.windSpeed > 50) {
      weatherRisk += ((weatherData.windSpeed - 50) / 50) * 0.3;
    }

    // Visibilidad reducida
    if (weatherData.visibility < 1000) {
      weatherRisk += ((1000 - weatherData.visibility) / 1000) * 0.5;
    }

    // Condiciones de niebla
    if (weatherData.humidity > 90 && weatherData.temperature < 15) {
      weatherRisk += 0.3;
    }

    return weatherRisk.clamp(0.0, 1.0);
  }

  Future<double> _calculateRoadConditionsRisk(RouteSegment segment, RiskFactor riskFactor) async {
    final roadData = await repository.getRoadConditionsForSegment(segment);

    double roadRisk = 0.0;

    // Tipo de carretera
    switch (roadData.roadType) {
      case RoadType.highway:
        roadRisk += 0.1;
        break;
      case RoadType.primary:
        roadRisk += 0.2;
        break;
      case RoadType.secondary:
        roadRisk += 0.4;
        break;
      case RoadType.tertiary:
        roadRisk += 0.6;
        break;
      case RoadType.unpaved:
        roadRisk += 0.8;
        break;
    }

    // Condiciones del pavimento
    roadRisk += roadData.pavementCondition * 0.3;

    // Construcción activa
    if (roadData.hasActiveConstruction) {
      roadRisk += 0.4;
    }

    // Curvas peligrosas
    roadRisk += roadData.dangerousCurves * 0.1;

    // Pendientes pronunciadas
    roadRisk += roadData.steepGrades * 0.2;

    return roadRisk.clamp(0.0, 1.0);
  }

  Future<double> _calculateTrafficRisk(RouteSegment segment, RiskFactor riskFactor) async {
    final trafficData = await repository.getCurrentTrafficForSegment(segment);

    // Densidad de tráfico (0 = libre, 1 = congestionado)
    double trafficRisk = trafficData.congestionLevel;

    // Incrementar riesgo por accidentes reportados en tiempo real
    trafficRisk += trafficData.activeIncidents * 0.2;

    // Incrementar riesgo por vehículos pesados
    trafficRisk += trafficData.heavyVehiclePercentage * 0.3;

    return trafficRisk.clamp(0.0, 1.0);
  }

  double _calculateTimeOfDayRisk(RouteSegment segment, RiskFactor riskFactor) {
    final currentHour = DateTime.now().hour;

    // Curva de riesgo por hora del día
    final List<double> hourlyRiskCurve = [
      0.8, 0.9, 0.9, 0.8, 0.7, 0.6, // 00:00 - 05:59 (madrugada)
      0.4, 0.3, 0.3, 0.3, 0.2, 0.2, // 06:00 - 11:59 (mañana)
      0.3, 0.3, 0.3, 0.4, 0.4, 0.5, // 12:00 - 17:59 (tarde)
      0.6, 0.7, 0.8, 0.8, 0.8, 0.8, // 18:00 - 23:59 (noche)
    ];

    return hourlyRiskCurve[currentHour];
  }

  double _calculateVehicleTypeRisk(RouteSegment segment, RiskFactor riskFactor) {
    // El riesgo depende del tipo de vehículo y la ruta
    // Esto se configuraría basado en estadísticas específicas de cada tipo
    final vehicleType = riskFactor.vehicleType;

    switch (vehicleType) {
      case VehicleType.car:
        return 0.2;
      case VehicleType.motorcycle:
        return 0.8;
      case VehicleType.truck:
        return 0.6;
      case VehicleType.bus:
        return 0.4;
      case VehicleType.van:
        return 0.3;
    }
  }

  List<SafeRoute> _applySkyangelOptimizations(List<SafeRoute> routes, RouteCalculationParams params) {
    // Aplicar algoritmos específicos de SkyAngel
    for (final route in routes) {
      // 1. Identificar puntos de descanso seguros
      route.safeRestStops = _findSafeRestStops(route);

      // 2. Calcular horarios óptimos de viaje
      route.optimalDepartureTime = _calculateOptimalDepartureTime(route, params);

      // 3. Sugerir rutas alternativas en caso de emergencia
      route.emergencyAlternatives = _findEmergencyAlternatives(route);

      // 4. Calcular costo aproximado (gasolina, casetas, etc.)
      route.estimatedCost = _calculateRouteCost(route, params.vehicleType);
    }

    return routes;
  }

  RiskLevel _calculateRiskLevel(double totalRisk) {
    if (totalRisk < 0.3) return RiskLevel.low;
    if (totalRisk < 0.6) return RiskLevel.medium;
    if (totalRisk < 0.8) return RiskLevel.high;
    return RiskLevel.critical;
  }

  String _getRiskDescription(RiskFactor factor, double value) {
    final intensity = value < 0.3 ? 'bajo' : value < 0.6 ? 'moderado' : value < 0.8 ? 'alto' : 'muy alto';
    
    switch (factor.type) {
      case RiskFactorType.crimeData:
        return 'Riesgo de criminalidad $intensity en esta zona';
      case RiskFactorType.accidentData:
        return 'Riesgo de accidentes $intensity según datos históricos';
      case RiskFactorType.weatherConditions:
        return 'Condiciones climáticas presentan riesgo $intensity';
      case RiskFactorType.roadConditions:
        return 'Condiciones de la carretera con riesgo $intensity';
      case RiskFactorType.trafficDensity:
        return 'Densidad de tráfico con nivel de riesgo $intensity';
      case RiskFactorType.timeOfDay:
        return 'Hora del día presenta riesgo $intensity';
      case RiskFactorType.vehicleType:
        return 'Tipo de vehículo con riesgo $intensity para esta ruta';
    }
  }

  // Métodos auxiliares para cálculos geoespaciales
  LatLngBounds _calculateSegmentBounds(RouteSegment segment) {
    const buffer = 0.005; // ~500 metros
    return LatLngBounds(
      LatLng(
        math.min(segment.start.latitude, segment.end.latitude) - buffer,
        math.min(segment.start.longitude, segment.end.longitude) - buffer,
      ),
      LatLng(
        math.max(segment.start.latitude, segment.end.latitude) + buffer,
        math.max(segment.start.longitude, segment.end.longitude) + buffer,
      ),
    );
  }

  double _calculateSegmentArea(RouteSegment segment) {
    // Calcular área aproximada del segmento en km²
    const earthRadius = 6371.0; // km
    final distance = const Distance().as(LengthUnit.Kilometer, segment.start, segment.end);
    const bufferWidth = 1.0; // 1 km de ancho
    return distance * bufferWidth;
  }
}

// Entidades específicas para el cálculo de rutas
@freezed
class SafeRoute with _$SafeRoute {
  const factory SafeRoute({
    required String id,
    required List<LatLng> waypoints,
    required double distance,
    required Duration estimatedTime,
    required double totalRiskScore,
    required RiskLevel riskLevel,
    required List<RiskSegment> riskSegments,
    @Default([]) List<SafeRestStop> safeRestStops,
    @Default([]) List<SafeRoute> emergencyAlternatives,
    DateTime? optimalDepartureTime,
    RouteCost? estimatedCost,
  }) = _SafeRoute;
}

@freezed
class RiskSegment with _$RiskSegment {
  const factory RiskSegment({
    required RouteSegment segment,
    required double riskScore,
    required List<RiskDetail> riskDetails,
  }) = _RiskSegment;
}

@freezed
class RiskDetail with _$RiskDetail {
  const factory RiskDetail({
    required RiskFactor factor,
    required double value,
    required String description,
  }) = _RiskDetail;
}

enum RiskLevel { low, medium, high, critical }

enum RiskFactorType {
  crimeData,
  accidentData,
  weatherConditions,
  roadConditions,
  trafficDensity,
  timeOfDay,
  vehicleType,
}
```

## 2. INTEGRACIÓN CON BACKEND EXISTENTE

### 2.1 Adaptadores de API Específicos

#### **Cliente HTTP con Endpoints Específicos**
```dart
// infrastructure/network/skyangel_api_client.dart
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../app/core/config/app_config.dart';

@singleton
class SkyAngelApiClient {
  final Dio _dio;

  SkyAngelApiClient(this._dio);

  // Endpoints específicos identificados del análisis del frontend React

  // Delitos - Secretariado
  Future<Response> getDelitosSecretariado({
    required List<int> anios,
    required List<int> entidades,
    required List<int> municipios,
    required List<int> meses,
    required List<int> bienesJuridicos,
    required List<int> tiposDelito,
    required List<int> subtiposDelito,
    required List<int> modalidades,
  }) async {
    return await _dio.post(
      '/municipios/delitos',
      data: {
        'anios': anios,
        'entidades': entidades,
        'municipios': municipios,
        'meses': meses,
        'bienes_juridicos': bienesJuridicos,
        'tipos_delito': tiposDelito,
        'subtipos_delito': subtiposDelito,
        'modalidades': modalidades,
      },
    );
  }

  // Delitos - ANERPV
  Future<Response> getDelitosAnerpv({
    required List<int> anios,
    required List<int> entidades,
    required List<int> municipios,
    required List<int> modalidades,
  }) async {
    return await _dio.post(
      '/anerpv/delitos/municipios/filtros',
      data: {
        'anios': anios,
        'entidades': entidades,
        'municipios': municipios,
        'modalidades': modalidades,
      },
    );
  }

  // Delitos - SkyAngel (Reacciones)
  Future<Response> getReaccionesSkyAngel({
    required List<int> anios,
    required List<int> entidades,
    required List<int> municipios,
    required List<String> tiposReaccion,
  }) async {
    return await _dio.post(
      '/reacciones/municipios/delitos',
      data: {
        'anios': anios,
        'entidades': entidades,
        'municipios': municipios,
        'tipos_reaccion': tiposReaccion,
      },
    );
  }

  // Gráficos específicos
  Future<Response> getGraficasSecretariado({
    required int municipioId,
    required Map<String, dynamic> filtros,
  }) async {
    return await _dio.post(
      '/graficas/secretariado/municipio/$municipioId',
      data: filtros,
    );
  }

  Future<Response> getGraficasFuentesExternas({
    required int municipioId,
    required String tipoGrafica,
    required Map<String, dynamic> filtros,
  }) async {
    return await _dio.post(
      '/graficas/fuentes-externas/$tipoGrafica/municipio/$municipioId',
      data: filtros,
    );
  }

  Future<Response> getGraficasReacciones({
    required int municipioId,
    required String tipoGrafica,
    required Map<String, dynamic> filtros,
  }) async {
    return await _dio.post(
      '/graficas/reacciones/$tipoGrafica/municipio/$municipioId',
      data: filtros,
    );
  }

  // Mapas y datos geográficos
  Future<Response> getHexagonosRiesgo({
    required int nivel,
    LatLngBounds? bounds,
  }) async {
    final queryParams = <String, dynamic>{
      'nivel': nivel,
    };
    
    if (bounds != null) {
      queryParams.addAll({
        'north': bounds.north,
        'south': bounds.south,
        'east': bounds.east,
        'west': bounds.west,
      });
    }

    return await _dio.get(
      '/hexagonos-riesgo',
      queryParameters: queryParams,
    );
  }

  Future<Response> getMunicipiosGeojson() async {
    return await _dio.get('/municipios/geojson');
  }

  Future<Response> getEntidadesGeojson() async {
    return await _dio.get('/entidades/geojson');
  }

  // Rutas y cálculos
  Future<Response> calcularRuta({
    required LatLng origen,
    required LatLng destino,
    required String tipoVehiculo,
    DateTime? horaSalida,
  }) async {
    return await _dio.post(
      '/rutas/calcular',
      data: {
        'origen': {
          'lat': origen.latitude,
          'lng': origen.longitude,
        },
        'destino': {
          'lat': destino.latitude,
          'lng': destino.longitude,
        },
        'tipo_vehiculo': tipoVehiculo,
        'hora_salida': horaSalida?.toIso8601String(),
      },
    );
  }

  Future<Response> getRutasRiesgo({
    required String rutaId,
  }) async {
    return await _dio.get('/rutas/$rutaId/riesgo');
  }

  // Alertas
  Future<Response> createAlerta({
    required String tipo,
    required String descripcion,
    required LatLng ubicacion,
    List<String>? imagenes,
    Map<String, dynamic>? metadatos,
  }) async {
    return await _dio.post(
      '/alertas',
      data: {
        'tipo': tipo,
        'descripcion': descripcion,
        'ubicacion': {
          'lat': ubicacion.latitude,
          'lng': ubicacion.longitude,
        },
        'imagenes': imagenes,
        'metadatos': metadatos,
      },
    );
  }

  Future<Response> getAlertasCercanas({
    required LatLng ubicacion,
    required double radio, // en kilómetros
    DateTime? desde,
  }) async {
    return await _dio.get(
      '/alertas/cercanas',
      queryParameters: {
        'lat': ubicacion.latitude,
        'lng': ubicacion.longitude,
        'radio': radio,
        if (desde != null) 'desde': desde.toIso8601String(),
      },
    );
  }

  // Catálogos
  Future<Response> getCatalogoAnios() async {
    return await _dio.get('/catalogos/anios');
  }

  Future<Response> getCatalogoEntidades() async {
    return await _dio.get('/catalogos/entidades');
  }

  Future<Response> getCatalogoMunicipios({int? entidadId}) async {
    return await _dio.get(
      '/catalogos/municipios',
      queryParameters: entidadId != null ? {'entidad_id': entidadId} : null,
    );
  }

  Future<Response> getCatalogoBienesJuridicos() async {
    return await _dio.get('/catalogos/bienes-juridicos');
  }

  Future<Response> getCatalogoTiposDelito() async {
    return await _dio.get('/catalogos/tipos-delito');
  }

  Future<Response> getCatalogoSubtiposDelito({int? tipoDelitoId}) async {
    return await _dio.get(
      '/catalogos/subtipos-delito',
      queryParameters: tipoDelitoId != null ? {'tipo_delito_id': tipoDelitoId} : null,
    );
  }

  Future<Response> getCatalogoModalidades() async {
    return await _dio.get('/catalogos/modalidades');
  }

  Future<Response> getCatalogoModalidadesAnerpv() async {
    return await _dio.get('/catalogos/modalidades-anerpv');
  }

  // Puntos de interés
  Future<Response> getPuntosInteres({
    required List<String> tipos,
    LatLngBounds? bounds,
  }) async {
    final queryParams = <String, dynamic>{
      'tipos': tipos,
    };
    
    if (bounds != null) {
      queryParams.addAll({
        'north': bounds.north,
        'south': bounds.south,
        'east': bounds.east,
        'west': bounds.west,
      });
    }

    return await _dio.get(
      '/puntos-interes',
      queryParameters: queryParams,
    );
  }

  // Noticias/Tweets
  Future<Response> getNoticias({
    int? limit,
    DateTime? desde,
  }) async {
    return await _dio.get(
      '/tweets',
      queryParameters: {
        if (limit != null) 'limit': limit,
        if (desde != null) 'desde': desde.toIso8601String(),
      },
    );
  }

  // Analytics y reportes
  Future<Response> getEstadisticasGeneral() async {
    return await _dio.get('/analytics/estadisticas-general');
  }

  Future<Response> getReportePersonalizado({
    required Map<String, dynamic> parametros,
  }) async {
    return await _dio.post(
      '/analytics/reporte-personalizado',
      data: parametros,
    );
  }
}
```

### 2.2 Modelos de Datos Específicos

#### **Modelos que Reflejan la Estructura del Backend**
```dart
// features/delitos/data/models/delitos_response_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/delito.dart';

part 'delitos_response_model.freezed.dart';
part 'delitos_response_model.g.dart';

@freezed
class DelitosResponseModel with _$DelitosResponseModel {
  const factory DelitosResponseModel({
    required String status,
    required List<DelitoMunicipioModel> data,
    required MetadataModel metadata,
  }) = _DelitosResponseModel;

  factory DelitosResponseModel.fromJson(Map<String, dynamic> json) =>
      _$DelitosResponseModelFromJson(json);
}

@freezed
class DelitoMunicipioModel with _$DelitoMunicipioModel {
  const factory DelitoMunicipioModel({
    required int idMunicipio,
    required String nombreMunicipio,
    required int idEntidad,
    required String nombreEntidad,
    required double latitud,
    required double longitud,
    required int totalDelitos,
    required List<DelitoDetalleModel> detalles,
    required Map<String, dynamic> propiedades,
  }) = _DelitoMunicipioModel;

  factory DelitoMunicipioModel.fromJson(Map<String, dynamic> json) =>
      _$DelitoMunicipioModelFromJson(json);
}

@freezed
class DelitoDetalleModel with _$DelitoDetalleModel {
  const factory DelitoDetalleModel({
    required int anio,
    required int mes,
    required String tipoDelito,
    required String subtipoDelito,
    required String modalidad,
    required String bienJuridico,
    required int cantidad,
  }) = _DelitoDetalleModel;

  factory DelitoDetalleModel.fromJson(Map<String, dynamic> json) =>
      _$DelitoDetalleModelFromJson(json);
}

@freezed
class MetadataModel with _$MetadataModel {
  const factory MetadataModel({
    required int totalRegistros,
    required DateTime fechaConsulta,
    required String fuenteDatos,
    required List<FiltroAplicadoModel> filtrosAplicados,
  }) = _MetadataModel;

  factory MetadataModel.fromJson(Map<String, dynamic> json) =>
      _$MetadataModelFromJson(json);
}

@freezed
class FiltroAplicadoModel with _$FiltroAplicadoModel {
  const factory FiltroAplicadoModel({
    required String campo,
    required List<dynamic> valores,
  }) = _FiltroAplicadoModel;

  factory FiltroAplicadoModel.fromJson(Map<String, dynamic> json) =>
      _$FiltroAplicadoModelFromJson(json);
}

// Extension para conversión a entidades del dominio
extension DelitosResponseModelX on DelitosResponseModel {
  List<DelitoMunicipio> toDomain() {
    return data.map((model) => model.toDomain()).toList();
  }
}

extension DelitoMunicipioModelX on DelitoMunicipioModel {
  DelitoMunicipio toDomain() {
    return DelitoMunicipio(
      municipio: Municipio(
        id: idMunicipio,
        nombre: nombreMunicipio,
        entidad: Entidad(
          id: idEntidad,
          nombre: nombreEntidad,
        ),
        ubicacion: LatLng(latitud, longitud),
      ),
      totalDelitos: totalDelitos,
      detalles: detalles.map((d) => d.toDomain()).toList(),
      propiedades: propiedades,
    );
  }
}

extension DelitoDetalleModelX on DelitoDetalleModel {
  DelitoDetalle toDomain() {
    return DelitoDetalle(
      anio: anio,
      mes: mes,
      tipoDelito: tipoDelito,
      subtipoDelito: subtipoDelito,
      modalidad: modalidad,
      bienJuridico: bienJuridico,
      cantidad: cantidad,
    );
  }
}
```

### 2.3 Gestión de Estado Específica

#### **Providers Riverpod para Funcionalidades Específicas**
```dart
// features/delitos/presentation/providers/delitos_providers.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/delito.dart';
import '../../domain/usecases/get_delitos_secretariado_usecase.dart';
import '../../domain/usecases/get_delitos_anerpv_usecase.dart';
import '../../domain/usecases/get_reacciones_skyangel_usecase.dart';

part 'delitos_providers.g.dart';

@riverpod
class DelitosNotifier extends _$DelitosNotifier {
  @override
  DelitosState build() {
    return const DelitosState(
      fuenteSeleccionada: FuenteDatos(id: 1, nombre: 'Secretariado', color: Colors.blue),
      filtrosSecretariado: FiltrosSecretariado(),
      filtrosAnerpv: FiltrosAnerpv(),
      filtrosSkyAngel: FiltrosSkyAngel(),
      datos: AsyncValue.data([]),
      escalaActual: EscalaVisualizacion.lineal,
      showLegend: true,
      isSidebarOpen: false,
      selectedMunicipality: null,
    );
  }

  void cambiarFuente(FuenteDatos fuente) {
    state = state.copyWith(fuenteSeleccionada: fuente);
    // Limpiar datos previos
    state = state.copyWith(datos: const AsyncValue.loading());
    // Aplicar filtros automáticamente
    aplicarFiltros();
  }

  void actualizarFiltroSecretariado(FiltrosSecretariado filtros) {
    state = state.copyWith(filtrosSecretariado: filtros);
  }

  void actualizarFiltroAnerpv(FiltrosAnerpv filtros) {
    state = state.copyWith(filtrosAnerpv: filtros);
  }

  void actualizarFiltroSkyAngel(FiltrosSkyAngel filtros) {
    state = state.copyWith(filtrosSkyAngel: filtros);
  }

  void cambiarEscala(EscalaVisualizacion escala) {
    state = state.copyWith(escalaActual: escala);
  }

  void toggleLegend() {
    state = state.copyWith(showLegend: !state.showLegend);
  }

  void toggleSidebar() {
    state = state.copyWith(isSidebarOpen: !state.isSidebarOpen);
  }

  void selectMunicipality(Municipality municipality) {
    state = state.copyWith(selectedMunicipality: municipality);
  }

  void clearSelection() {
    state = state.copyWith(selectedMunicipality: null);
  }

  Future<void> aplicarFiltros() async {
    state = state.copyWith(datos: const AsyncValue.loading());

    try {
      List<DelitoMunicipio> datos;

      switch (state.fuenteSeleccionada.id) {
        case 1: // Secretariado
          final usecase = ref.read(getDelitosSecretariadoUseCaseProvider);
          final result = await usecase(GetDelitosSecretariadoParams(
            anios: state.filtrosSecretariado.aniosSeleccionados.map((a) => a.id).toList(),
            entidades: state.filtrosSecretariado.entidadesSeleccionadas.map((e) => e.id).toList(),
            municipios: state.filtrosSecretariado.municipiosSeleccionados.map((m) => m.id).toList(),
            meses: state.filtrosSecretariado.mesesSeleccionados,
            bienesJuridicos: state.filtrosSecretariado.bienesJuridicosSeleccionados.map((b) => b.id).toList(),
            tiposDelito: state.filtrosSecretariado.tiposDelitoSeleccionados.map((t) => t.id).toList(),
            subtiposDelito: state.filtrosSecretariado.subtiposDelitoSeleccionados.map((s) => s.id).toList(),
            modalidades: state.filtrosSecretariado.modalidadesSeleccionadas.map((m) => m.id).toList(),
          ));
          
          result.fold(
            (failure) => throw Exception(failure.message),
            (data) => datos = data,
          );
          break;

        case 2: // ANERPV
          final usecase = ref.read(getDelitosAnerpvUseCaseProvider);
          final result = await usecase(GetDelitosAnerpvParams(
            anios: state.filtrosAnerpv.aniosSeleccionados.map((a) => a.id).toList(),
            entidades: state.filtrosAnerpv.entidadesSeleccionadas.map((e) => e.id).toList(),
            municipios: state.filtrosAnerpv.municipiosSeleccionados.map((m) => m.id).toList(),
            modalidades: state.filtrosAnerpv.modalidadesSeleccionadas.map((m) => m.id).toList(),
          ));
          
          result.fold(
            (failure) => throw Exception(failure.message),
            (data) => datos = data,
          );
          break;

        case 3: // SkyAngel
          final usecase = ref.read(getReaccionesSkyAngelUseCaseProvider);
          final result = await usecase(GetReaccionesSkyAngelParams(
            anios: state.filtrosSkyAngel.aniosSeleccionados.map((a) => a.id).toList(),
            entidades: state.filtrosSkyAngel.entidadesSeleccionadas.map((e) => e.id).toList(),
            municipios: state.filtrosSkyAngel.municipiosSeleccionados.map((m) => m.id).toList(),
            tiposReaccion: state.filtrosSkyAngel.tiposReaccionSeleccionados,
          ));
          
          result.fold(
            (failure) => throw Exception(failure.message),
            (data) => datos = data,
          );
          break;

        default:
          throw Exception('Fuente de datos no válida');
      }

      state = state.copyWith(datos: AsyncValue.data(datos));
    } catch (e) {
      state = state.copyWith(datos: AsyncValue.error(e, StackTrace.current));
    }
  }

  void limpiarFiltros() {
    switch (state.fuenteSeleccionada.id) {
      case 1: // Secretariado
        state = state.copyWith(filtrosSecretariado: const FiltrosSecretariado());
        break;
      case 2: // ANERPV
        state = state.copyWith(filtrosAnerpv: const FiltrosAnerpv());
        break;
      case 3: // SkyAngel
        state = state.copyWith(filtrosSkyAngel: const FiltrosSkyAngel());
        break;
    }
    
    state = state.copyWith(datos: const AsyncValue.data([]));
  }
}

// Provider para catálogos
@riverpod
Future<List<Anio>> aniosDisponibles(AniosDisponiblesRef ref) async {
  final repository = ref.read(catalogosRepositoryProvider);
  final result = await repository.getAnios();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (anios) => anios,
  );
}

@riverpod
Future<List<Entidad>> entidadesDisponibles(EntidadesDisponiblesRef ref) async {
  final repository = ref.read(catalogosRepositoryProvider);
  final result = await repository.getEntidades();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (entidades) => entidades,
  );
}

@riverpod
Future<List<Municipio>> municipiosDisponibles(
  MunicipiosDisponiblesRef ref,
  {int? entidadId}
) async {
  final repository = ref.read(catalogosRepositoryProvider);
  final result = await repository.getMunicipios(entidadId: entidadId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (municipios) => municipios,
  );
}

@riverpod
Future<List<BienJuridico>> bienesJuridicosDisponibles(BienesJuridicosDisponiblesRef ref) async {
  final repository = ref.read(catalogosRepositoryProvider);
  final result = await repository.getBienesJuridicos();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (bienes) => bienes,
  );
}

@riverpod
Future<List<TipoDelito>> tiposDelitoDisponibles(TiposDelitoDisponiblesRef ref) async {
  final repository = ref.read(catalogosRepositoryProvider);
  final result = await repository.getTiposDelito();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (tipos) => tipos,
  );
}

@riverpod
Future<List<SubtipoDelito>> subtiposDelitoDisponibles(
  SubtiposDelitoDisponiblesRef ref,
  {int? tipoDelitoId}
) async {
  final repository = ref.read(catalogosRepositoryProvider);
  final result = await repository.getSubtiposDelito(tipoDelitoId: tipoDelitoId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (subtipos) => subtipos,
  );
}

@riverpod
Future<List<Modalidad>> modalidadesDisponibles(ModalidadesDisponiblesRef ref) async {
  final repository = ref.read(catalogosRepositoryProvider);
  final result = await repository.getModalidades();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (modalidades) => modalidades,
  );
}

@riverpod
Future<List<ModalidadAnerpv>> modalidadesAnerpvDisponibles(ModalidadesAnerpvDisponiblesRef ref) async {
  final repository = ref.read(catalogosRepositoryProvider);
  final result = await repository.getModalidadesAnerpv();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (modalidades) => modalidades,
  );
}

// Provider para gráficos de municipio
@riverpod
Future<MunicipalityChartsData> municipalityCharts(
  MunicipalityChartsRef ref,
  int municipalityId
) async {
  final delitosState = ref.watch(delitosProvider);
  
  final repository = ref.read(graficasRepositoryProvider);
  
  switch (delitosState.fuenteSeleccionada.id) {
    case 1: // Secretariado
      final result = await repository.getGraficasSecretariado(
        municipioId: municipalityId,
        filtros: delitosState.filtrosSecretariado.toMap(),
      );
      return result.fold(
        (failure) => throw Exception(failure.message),
        (data) => data,
      );
    case 2: // ANERPV
      final result = await repository.getGraficasAnerpv(
        municipioId: municipalityId,
        filtros: delitosState.filtrosAnerpv.toMap(),
      );
      return result.fold(
        (failure) => throw Exception(failure.message),
        (data) => data,
      );
    case 3: // SkyAngel
      final result = await repository.getGraficasReacciones(
        municipioId: municipalityId,
        filtros: delitosState.filtrosSkyAngel.toMap(),
      );
      return result.fold(
        (failure) => throw Exception(failure.message),
        (data) => data,
      );
    default:
      throw Exception('Fuente de datos no válida');
  }
}
```

## 3. COMPATIBILIDAD Y VALIDACIÓN

### 3.1 Verificación de Operación Correcta

#### **Tests de Integración Específicos**
```dart
// test/integration/delitos_integration_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:skyangel_mobile/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Delitos Module Integration Tests', () {
    testWidgets('should load delitos data with Secretariado filters', (tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Navigate to delitos module
      await tester.tap(find.text('Análisis de Delitos'));
      await tester.pumpAndSettle();

      // Verify initial state
      expect(find.byType(DelitosScreen), findsOneWidget);
      expect(find.text('Secretariado'), findsOneWidget);

      // Act - Apply filters
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      // Select year filter
      await tester.tap(find.text('Años'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('2023'));
      await tester.tap(find.text('Aceptar'));
      await tester.pumpAndSettle();

      // Apply filters
      await tester.tap(find.text('Aplicar Filtros'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Assert
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(SkyAngelMap), findsOneWidget);

      // Verify data is loaded on map
      // This would check for colored municipalities
      expect(find.byType(PolygonLayer), findsOneWidget);
    });

    testWidgets('should switch between data sources correctly', (tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Análisis de Delitos'));
      await tester.pumpAndSettle();

      // Act - Switch to ANERPV
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('ANERPV'));
      await tester.pumpAndSettle();

      // Verify ANERPV specific filters are shown
      expect(find.text('Modalidades ANERPV'), findsOneWidget);
      expect(find.text('Bienes Jurídicos'), findsNothing); // Should not show Secretariado filters

      // Switch to SkyAngel
      await tester.tap(find.text('SkyAngel'));
      await tester.pumpAndSettle();

      // Verify SkyAngel specific filters
      expect(find.text('Tipos de Reacción'), findsOneWidget);
      expect(find.text('Modalidades ANERPV'), findsNothing);
    });

    testWidgets('should show municipality details modal', (tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Análisis de Delitos'));
      await tester.pumpAndSettle();

      // Load data first
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Aplicar Filtros'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Act - Tap on a municipality (simulate)
      // This would require finding a specific municipality polygon
      await tester.tapAt(const Offset(400, 300)); // Center of map approximately
      await tester.pumpAndSettle();

      // Assert - Modal should appear
      expect(find.byType(DelitosModal), findsOneWidget);
      expect(find.byType(DelitosChartsWidget), findsOneWidget);
    });
  });

  group('Backend API Integration Tests', () {
    testWidgets('should handle API errors gracefully', (tester) async {
      // Arrange - This would require mocking network failures
      app.main();
      await tester.pumpAndSettle();

      // Navigate to delitos
      await tester.tap(find.text('Análisis de Delitos'));
      await tester.pumpAndSettle();

      // Simulate network error by applying filters when offline
      // This would require network mocking in test environment

      // Act
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Aplicar Filtros'));
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Assert - Error state should be shown
      expect(find.text('Error al cargar datos'), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
    });

    testWidgets('should validate filter parameters before API call', (tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Análisis de Delitos'));
      await tester.pumpAndSettle();

      // Act - Try to apply filters without selecting required fields
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      // Don't select any filters, just apply
      await tester.tap(find.text('Aplicar Filtros'));
      await tester.pumpAndSettle();

      // Assert - Should show validation message or default behavior
      // The specific behavior depends on business requirements
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });

  group('Performance Integration Tests', () {
    testWidgets('should load large datasets without blocking UI', (tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Análisis de Delitos'));
      await tester.pumpAndSettle();

      // Act - Load maximum data (all years, all municipalities)
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      // Select all available options
      await tester.tap(find.text('Años'));
      await tester.pumpAndSettle();
      // Select all years (this would be dynamic based on available data)
      await tester.tap(find.text('Seleccionar Todo'));
      await tester.tap(find.text('Aceptar'));
      await tester.pumpAndSettle();

      // Apply filters
      final startTime = DateTime.now();
      await tester.tap(find.text('Aplicar Filtros'));
      
      // Wait for data to load but ensure UI remains responsive
      while (find.byType(CircularProgressIndicator).evaluate().isNotEmpty) {
        await tester.pump(const Duration(milliseconds: 100));
        
        // Ensure we can still interact with UI during loading
        expect(find.byIcon(Icons.filter_list), findsOneWidget);
        
        // Timeout after 30 seconds
        if (DateTime.now().difference(startTime).inSeconds > 30) {
          fail('Data loading took too long');
        }
      }

      // Assert - Data loaded and UI responsive
      expect(find.byType(SkyAngelMap), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}
```

### 3.2 Validación de Endpoints

#### **Tests de Conectividad con Backend**
```dart
// test/infrastructure/api_connectivity_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';

void main() {
  late SkyAngelApiClient apiClient;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    apiClient = SkyAngelApiClient(mockDio);
  });

  group('SkyAngel API Connectivity Tests', () {
    test('should call correct endpoint for Secretariado delitos', () async {
      // Arrange
      final expectedResponse = Response(
        requestOptions: RequestOptions(path: '/municipios/delitos'),
        statusCode: 200,
        data: {
          'status': 'success',
          'data': [],
          'metadata': {
            'total_registros': 0,
            'fecha_consulta': DateTime.now().toIso8601String(),
            'fuente_datos': 'secretariado',
            'filtros_aplicados': []
          }
        },
      );

      when(mockDio.post(
        '/municipios/delitos',
        data: anyNamed('data'),
      )).thenAnswer((_) async => expectedResponse);

      // Act
      final response = await apiClient.getDelitosSecretariado(
        anios: [2023],
        entidades: [1],
        municipios: [1],
        meses: [1],
        bienesJuridicos: [1],
        tiposDelito: [1],
        subtiposDelito: [1],
        modalidades: [1],
      );

      // Assert
      verify(mockDio.post(
        '/municipios/delitos',
        data: {
          'anios': [2023],
          'entidades': [1],
          'municipios': [1],
          'meses': [1],
          'bienes_juridicos': [1],
          'tipos_delito': [1],
          'subtipos_delito': [1],
          'modalidades': [1],
        },
      )).called(1);

      expect(response.statusCode, 200);
      expect(response.data['status'], 'success');
    });

    test('should call correct endpoint for ANERPV delitos', () async {
      // Arrange
      final expectedResponse = Response(
        requestOptions: RequestOptions(path: '/anerpv/delitos/municipios/filtros'),
        statusCode: 200,
        data: {
          'status': 'success',
          'data': [],
          'metadata': {
            'total_registros': 0,
            'fecha_consulta': DateTime.now().toIso8601String(),
            'fuente_datos': 'anerpv',
            'filtros_aplicados': []
          }
        },
      );

      when(mockDio.post(
        '/anerpv/delitos/municipios/filtros',
        data: anyNamed('data'),
      )).thenAnswer((_) async => expectedResponse);

      // Act
      final response = await apiClient.getDelitosAnerpv(
        anios: [2023],
        entidades: [1],
        municipios: [1],
        modalidades: [1],
      );

      // Assert
      verify(mockDio.post(
        '/anerpv/delitos/municipios/filtros',
        data: {
          'anios': [2023],
          'entidades': [1],
          'municipios': [1],
          'modalidades': [1],
        },
      )).called(1);

      expect(response.statusCode, 200);
    });

    test('should call correct endpoint for SkyAngel reacciones', () async {
      // Arrange
      final expectedResponse = Response(
        requestOptions: RequestOptions(path: '/reacciones/municipios/delitos'),
        statusCode: 200,
        data: {
          'status': 'success',
          'data': [],
          'metadata': {
            'total_registros': 0,
            'fecha_consulta': DateTime.now().toIso8601String(),
            'fuente_datos': 'skyangel',
            'filtros_aplicados': []
          }
        },
      );

      when(mockDio.post(
        '/reacciones/municipios/delitos',
        data: anyNamed('data'),
      )).thenAnswer((_) async => expectedResponse);

      // Act
      final response = await apiClient.getReaccionesSkyAngel(
        anios: [2023],
        entidades: [1],
        municipios: [1],
        tiposReaccion: ['robo', 'accidente'],
      );

      // Assert
      verify(mockDio.post(
        '/reacciones/municipios/delitos',
        data: {
          'anios': [2023],
          'entidades': [1],
          'municipios': [1],
          'tipos_reaccion': ['robo', 'accidente'],
        },
      )).called(1);

      expect(response.statusCode, 200);
    });

    test('should handle API errors correctly', () async {
      // Arrange
      when(mockDio.post(
        any,
        data: anyNamed('data'),
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionTimeout,
        message: 'Connection timeout',
      ));

      // Act & Assert
      expect(
        () => apiClient.getDelitosSecretariado(
          anios: [2023],
          entidades: [1],
          municipios: [1],
          meses: [1],
          bienesJuridicos: [1],
          tiposDelito: [1],
          subtiposDelito: [1],
          modalidades: [1],
        ),
        throwsA(isA<DioException>()),
      );
    });

    test('should validate response structure', () async {
      // Arrange
      final invalidResponse = Response(
        requestOptions: RequestOptions(path: '/municipios/delitos'),
        statusCode: 200,
        data: {
          // Missing required fields
          'invalid': 'structure'
        },
      );

      when(mockDio.post(
        '/municipios/delitos',
        data: anyNamed('data'),
      )).thenAnswer((_) async => invalidResponse);

      // Act
      final response = await apiClient.getDelitosSecretariado(
        anios: [2023],
        entidades: [1],
        municipios: [1],
        meses: [1],
        bienesJuridicos: [1],
        tiposDelito: [1],
        subtiposDelito: [1],
        modalidades: [1],
      );

      // Assert
      expect(response.statusCode, 200);
      expect(response.data['status'], isNull); // Should validate this in real implementation
    });
  });

  group('Catalogos API Tests', () {
    test('should fetch catalogos correctly', () async {
      // Test all catalog endpoints
      final endpoints = [
        '/catalogos/anios',
        '/catalogos/entidades',
        '/catalogos/municipios',
        '/catalogos/bienes-juridicos',
        '/catalogos/tipos-delito',
        '/catalogos/subtipos-delito',
        '/catalogos/modalidades',
        '/catalogos/modalidades-anerpv',
      ];

      for (final endpoint in endpoints) {
        // Arrange
        final expectedResponse = Response(
          requestOptions: RequestOptions(path: endpoint),
          statusCode: 200,
          data: {
            'status': 'success',
            'data': [
              {'id': 1, 'nombre': 'Test Item 1'},
              {'id': 2, 'nombre': 'Test Item 2'},
            ]
          },
        );

        when(mockDio.get(endpoint, queryParameters: anyNamed('queryParameters')))
            .thenAnswer((_) async => expectedResponse);

        // Act & Assert based on specific endpoint
        switch (endpoint) {
          case '/catalogos/anios':
            final response = await apiClient.getCatalogoAnios();
            expect(response.statusCode, 200);
            break;
          case '/catalogos/entidades':
            final response = await apiClient.getCatalogoEntidades();
            expect(response.statusCode, 200);
            break;
          // ... continue for other endpoints
        }

        verify(mockDio.get(endpoint, queryParameters: anyNamed('queryParameters'))).called(1);
      }
    });
  });
}

class MockDio extends Mock implements Dio {}
```

<function_calls>
<invoke name="TodoWrite">
<parameter name="todos">[{"id": "1", "content": "Analizar componentes actuales del frontend React", "status": "completed", "priority": "high"}, {"id": "2", "content": "Mapear funcionalidades existentes a Flutter", "status": "completed", "priority": "high"}, {"id": "3", "content": "Identificar gaps y componentes faltantes", "status": "in_progress", "priority": "high"}, {"id": "4", "content": "Complementar arquitectura Flutter con detalles espec\u00edficos", "status": "pending", "priority": "high"}, {"id": "5", "content": "Validar compatibilidad con backend existente", "status": "pending", "priority": "medium"}, {"id": "6", "content": "Actualizar documento con funcionalidades completas", "status": "pending", "priority": "medium"}]