

import 'dart:async';
import 'dart:io';

import 'package:beauty_compare/core/widgets/glitter_background.dart';
import 'package:beauty_compare/core/widgets/looping_video.dart';
import 'package:beauty_compare/core/widgets/text_slideshow.dart';
import 'package:beauty_compare/features/beauty/providers/beauty_provider.dart';
import 'package:beauty_compare/features/beauty/screens/result_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(beautyProvider);
    final notifier = ref.read(beautyProvider.notifier);

    // Listen for errors
    ref.listen(beautyProvider, (previous, next) {
      if (next.status == AnalysisStatus.error) {
        if (context.mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.error ?? 'Unknown error'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              action: SnackBarAction(label: 'Dismiss', onPressed: () {}, textColor: Colors.white),
            ),
          );
        }
      }
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'BEAUTY BATTLE AI',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            fontSize: 22,
            shadows: [Shadow(color: Theme.of(context).colorScheme.primary, blurRadius: 10)]
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.7),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          const GlitterBackground(),
          
          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Gap(10),
                  TextSlideshow(
                    texts: const [
                      "Who Reigns Supreme?",
                      "✨ Mirror Mirror... ✨",
                      "🔥 Scale of 1 to 10? 🔥",
                      "👑 Claims the Crown? 👑",
                    ], 
                    colors: const [
                      Color(0xFFFFD700), // Gold
                      Color(0xFFE040FB), // Neon Purple
                      Color(0xFF00E5FF), // Cyan
                      Color(0xFFFF4081), // Pink
                    ]
                  ),
                  
                  const Gap(20),
                  
                  // Brief Description Card
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Text(
                      "Upload photos to let AI judge beauty, find flaws, and roast your friends with savage honesty.",
                      style: GoogleFonts.inter(fontSize: 14, color: Colors.white70, height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                  ).animate().fade().slideY(begin: 0.2, end: 0),

                  const Gap(30),

                  // Challenger Arena Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const Gap(10),
                      Text("THE ARENA", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.white)),
                      const Gap(10),
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                    ],
                  ).animate().fadeIn(delay: 200.ms),
                  
                  const Gap(20),

                  // Dynamic Challenger Layout
                  if (state.challengers.isEmpty) ...[
                     _buildEmptyState(context, notifier),
                  ] else ...[
                     _buildChallengerGrid(context, state.challengers, notifier),
                  ],

                  const Gap(40),

                  // Action Button
                  Center(
                    child: _buildJudgeButton(context, state, notifier),
                  ),
                  
                  const Gap(30),
                  
                  if (state.challengers.isEmpty)
                    Text(
                      "Add at least 1 photo to start",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(color: Colors.white38, fontSize: 12),
                    ),
                  const Gap(20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, BeautyNotifier notifier) {
    return GestureDetector(
      onTap: () => _showImageSourceModal(context, notifier),
      child: Container(
        height: 250,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3), width: 1),
          boxShadow: [
            BoxShadow(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1), blurRadius: 20, spreadRadius: 0),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
              ),
              child: Icon(Icons.add_a_photo_outlined, size: 40, color: Theme.of(context).colorScheme.primary),
             ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 1.seconds),
             const Gap(20),
             Text("Tap to Enter the Arena", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
             const Gap(5),
             Text("Upload the first challenger", style: GoogleFonts.inter(fontSize: 12, color: Colors.white54)),
          ],
        ),
      ),
    ).animate().fade(duration: 500.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildChallengerGrid(BuildContext context, List<XFile> challengers, BeautyNotifier notifier) {
    return Column(
      children: [
        // Grid of images
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 0.85,
          ),
          itemCount: challengers.length + 1, // Add +1 for the "Add" button
          itemBuilder: (context, index) {
            if (index == challengers.length) {
              // The "Add" button at the end
              return GestureDetector(
                onTap: () => _showImageSourceModal(context, notifier),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24, style: BorderStyle.solid),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, size: 40, color: Colors.white54),
                      const Gap(5),
                      Text("Add More", style: GoogleFonts.inter(color: Colors.white54, fontSize: 12))
                    ],
                  ),
                ),
              );
            }

            final image = challengers[index];
            return Stack(
              children: [
                _ImageSlot(
                   image: image,
                   label: "Player ${index + 1}",
                   width: double.infinity,
                   height: double.infinity,
                ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                
                Positioned(
                  top: 5, right: 5,
                  child: GestureDetector(
                    onTap: () => notifier.removeChallenger(index),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                      child: const Icon(Icons.close, size: 16, color: Colors.white),
                    ),
                  ),
                ),
                
                // Rank Badge Placeholder (optional style)
                Positioned(
                  top: 5, left: 5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "#${index + 1}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildJudgeButton(BuildContext context, dynamic state, BeautyNotifier notifier) {
    final bool isEnabled = state.challengers.isNotEmpty;
    
    return Container(
      decoration: BoxDecoration(
        boxShadow: isEnabled ? [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
            blurRadius: 30,
            spreadRadius: 2,
          )
        ] : [],
        borderRadius: BorderRadius.circular(30),
      ),
      child: ElevatedButton(
        onPressed: isEnabled
            ? () {
                notifier.analyzeBeauty();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AnalyzingScreen()),
                );
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? Theme.of(context).colorScheme.primary : Colors.grey.withValues(alpha: 0.2),
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 22),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: isEnabled ? 10 : 0,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "ROAST & RANK",
              style: GoogleFonts.outfit(
                fontSize: 18, 
                fontWeight: FontWeight.bold, 
                letterSpacing: 1.5
              ),
            ),
            const Gap(10),
            Icon(isEnabled ? Icons.auto_awesome : Icons.lock, size: 24),
          ],
        ),
      ),
    ).animate(target: isEnabled ? 1 : 0).scaleXY(end: 1.05, duration: 200.ms);
  }
}



