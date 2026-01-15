

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
        // If we are on the AnalyzingScreen, we might need to pop it? 
        // But since AnalyzingScreen handles its own state mostly, we just show snackbar here if visible,
        // or let AnalyzingScreen handle it. 
        // Ideally, AnalyzingScreen listens to error and pops itself.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error ?? 'Unknown error'), 
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(label: 'Dismiss', onPressed: () {}, textColor: Colors.white),
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('✨ BEAUTY BATTLE AI ✨'),
      ),
      body: Stack(
        children: [
          const GlitterBackground(),
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                 TextSlideshow(
                  texts: const [
                    "Who is the Fairest?",
                    "✨ Mirror Mirror on the Wall... ✨",
                    "🔥 Slay or Nay? 🔥",
                    "👑 Claims the Throne? 👑",
                  ], 
                  colors: const [
                    Color(0xFFFFD700), // Gold
                    Color(0xFFE040FB), // Neon Purple
                    Color(0xFF00E5FF), // Cyan
                    Color(0xFFFF4081), // Pink
                  ]
                ),
                 
                const Gap(10),
                Text(
                  "Upload selfies to compare beauty, detect perfections, and get expert advice!",
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ).animate().fade(delay: 300.ms).slideY(begin: 0.2, end: 0),
                const Gap(30),
    
                // Challenger List
                if (state.challengers.isNotEmpty)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      // Calculate width to ensure 2 items fit side-by-side with spacing
                      // Spacing = 15. Padding is already 20*2=40 parent. 
                      // Available width = constraints.maxWidth
                      // ItemWidth = (AvailableWidth - Spacing) / 2
                      final double itemWidth = (constraints.maxWidth - 15) / 2;
                      
                      return Wrap(
                        spacing: 15,
                        runSpacing: 15,
                        children: [
                          ...state.challengers.asMap().entries.map((entry) {
                            return Stack(
                              children: [
                                _ImageSlot(
                                  image: entry.value,
                                  label: "Challenger ${entry.key + 1}",
                                  size: itemWidth,
                                  width: itemWidth,
                                  height: itemWidth,
                                ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.red,
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(Icons.close, size: 16, color: Colors.white),
                                      onPressed: () => notifier.removeChallenger(entry.key),
                                    ),
                                  ).animate().fade(delay: 200.ms).scale(),
                                ),
                              ],
                            );
                          }),
                          GestureDetector(
                            onTap: () => _showImageSourceModal(context, notifier),
                            child: Container(
                              width: itemWidth,
                              height: itemWidth,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5), width: 1),
                                boxShadow: [
                                  BoxShadow(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1), blurRadius: 10),
                                ]
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 60, width: 60,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(30),
                                      child: const LoopingVideo(assetPath: 'anim/photo/original-5d3c16d01f5054b2d4d60ac58f965dea.mov')
                                    )
                                  ),
                                  const Gap(5),
                                  Text("Add", style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 14)),
                                ],
                              ),
                            ),
                          ).animate().fade().slideX(begin: 0.2, end: 0, duration: 500.ms),
                        ],
                      );
                    }
                  )
                else
                   Center(
                     child: Column(
                       children: [
                         const Gap(20),
                         GestureDetector(
                            onTap: () => _showImageSourceModal(context, notifier),
                            child: _ImageSlot(
                              label: "Add First Challenger", 
                              isMain: true,
                              size: 220,
                              onTap: () => _showImageSourceModal(context, notifier),
                            )
                         ).animate(onPlay: (c) => c.repeat(reverse: true))
                          .shimmer(duration: 3.seconds, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3))
                          .scaleXY(begin: 1, end: 1.02),
                       ],
                     ),
                   ),
    
                const Gap(50),
    
                // Judge Button
                ElevatedButton(
                  onPressed: state.challengers.isNotEmpty
                      ? () {
                          notifier.analyzeBeauty();
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const AnalyzingScreen()),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                       const Flexible(
                         child: Text("🔥 ROAST & RANK 🔥", 
                           style: TextStyle(fontSize: 18, letterSpacing: 1.2),
                           textAlign: TextAlign.center,
                         )
                       ),
                       const Gap(10),
                       if (state.challengers.isEmpty) const Icon(Icons.lock, size:20) else const Icon(Icons.auto_awesome, size: 20),
                    ],
                  ),
                ).animate(onPlay: (c) => c.repeat(reverse: true))
                .scaleXY(begin: 1.0, end: 1.1, duration: 800.ms)
                .boxShadow(
                    begin: const BoxShadow(color: Colors.transparent, blurRadius: 0, spreadRadius: 0),
                    end: BoxShadow(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6), blurRadius: 30, spreadRadius: 5),
                 )
                .shimmer(duration: 2.seconds, color: Colors.white),
                
                if (state.challengers.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text("Please upload at least one photo", textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withValues(alpha: 0.5))),
                  ),
                
                const Gap(20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



class _ImageSlot extends StatelessWidget {
  final XFile? image;
  final String label;
  final bool isMain;
  final double? size;
  final double? width;
  final double? height;
  final VoidCallback? onTap;

  const _ImageSlot({this.image, required this.label, this.isMain = false, this.size, this.width, this.height, this.onTap});

  @override
  Widget build(BuildContext context) {
    final double defaultSize = size ?? (isMain ? 200 : 100);
    final double viewWidth = width ?? defaultSize;
    final double viewHeight = height ?? defaultSize;
    
    return Container(
      width: viewWidth,
      height: viewHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: image != null ? Theme.of(context).colorScheme.primary : Colors.grey.withValues(alpha: 0.3),
          width: image != null ? 3 : 1
        ),
        boxShadow: image != null ? [
          BoxShadow(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3), blurRadius: 15, spreadRadius: 2)
        ] : [],
        image: image != null ? DecorationImage(
          image: FileImage(File(image!.path)),
          fit: BoxFit.cover,
        ) : null,
      ),
      child: image == null ? Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // If label is "Add First Challenger" (main), show video
          if (isMain) 
             SizedBox(
              height: 100, width: 100,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: const LoopingVideo(assetPath: 'anim/photo/original-5d3c16d01f5054b2d4d60ac58f965dea.mov')
              )
            )
          else
            Icon(Icons.person_add, size: viewWidth * 0.3, color: Colors.grey),
            
          if (label.isNotEmpty) ...[
            const Gap(10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ),
          ]
        ],
      ) : null,
    );
  }
}

