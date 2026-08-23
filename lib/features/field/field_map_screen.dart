import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jeevan/core/theme/app_colors.dart';
import 'package:jeevan/core/theme/app_typography.dart';
import 'package:jeevan/core/theme/app_spacing.dart';
import 'package:jeevan/core/theme/app_radius.dart';
import 'package:jeevan/domain/models/zone.dart';
import 'package:jeevan/application/field/field_provider.dart';
import 'package:jeevan/widgets/skeleton/skeleton_composites.dart';
import 'package:jeevan/widgets/states/error_state.dart';
import 'package:jeevan/widgets/app_bar/jeevan_app_bar.dart';
import 'package:jeevan/widgets/field/moisture_legend.dart';
import 'package:jeevan/widgets/status/status_badge.dart';
import 'package:jeevan/widgets/buttons/primary_button.dart';
import 'package:jeevan/data/mock/seed/mock_seed_data.dart';
import 'package:jeevan/features/field/zone_detail_screen.dart';
import 'package:jeevan/core/utils/formatters.dart';

class FieldMapScreen extends ConsumerStatefulWidget {
  const FieldMapScreen({super.key});

  @override
  ConsumerState<FieldMapScreen> createState() => _FieldMapScreenState();
}

class _FieldMapScreenState extends ConsumerState<FieldMapScreen> with SingleTickerProviderStateMixin {
  final TransformationController _transformController = TransformationController();
  late AnimationController _roverAnimController;

