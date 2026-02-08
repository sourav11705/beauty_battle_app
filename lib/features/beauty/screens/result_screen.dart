import 'dart:io';

import 'package:beauty_compare/features/beauty/providers/beauty_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import 'package:confetti/confetti.dart';

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({super.key});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.read(beautyProvider);
    final result = state.result;
    
    if (result == null) {
      return const Scaffold(body: Center(child: Text("No result data found")));
    }

    final analyses = result['analyses'] as List<dynamic>? ?? [];
    final winnerId = result['winner_id'] as int?;
    final winnerReason = result['winner_reason'] as String? ?? "No winner assigned.";
    final winnerTitle = result['winner_title'] as String? ?? "Winner";

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("🏆 THE VERDICT 🏆"),
        backgroundColor: Colors.black.withValues(alpha: 0.5),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
            Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black,
                  Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
                  Colors.black
                ]
              )
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Winner Announcement
                  if (winnerId != null && winnerId < state.challengers.length)
                    _WinnerCard(
                      winnerImage: File(state.challengers[winnerId].path),
                      title: winnerTitle,
                      reason: winnerReason,
                    ),
                  
                  const Gap(30),
                  
                  _RankingHeader(),
                  const Gap(15),
    
                  // Individual Analyses - SORTED BY RANK
                  ...(() {
                    final sortedAnalyses = List<Map<String, dynamic>>.from(analyses);
                    sortedAnalyses.sort((a, b) => (a['rank'] as int? ?? 999).compareTo(b['rank'] as int? ?? 999));
                    
                    return sortedAnalyses.map((analysis) {
                      final id = analysis['id'];
                      final imageFile = (id != null && id < state.challengers.length) 
                         ? File(state.challengers[id].path) 
                         : null;
                      
                      return _AnalysisCard(
                        image: imageFile,
                        nickname: analysis['nickname'] ?? 'The Mystery Face',
                        highlights: analysis['beauty_highlights'] ?? '',
                        defects: analysis['defects'] ?? '', // Now Defects
                        cure: analysis['cure'] ?? '',
                        vibe: analysis['vibe_gender'] ?? '',
                        index: id ?? 0,
                        score: analysis['beauty_score'] as int? ?? 50,
                        rank: analysis['rank'] as int? ?? 0,
                        age: analysis['predicted_age'] as int? ?? 25,
                        celebName: analysis['celeb_name'] ?? 'Unknown',
                      ).animate().slideX(begin: 0.2, end: 0, delay: Duration(milliseconds: 200 * (id as int? ?? 0))).fade();
                    });
                  })(),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
              gravity: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _WinnerCard extends StatelessWidget {
  final File winnerImage;
  final String title;
  final String reason;

  const _WinnerCard({required this.winnerImage, required this.title, required this.reason});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
      ),
      child: Column(
        children: [
          const Icon(Icons.emoji_events, size: 50, color: Color(0xFFFFD700)),
          const Gap(10),
          Text(title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: const Color(0xFFFFD700)), textAlign: TextAlign.center),
          const Gap(20),
          CircleAvatar(
            radius: 80,
            backgroundImage: ResizeImage(FileImage(winnerImage), width: 300),
          ).animate(onPlay: (c)=>c.repeat()).shimmer(duration: 2.seconds, color: Colors.white.withValues(alpha: 0.5)),
          const Gap(20),
          MarkdownBody(data: reason, styleSheet: MarkdownStyleSheet(p: const TextStyle(fontSize: 16))),
        ],
      ),
    ).animate().scale(duration: 500.ms, curve: Curves.elasticOut);
  }
}

class _RankingHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.format_list_numbered, color: Colors.white),
        const Gap(10),
        Text(
          "Official Rankings",
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
        ),
      ],
    );
  }
}

class _AnalysisCard extends StatelessWidget {
  final File? image;
  final String nickname;
  final String highlights;
  final String defects;
  final String cure;
  final String vibe;
  final int index;
  final int score;
  final int rank;
  final int age;
  final String celebName;