class AnalyzingScreen extends ConsumerStatefulWidget {
  const AnalyzingScreen({super.key});

  @override
  ConsumerState<AnalyzingScreen> createState() => _AnalyzingScreenState();
}

class _AnalyzingScreenState extends ConsumerState<AnalyzingScreen> {
  RewardedInterstitialAd? _rewardedInterstitialAd;
  bool _isAdShowing = false;
  bool _isResultReady = false;
  bool _isAdLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    // Load the ad immediately
    _loadAd();
  }

  void _loadAd() {
    RewardedInterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/5354046379', // Test ID for Rewarded Interstitial
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          debugPrint('AdMob Loaded');
          setState(() {
            _rewardedInterstitialAd = ad;
            _isAdLoading = false;
          });
          
          _rewardedInterstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              setState(() {
                _isAdShowing = false;
                _rewardedInterstitialAd = null;
              });
              _checkNavigation();
            },
            onAdFailedToShowFullScreenContent: (ad, err) {
              ad.dispose();
              setState(() {
                _isAdShowing = false;
                _rewardedInterstitialAd = null;
              });
              _checkNavigation();
            },
            onAdShowedFullScreenContent: (ad) {
              setState(() {
                _isAdShowing = true;
                _isAdLoading = false; // Just in case
              });
            },
          );

          // Show the ad roughly when it loads, matching user request "shown in that time when ai is analysing"
          _rewardedInterstitialAd!.show(onUserEarnedReward: (ad, reward) {
            // Reward logic if any (optional for this app)
          });
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('AdMob load failed: $error');
          if (mounted) {
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
    // Navigate only if result is ready and we are not waiting for ad to load or show
    // We wait for ad to load (_isAdLoading) to give it a chance to show.
    // If ad is loading, we don't navigate yet, effectively "pausing" until ad succeeds or fails.
    if (_isResultReady && !_isAdShowing && !_isAdLoading) {
       Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const ResultScreen()),
       );
    }
  }

  @override
  void dispose() {
    _rewardedInterstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch for analysis completion
    ref.listen(beautyProvider, (previous, next) {
      if (next.status == AnalysisStatus.done && next.result != null) {
        setState(() {
          _isResultReady = true;
        });
        _checkNavigation();
      } else if (next.status == AnalysisStatus.error) {
        // If error, pop back to home
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
               // Slideshow of videos
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
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
              ).animate(onPlay: (c)=>c.repeat()).shimmer(duration: 2.seconds, color: Colors.white),
              const Gap(10),
              const Text("Checking Symmetry...", style: TextStyle(color: Colors.white70)),
              const Gap(5),
              const Text("Consulting Beauty Algorithms...", style: TextStyle(color: Colors.white70)),
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
          _currentIndex = (_currentIndex + 1) % widget.videos.length;
        });
      }
    });
  }

  Future<void> _initializeVideos() async {
    for (var path in widget.videos) {
      final controller = VideoPlayerController.asset(
        path,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
      _controllers[path] = controller;
      await controller.initialize();
      controller.setLooping(true);
      controller.play(); // Auto-play everything so they are ready
    }
    if (mounted) {
      setState(() {
         _initialized = true;
      });
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
    if (!_initialized) return Container(color: Colors.black);

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
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Select Image Source", style: Theme.of(context).textTheme.titleLarge),
            const Gap(20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _SourceButton(
                  icon: Icons.camera_alt, 
                  label: "Camera", 
                  onTap: () {
                    Navigator.pop(context);
                    notifier.addChallenger(ImageSource.camera);
                  }
                ),
                _SourceButton(
                  icon: Icons.photo_library, 
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
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white24)
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: Theme.of(context).colorScheme.primary),
            const Gap(10),
            Text(label, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