  @override
  void initState() {
    super.initState();
    _roverAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  @override
  void dispose() {
    _transformController.dispose();
    _roverAnimController.dispose();
    super.dispose();
  }

  void _resetView() {
    _transformController.value = Matrix4.identity();
  }

  void _showLayersSheet(Set<MapLayer> selectedLayers) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.paperBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Map Layers', style: AppTypography.headlineSmall),
                const SizedBox(height: AppSpacing.md),
                _buildLayerCheckbox(MapLayer.soilMoisture, 'Soil Moisture (Always On)', true, selectedLayers, setState),
                _buildLayerCheckbox(MapLayer.roverPath, 'Rover Path', false, selectedLayers, setState),
                _buildLayerCheckbox(MapLayer.waterZones, 'Water Distribution', false, selectedLayers, setState),
                _buildLayerCheckbox(MapLayer.cropHealth, 'Crop Health Scans', false, selectedLayers, setState),
                _buildLayerCheckbox(MapLayer.scanCoverage, 'Scan Coverage', false, selectedLayers, setState),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          );
        });
      },
    );
  }

  Widget _buildLayerCheckbox(MapLayer layer, String label, bool isAlwaysOn, Set<MapLayer> selectedLayers, StateSetter setModalState) {
    final isSelected = selectedLayers.contains(layer);
    return CheckboxListTile(
      title: Text(label, style: AppTypography.bodyLarge),
      value: isSelected,
      activeColor: AppColors.accentGreen,
      onChanged: isAlwaysOn
          ? null
          : (val) {
              final current = Set<MapLayer>.from(ref.read(selectedMapLayerProvider));
              if (val == true) {
                current.add(layer);
              } else {
                current.remove(layer);
              }
              ref.read(selectedMapLayerProvider.notifier).state = current;
              setModalState(() {});
            },
    );
  }

  void _onMapTap(TapUpDetails details, List<Zone> zones, Size canvasSize) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset localPosition = renderBox.globalToLocal(details.globalPosition);
    final Matrix4 inverse = Matrix4.inverted(_transformController.value);
    final Offset transformedPos = MatrixUtils.transformPoint(inverse, localPosition);

    for (final zone in zones) {
      
      final path = Path();
      bool first = true;
      for (final point in zone.boundaryPoints) {
        final x = point[0] * canvasSize.width;
        final y = point[1] * canvasSize.height;
        if (first) {
          path.moveTo(x, y);
          first = false;
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      if (path.contains(transformedPos)) {
        ref.read(selectedZoneProvider.notifier).state = zone.id;
        return;
      }
    }
    ref.read(selectedZoneProvider.notifier).state = null;
  }

  @override
  Widget build(BuildContext context) {
    final zonesAsync = ref.watch(zonesProvider);
    final selectedLayers = ref.watch(selectedMapLayerProvider);
    final selectedZoneId = ref.watch(selectedZoneProvider);

    return Scaffold(
      appBar: JeevanAppBar(
        title: 'Field Map',
        actions: [
          IconButton(
            icon: const Icon(Icons.layers_outlined),
            onPressed: () => _showLayersSheet(selectedLayers),
          ),
        ],
      ),
      body: zonesAsync.when(
        loading: () => const FieldMapSkeleton(),
        error: (err, stack) => ErrorState(
          message: err.toString(),
          onRetry: () => ref.refresh(zonesProvider),
        ),
        data: (zones) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
              return Stack(
                children: [
                  GestureDetector(
                    onTapUp: (details) => _onMapTap(details, zones, canvasSize),
                    child: InteractiveViewer(
                      transformationController: _transformController,
                      minScale: 0.5,
                      maxScale: 3.0,
                      boundaryMargin: const EdgeInsets.all(AppSpacing.xxl),
                      constrained: true,
                      child: AnimatedBuilder(
                        animation: _roverAnimController,
                        builder: (context, child) {
                          return CustomPaint(
                            size: canvasSize,
                            painter: FieldMapPainter(
                              zones: zones,
                              fieldBoundary: MockSeedData.fieldBoundary,
                              roverPath: MockSeedData.roverPath,
                              selectedLayers: selectedLayers,
                              selectedZoneId: selectedZoneId,
                              roverProgress: _roverAnimController.value,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: AppSpacing.md,
                    right: AppSpacing.md,
                    child: FloatingActionButton.small(
                      backgroundColor: AppColors.surfaceWhite,
                      child: const Icon(Icons.center_focus_strong, color: AppColors.textSecondary),
                      onPressed: _resetView,
                    ),
                  ),
                  const Positioned(
                    bottom: AppSpacing.md,
                    left: AppSpacing.md,
                    child: MoistureLegend(),
                  ),
                  if (selectedZoneId != null)
                    Positioned(
                      bottom: AppSpacing.md,
                      left: AppSpacing.md,
                      right: AppSpacing.md,
                      child: _SelectedZoneCard(
                        zoneId: selectedZoneId,
                        zones: zones,
                        onClose: () => ref.read(selectedZoneProvider.notifier).state = null,
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _SelectedZoneCard extends StatelessWidget {
  final String zoneId;
  final List<Zone> zones;
  final VoidCallback onClose;

  const _SelectedZoneCard({
    required this.zoneId,
    required this.zones,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final zone = zones.firstWhere((z) => z.id == zoneId);
    return Card(
      color: AppColors.surfaceWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(zone.name, style: AppTypography.headlineSmall),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  onPressed: onClose,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                StatusBadge(
                  label: '${Formatters.capitalize(zone.moistureCategory.name)} — ${zone.currentMoisturePercent.toStringAsFixed(0)}%',
                  severity: _getMoistureSeverity(zone.moistureCategory),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    Formatters.formatZoneStatus(zone.status),
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            PrimaryButton(
              label: 'View Details',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ZoneDetailScreen(zoneId: zone.id)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class FieldMapPainter extends CustomPainter {
  final List<Zone> zones;
  final List<List<double>> fieldBoundary;
  final List<List<double>> roverPath;
  final Set<MapLayer> selectedLayers;
  final String? selectedZoneId;
  final double roverProgress;

  FieldMapPainter({
    required this.zones,
    required this.fieldBoundary,
    required this.roverPath,
    required this.selectedLayers,
    required this.selectedZoneId,
    required this.roverProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawFieldBoundary(canvas, size);
    if (selectedLayers.contains(MapLayer.soilMoisture)) {
      _drawZones(canvas, size);
    }
    if (selectedLayers.contains(MapLayer.roverPath)) {
      _drawRoverPath(canvas, size);
      _drawRover(canvas, size);
    }
    if (selectedLayers.contains(MapLayer.scanCoverage)) {
      _drawScanCoverage(canvas, size);
    }
  }

  void _drawFieldBoundary(Canvas canvas, Size size) {
    if (fieldBoundary.isEmpty) return;
    final paint = Paint()
      ..color = AppColors.divider
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    bool first = true;
    for (final point in fieldBoundary) {
      final x = point[0] * size.width;
      final y = point[1] * size.height;
      if (first) {
        path.moveTo(x, y);
        first = false;
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawZones(Canvas canvas, Size size) {
    for (final zone in zones) {
      
      final isSelected = zone.id == selectedZoneId;

      final path = Path();
      bool first = true;
      double sumX = 0;
      double sumY = 0;
      for (final point in zone.boundaryPoints) {
        final x = point[0] * size.width;
        final y = point[1] * size.height;
        sumX += x;
        sumY += y;
        if (first) {
          path.moveTo(x, y);
          first = false;
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();

      final fillColor = _getZoneFillColor(zone.moistureCategory);
      final fillPaint = Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, fillPaint);

      final strokePaint = Paint()
        ..color = isSelected ? AppColors.charcoalSoil : AppColors.divider
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? 3 : 1;
      canvas.drawPath(path, strokePaint);

      // Draw label at centroid
      final cx = sumX / zone.boundaryPoints.length;
      final cy = sumY / zone.boundaryPoints.length;
      
      final label = '${zone.name}\n${Formatters.capitalize(zone.moistureCategory.name)} · ${zone.currentMoisturePercent.toStringAsFixed(0)}%';
      final textSpan = TextSpan(
        text: label,
        style: AppTypography.caption.copyWith(
          color: AppColors.charcoalSoil,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          backgroundColor: AppColors.surfaceWhite.withOpacity(0.7),
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(cx - textPainter.width / 2, cy - textPainter.height / 2));
    }
  }

  Color _getZoneFillColor(MoistureCategory category) {
    switch (category) {
      case MoistureCategory.veryLow:
        return AppColors.criticalRed.withOpacity(0.3);
      case MoistureCategory.low:
        return AppColors.warningAmber.withOpacity(0.3);
      case MoistureCategory.medium:
        return Color.lerp(AppColors.warningAmber, AppColors.accentGreen, 0.5)!.withOpacity(0.2);
      case MoistureCategory.high:
        return AppColors.accentGreen.withOpacity(0.3);
    }
  }

  void _drawRoverPath(Canvas canvas, Size size) {
    if (roverPath.isEmpty) return;
    final paint = Paint()
      ..color = AppColors.textTertiary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final path = Path();
    bool first = true;
    for (final point in roverPath) {
      final x = point[0] * size.width;
      final y = point[1] * size.height;
      if (first) {
        path.moveTo(x, y);
        first = false;
      } else {
        path.lineTo(x, y);
      }
    }
    
    // Simple dash effect
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final extract = metric.extractPath(distance, distance + 5);
        canvas.drawPath(extract, paint);
        distance += 10;
      }
    }
  }

  void _drawRover(Canvas canvas, Size size) {
    if (roverPath.isEmpty) return;
    
    final path = Path();
    bool first = true;
    for (final point in roverPath) {
      final x = point[0] * size.width;
      final y = point[1] * size.height;
      if (first) {
        path.moveTo(x, y);
        first = false;
      } else {
        path.lineTo(x, y);
      }
    }

    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final metric = metrics.first;
    
    final currentDistance = metric.length * roverProgress;
    final tangent = metric.getTangentForOffset(currentDistance);
    if (tangent == null) return;

    final pos = tangent.position;
    final angle = tangent.vector.direction;

    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(angle);

    final roverPaint = Paint()
      ..color = AppColors.waterBlue
      ..style = PaintingStyle.fill;

    final roverPathShape = Path()
      ..moveTo(10, 0)
      ..lineTo(-8, 6)
      ..lineTo(-8, -6)
      ..close();

    canvas.drawPath(roverPathShape, roverPaint);
    canvas.restore();
  }

  void _drawScanCoverage(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.waterBlue.withOpacity(0.5)
      ..style = PaintingStyle.fill;
      
    for (final point in roverPath) {
      final x = point[0] * size.width;
      final y = point[1] * size.height;
      canvas.drawCircle(Offset(x, y), 8, paint);
    }
  }

  @override
  bool shouldRepaint(covariant FieldMapPainter oldDelegate) {
    return oldDelegate.roverProgress != roverProgress ||
           oldDelegate.selectedZoneId != selectedZoneId ||
           oldDelegate.selectedLayers != selectedLayers;
  }
}

  StatusBadgeSeverity _getMoistureSeverity(MoistureCategory category) {
    switch (category) {
      case MoistureCategory.veryLow:
        return StatusBadgeSeverity.critical;
      case MoistureCategory.low:
        return StatusBadgeSeverity.warning;
      case MoistureCategory.medium:
        return StatusBadgeSeverity.neutral;
      case MoistureCategory.high:
        return StatusBadgeSeverity.success;
    }
  }