  const _AnalysisCard({
    required this.image,
    required this.nickname,
    required this.highlights,
    required this.defects,
    required this.cure,
    required this.vibe,
    required this.index,
    required this.score,
    required this.rank,
    required this.age,
    required this.celebName,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      color: Colors.white10,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
           // Header
           Container(
             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
             color: rank == 1 ? const Color(0xFFFFD700).withValues(alpha: 0.2) : Colors.black26,
             child: Row(
               children: [
                 if (rank == 1) ...[
                   const Icon(Icons.emoji_events, color: Color(0xFFFFD700)),
                   const Gap(5),
                 ],
                 Text("#$rank", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)),
                 const Gap(10),
                 Text(rank == 1 ? "WINNER" : "Rank $rank", style: TextStyle(
                   color: rank == 1 ? const Color(0xFFFFD700) : Colors.white70,
                   fontWeight: FontWeight.bold
                 )),
                 const Spacer(),
                 Text("$score/100", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: _getScoreColor(score))),
               ],
             ),
           ),
           
           Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                 Row(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     if (image != null) 
                       Container(
                         width: 90, height: 90,
                         decoration: BoxDecoration(
                           borderRadius: BorderRadius.circular(15),
                           border: rank == 1 ? Border.all(color: const Color(0xFFFFD700), width: 2) : null,
                           image: DecorationImage(
                             image: ResizeImage(FileImage(image!), width: 200),
                             fit: BoxFit.cover
                           ),
                         ),
                       ),
                     const Gap(15),
                     Expanded(
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text(nickname, style: Theme.of(context).textTheme.titleLarge?.copyWith(
                             color: Theme.of(context).colorScheme.primary,
                             fontWeight: FontWeight.bold,
                           )),
                           const Gap(5),
                           Text(vibe, style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey, fontSize: 14)),
                           const Gap(10),
                           _BeautyMeter(score: score),
                         ],
                       ),
                     ),
                   ],
                 ),
                 const Gap(20),
                 const Divider(color: Colors.white24),
                 const Gap(5),
                 _SectionTitle(title: "🌟 Highlights", color: Colors.amber),
                 MarkdownBody(data: highlights),
                 const Gap(15),
                 _SectionTitle(title: "📉 Defects", color: Colors.redAccent), // Renamed from Improvements
                 MarkdownBody(data: defects),
                 const Gap(15),
                 _SectionTitle(title: "💊 Expert Cure", color: Colors.greenAccent),
                 MarkdownBody(data: cure),
                 const Gap(15),

                 // NEW SECTIONS: AGE and CELEB
                 Row(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Expanded(
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           _SectionTitle(title: "🎂 Predicted Age", color: Colors.blueAccent),
                           Text("$age years", style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                         ],
                       ),
                     ),
                     Expanded(
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           _SectionTitle(title: "🎬 Lookalike", color: Colors.purpleAccent),
                           Text(celebName, style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                         ],
                       ),
                     )
                   ],
                 )
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getScoreColor(int score) {
    if (score >= 90) return Colors.greenAccent;
    if (score >= 70) return Colors.lightGreen;
    if (score >= 50) return Colors.amber;
    return Colors.redAccent;
  }
}

class _BeautyMeter extends StatelessWidget {
  final int score;
  const _BeautyMeter({required this.score});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Beauty Score", style: TextStyle(fontSize: 12, color: Colors.grey)),
            Text(getRatingComment(score), style: const TextStyle(fontSize: 12, color: Colors.white70, fontStyle: FontStyle.italic)),
          ],
        ),
        const Gap(5),
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: LinearProgressIndicator(
            value: score / 100,
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation<Color>(_getMeterColor(score)),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
  
  Color _getMeterColor(int score) {
     if (score >= 90) return const Color(0xFFE040FB); // Neon Purple
     if (score >= 80) return Colors.amber;
     if (score >= 60) return Colors.orange;
     return Colors.grey;
  }

  String getRatingComment(int s) {
    if (s >= 95) return "God Tier 😱";
    if (s >= 90) return "Stunning 🤩";
    if (s >= 80) return "Gorgeous 🥰";
    if (s >= 70) return "Pretty Good 😉";
    if (s >= 50) return "Average 😐";
    return "Needs Work 😬";
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final Color color;
  const _SectionTitle({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}