class _ImageSlot extends StatelessWidget {
  final XFile? image;
  final String label;
  final double? width;
  final double? height;

  const _ImageSlot({this.image, required this.label, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1
        ),
        image: image != null ? DecorationImage(
          image: ResizeImage(FileImage(File(image!.path)), width: 400),
          fit: BoxFit.cover,
        ) : null,
      ),
      child: image == null ? Center(child: Text(label, style: const TextStyle(color: Colors.grey))) : null,
    );
  }
}

class AnalyzingScreen extends ConsumerStatefulWidget {
  const AnalyzingScreen({super.key});

  @override
  ConsumerState<AnalyzingScreen> createState() => _AnalyzingScreenState();
}

class _AnalyzingScreenState extends ConsumerState<AnalyzingScreen> {
  RewardedAd? _rewardedAd; // Changed to RewardedAd
  bool _isAdShowing = false;
  bool _isResultReady = false;
  bool _isAdLoading = true;
  Timer? _adTimeoutTimer;

  @override
  void initState() {
    super.initState();
    // Register test device to ensure ads load during development/testing
    // This solves "No Fill" errors common with new Ad Units.
    MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(testDeviceIds: ['0A53A05132210847', 'EF27C5A377150005BB39077274092484'])
    );
    
    _loadAd();
    
