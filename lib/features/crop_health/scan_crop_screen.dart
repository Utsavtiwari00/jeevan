import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:jeevan/core/theme/app_colors.dart';
import 'package:jeevan/core/theme/app_typography.dart';
import 'package:jeevan/core/theme/app_spacing.dart';
import 'package:jeevan/core/theme/app_radius.dart';
import 'package:jeevan/application/crop_health/crop_health_provider.dart';
import 'package:jeevan/features/crop_health/crop_analysis_screen.dart';

class ScanCropScreen extends ConsumerStatefulWidget {
  final String zoneId;

  const ScanCropScreen({super.key, this.zoneId = 'zone-a'});

  @override
  ConsumerState<ScanCropScreen> createState() => _ScanCropScreenState();
}

class _ScanCropScreenState extends ConsumerState<ScanCropScreen> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _cameraError = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _cameraError = true);
        return;
      }
      final firstCamera = cameras.first;
      _cameraController = CameraController(
        firstCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await _cameraController!.initialize();
      if (mounted) {
        setState(() => _isCameraInitialized = true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _cameraError = true);
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _captureAndAnalyze() async {
    if (ref.read(analysisStageProvider) != AnalysisStage.idle) return;
    
    // Reset stage just in case
    ref.read(analysisStageProvider.notifier).state = AnalysisStage.idle;
    
    // Proceed to analysis
    final controller = ref.read(cropAnalysisControllerProvider.notifier);
    
    try {
      final result = await controller.submitScan(widget.zoneId, 'simulated_path.jpg');
      if (result != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => CropAnalysisScreen(zoneId: widget.zoneId)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Analysis failed: $e')),
        );
        ref.read(analysisStageProvider.notifier).state = AnalysisStage.idle;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final stage = ref.watch(analysisStageProvider);
    final isAnalyzing = stage != AnalysisStage.idle;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: isAnalyzing ? _buildAnalyzingView(stage) : _buildCameraView(),
      ),
    );
  }

  Widget _buildCameraView() {
    return Stack(
      children: [
        // Camera Preview or Fallback
        Positioned.fill(
          child: _isCameraInitialized
              ? CameraPreview(_cameraController!)
              : _buildCameraFallback(),
        ),
        
        // Top actions
        Positioned(
          top: AppSpacing.md,
          left: AppSpacing.md,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        
        // Target overlay
        Center(
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Center(
              child: Icon(Icons.add, color: Colors.white.withOpacity(0.5), size: 40),
            ),
          ),
        ),
        
        // Bottom Controls
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl, horizontal: AppSpacing.lg),
            color: Colors.black.withOpacity(0.6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(Icons.photo_library, color: Colors.white),
                  onPressed: () {
                    // Simulate picking from gallery
                  },
                ),
                GestureDetector(
                  onTap: _captureAndAnalyze,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: Center(
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.flash_off, color: Colors.white),
                  onPressed: () {
                    // Toggle flash
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCameraFallback() {
    return Container(
      color: AppColors.charcoalSoil,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.local_florist, color: AppColors.textTertiary, size: 80),
            const SizedBox(height: AppSpacing.md),
            Text(
              _cameraError ? 'Camera unavailable' : 'Initializing camera...',
              style: AppTypography.headlineSmall.copyWith(color: Colors.white),
            ),
            if (_cameraError) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Tap capture to simulate a scan',
                style: AppTypography.bodyLarge.copyWith(color: AppColors.textTertiary),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyzingView(AnalysisStage stage) {
    return Container(
      color: AppColors.paperBackground,
      child: Column(
        children: [
          // Captured Image Placeholder
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              color: AppColors.skeletonBase,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.local_florist, size: 80, color: AppColors.textTertiary),
                  Container(color: Colors.black.withOpacity(0.3)), // Dim overlay
                ],
              ),
            ),
          ),
          
          // Analysis Pipeline
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Analyzing crop health...',
                    style: AppTypography.headlineMedium.copyWith(color: AppColors.charcoalSoil),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _buildStageItem('Image captured', AnalysisStage.imageCaptured, stage),
                  _buildStageItem('Identifying plant region...', AnalysisStage.identifyingPlant, stage),
                  _buildStageItem('Examining leaf patterns...', AnalysisStage.examiningLeaves, stage),
                  _buildStageItem('Comparing visual patterns...', AnalysisStage.comparingPatterns, stage),
                  _buildStageItem('Generating health report...', AnalysisStage.generatingReport, stage),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageItem(String label, AnalysisStage itemStage, AnalysisStage currentStage) {
    final bool isCompleted = currentStage.index >= itemStage.index;
    final bool isCurrent = currentStage == itemStage;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AnimatedOpacity(
        opacity: isCompleted ? 1.0 : 0.3,
        duration: const Duration(milliseconds: 500),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? AppColors.accentGreen : AppColors.skeletonBase,
              ),
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyLarge.copyWith(
                  color: isCurrent ? AppColors.charcoalSoil : AppColors.textSecondary,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
