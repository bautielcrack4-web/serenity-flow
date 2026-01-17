import 'package:flutter/material.dart';
import 'package:serenity_flow/core/design_system.dart';
import 'package:serenity_flow/models/routine_model.dart';
import 'package:serenity_flow/screens/session/pose_screen.dart';
import 'package:flutter/services.dart';

class PreSessionScreen extends StatefulWidget {
  final Routine routine;

  const PreSessionScreen({super.key, required this.routine});

  @override
  State<PreSessionScreen> createState() => _PreSessionScreenState();
}

class _PreSessionScreenState extends State<PreSessionScreen> with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  final ScrollController _scrollController = ScrollController();
  int _activePoseIndex = 0;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _scrollController.addListener(() {
      int idx = (_scrollController.offset / 80).round();
      if (idx != _activePoseIndex) setState(() => _activePoseIndex = idx);
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            const Spacer(),
            _buildMainInfo(),
            const Spacer(),
            _buildPoseCarousel(),
            const SizedBox(height: 48),
            _buildEpicStartButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: () => Navigator.pop(context)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: widget.routine.themeGradient.colors.first.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
            child: Row(
              children: [
                 Icon(Icons.accessibility_new_rounded, size: 16, color: widget.routine.themeGradient.colors.last),
                 const SizedBox(width: 8),
                 Text("${widget.routine.poseCount} poses • ${widget.routine.computedDuration}", style: TextStyle(fontWeight: FontWeight.w900, color: widget.routine.themeGradient.colors.last, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(width: 48), // Spacer
        ],
      ),
    );
  }

  Widget _buildMainInfo() {
    return Column(
      children: [
        Hero(
          tag: 'routine_icon_${widget.routine.id}',
          child: Container(
            width: 240, height: 240,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [widget.routine.themeGradient.colors.first.withOpacity(0.4), Colors.transparent]),
            ),
            child: Image.asset(widget.routine.icon, fit: BoxFit.contain),
          ),
        ),
        const SizedBox(height: 32),
        Text(widget.routine.name, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: AppColors.dark)),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(widget.routine.description, textAlign: TextAlign.center, style: TextStyle(fontSize: 17, color: AppColors.dark.withOpacity(0.6), height: 1.4)),
        ),
      ],
    );
  }

  Widget _buildPoseCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 100,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: widget.routine.poses.length,
            itemBuilder: (context, index) {
              return Container(
                width: 80, height: 80,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: _activePoseIndex == index ? widget.routine.themeGradient.colors.first : Colors.transparent, width: 2),
                  boxShadow: AppShadows.card,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Image.asset(widget.routine.poses[index].image, fit: BoxFit.contain),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        Row(
           mainAxisAlignment: MainAxisAlignment.center,
           children: List.generate(widget.routine.poses.length, (index) => Container(
             width: 8, height: 8,
             margin: const EdgeInsets.symmetric(horizontal: 4),
             decoration: BoxDecoration(shape: BoxShape.circle, color: _activePoseIndex == index ? widget.routine.themeGradient.colors.first : AppColors.lightGray),
           )),
        ),
      ],
    );
  }

  Widget _buildEpicStartButton() {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: 72,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(36),
            boxShadow: [
              BoxShadow(
                color: AppColors.coral.withOpacity(0.3 + (_glowController.value * 0.2)),
                blurRadius: 20 + (_glowController.value * 10),
                spreadRadius: 2,
              )
            ],
          ),
          child: ElevatedButton(
            onPressed: () {
              HapticFeedback.heavyImpact();
              Navigator.push(context, MaterialPageRoute(builder: (context) => PoseScreen(routine: widget.routine)));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(36)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("START PRACTICE", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.2)),
                SizedBox(width: 12),
                Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
              ],
            ),
          ),
        );
      },
    );
  }
}