    // Safety timeout: If ad takes too long (e.g., 8 seconds), proceed anyway.
    // This prevents the user from being stuck on this screen forever.
    _adTimeoutTimer = Timer(const Duration(seconds: 8), () {
      if (mounted && _isAdLoading) {
        debugPrint("Ad loading timed out. Proceeding...");
        setState(() {
          _isAdLoading = false;
        });
        _checkNavigation();
      }
    });
  }

  void _loadAd() {
    RewardedAd.load( // Changed to RewardedAd.load
      adUnitId: 'ca-app-pub-7621618027309121/2058622748', // User provided ID
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback( // Changed to RewardedAdLoadCallback
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          debugPrint('AdMob Loaded');
          setState(() {
             _rewardedAd = ad;
             _isAdLoading = false;
          });
          
          _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback( // Updated callback attachment
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              setState(() {
                _isAdShowing = false;
                _rewardedAd = null;
              });
              _checkNavigation();
            },
            onAdFailedToShowFullScreenContent: (ad, err) {
              ad.dispose();
              setState(() {
                _isAdShowing = false;
                _rewardedAd = null;
              });
              _checkNavigation();
            },
            onAdShowedFullScreenContent: (ad) {
              setState(() {
                _isAdShowing = true;
                _isAdLoading = false;
              });
            },
          );

          _rewardedAd!.show(onUserEarnedReward: (ad, reward) {}); // Show the ad
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('AdMob load failed: $error');
          if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(
                 content: Text('Ad Failed to Load: ${error.message} (Code: ${error.code})'),
                 backgroundColor: Colors.red,
                 duration: const Duration(seconds: 4),
               ),
             );
             setState(() {
               _isAdLoading = false;
             });
             _checkNavigation();
          }
        },
      )
    );
  }
  
  void _checkNavigation() {
    if (_isResultReady && !_isAdShowing && !_isAdLoading) {
       Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const ResultScreen()),
       );
    }
  }

  @override
  void dispose() {
    _adTimeoutTimer?.cancel();
    _rewardedAd?.dispose(); // Dispose RewardedAd
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(beautyProvider, (previous, next) {
      if (next.status == AnalysisStatus.done && next.result != null) {
        setState(() {
          _isResultReady = true;
        });
        _checkNavigation();
      } else if (next.status == AnalysisStatus.error) {
        Navigator.of(context).pop();
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView( 
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               SizedBox(
                 width: 300, height: 300,
                 child: ClipRRect(
                   borderRadius: BorderRadius.circular(20),
                   child: _VideoSlideshow(videos: const [
                      'anim/crown.mp4',
                      'anim/eyelashes.mp4',
                      'anim/facial-mask.mp4',
                      'anim/heart.mp4',
                      'anim/smiling.mp4'
                   ])
                 ),
               ),
              const Gap(40),
              Text(
                "Analyzing Features...",
                style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
              ).animate(onPlay: (c)=>c.repeat()).shimmer(duration: 2.seconds, color: Colors.white),
              const Gap(10),
              Text("Using advanced AI models...", style: GoogleFonts.inter(color: Colors.white54)),
            ],
          ),
        ),
      ),
    );
  }
}

class _VideoSlideshow extends StatefulWidget {
  final List<String> videos;
  const _VideoSlideshow({required this.videos});

  @override
  State<_VideoSlideshow> createState() => _VideoSlideshowState();
}

class _VideoSlideshowState extends State<_VideoSlideshow> {
  int _currentIndex = 0;
  late Timer _timer;
  final Map<String, VideoPlayerController> _controllers = {};
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideos();
    
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted && _initialized) {
        setState(() {
          // Pause previous
          _controllers[widget.videos[_currentIndex]]?.pause();
          
          // Advance index
          _currentIndex = (_currentIndex + 1) % widget.videos.length;
          
          // Play next
          _controllers[widget.videos[_currentIndex]]?.play();
        });
      }
    });
  }

  Future<void> _initializeVideos() async {
    try {
      // Initialize all but only play the first one
      for (var i = 0; i < widget.videos.length; i++) {
        final path = widget.videos[i];
        final controller = VideoPlayerController.asset(
          path,
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
        );
        _controllers[path] = controller;
        await controller.initialize();
        controller.setLooping(true);
        controller.setVolume(0);
        
        if (i == 0) {
          controller.play(); // Only play the first one initially
        }
      }
      
      if (mounted) {
        setState(() {
           _initialized = true;
        });
      }
    } catch (e) {
      debugPrint("Error initializing videos: $e");
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) return Container(color: Colors.black12);

    final currentPath = widget.videos[_currentIndex];
    final controller = _controllers[currentPath];

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 1000),
      child: LoopingVideo(
        key: ValueKey<String>(currentPath),
        controller: controller
      ),
    );
  }
}

void _showImageSourceModal(BuildContext context, BeautyNotifier notifier) {
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF1E1E1E),
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Select Source", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const Gap(30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _SourceButton(
                  icon: Icons.camera_alt_outlined, 
                  label: "Camera", 
                  onTap: () {
                    Navigator.pop(context);
                    notifier.addChallenger(ImageSource.camera);
                  }
                ),
                _SourceButton(
                  icon: Icons.photo_library_outlined, 
                  label: "Gallery", 
                  onTap: () {
                    Navigator.pop(context);
                    notifier.addChallenger(ImageSource.gallery);
                  }
                ),
              ],
            ),
             const Gap(20),
          ],
        ),
      );
    }
  );
}

class _SourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SourceButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white12)
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
            const Gap(10),
            Text(label, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
