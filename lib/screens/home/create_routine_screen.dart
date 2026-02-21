import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:serenity_flow/core/design_system.dart';
import 'package:serenity_flow/models/routine_model.dart';
import 'package:serenity_flow/services/supabase_service.dart';
import 'package:serenity_flow/screens/monetization/paywall_screen.dart';

class CreateRoutineScreen extends StatefulWidget {
  const CreateRoutineScreen({super.key});

  @override
  State<CreateRoutineScreen> createState() => _CreateRoutineScreenState();
}

class _CreateRoutineScreenState extends State<CreateRoutineScreen> {
  // Poses available (using the ones from pre-defined routines as a catalog)
  // De-duplicating poses from routinesData
  final List<Pose> _poseCatalog = [];
  
  // Creation State
  String _routineName = '';
  final List<Pose> _selectedPoses = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadPoseCatalog();
  }

  void _loadPoseCatalog() {
    final seen = <String>{};
    for (var routine in routinesData) {
      for (var pose in routine.poses) {
        if (!seen.contains(pose.name)) {
          seen.add(pose.name);
          _poseCatalog.add(pose);
        }
      }
    }
    // Sort alphabetically
    _poseCatalog.sort((a, b) => a.name.compareTo(b.name));
  }

  void _addPose(Pose pose) {
    if (_selectedPoses.length >= 20) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Max 20 poses per routine for now!")),
      );
      return;
    }
    setState(() {
      // Create a copy so we can modify duration individually if needed
      _selectedPoses.add(Pose(
        name: pose.name,
        image: pose.image,
        duration: pose.duration,
        perSide: pose.perSide,
      ));
    });
    HapticFeedback.lightImpact();
  }

  void _removePose(int index) {
    setState(() {
      _selectedPoses.removeAt(index);
    });
    HapticFeedback.selectionClick();
  }

  void _saveRoutine() async {
    if (_routineName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please name your routine")),
      );
      return;
    }
    if (_selectedPoses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Add at least one pose")),
      );
      return;
    }

    setState(() => _isSaving = true);

    // Ensure user is signed in (retry if needed)
    final supabaseService = SupabaseService();
    if (supabaseService.userId == null) {
      debugPrint("User not signed in, attempting anonymous sign-in...");
      await supabaseService.signInAnonymously();
      
      // Wait a bit for the sign-in to complete
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (supabaseService.userId == null) {
        setState(() => _isSaving = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Connection error. Please try again.")),
          );
        }
        return;
      }
    }

    final success = await supabaseService.saveCustomRoutine(_routineName, _selectedPoses);

    setState(() => _isSaving = false);

    if (success) {
      if (mounted) {
        Navigator.pop(context, true); // Return true to refresh
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Routine saved successfully! 🧘‍♂️")),
        );
      }
    } else {
      // Limit Reached or Error
      if (mounted) {
        // Check if it's actually a limit issue
        final currentRoutines = await supabaseService.getCustomRoutines();
        debugPrint("Current routines count: ${currentRoutines.length}");
        
        if (currentRoutines.length >= 3) {
          // Show Paywall
          if (!mounted) return;
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const PaywallScreen(),
          );
        } else {
          // Some other error
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Error saving routine. Please try again.")),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dawnBackground,
      appBar: AppBar(
        title: const Text("Create Routine", style: TextStyle(color: AppColors.dark, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.dark),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveRoutine,
            child: _isSaving 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
              : const Text("SAVE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // 1. Name Input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Routine Name (e.g. My Power Morning)",
                filled: true,
                fillColor: AppColors.lightGray,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                prefixIcon: const Icon(Icons.edit, color: AppColors.gray),
              ),
              onChanged: (val) => _routineName = val,
            ),
          ),
          
          // 2. Selected Poses (Timeline)
          Container(
            height: 140,
            width: double.infinity,
            color: AppColors.cream,
            child: _selectedPoses.isEmpty 
              ? const Center(child: Text("Tap poses below to add them to your flow 👇", style: TextStyle(color: AppColors.gray)))
              : ReorderableListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  itemCount: _selectedPoses.length,
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                       if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }
                      final item = _selectedPoses.removeAt(oldIndex);
                      _selectedPoses.insert(newIndex, item);
                    });
                  },
                  itemBuilder: (context, index) {
                    final pose = _selectedPoses[index];
                    return Container(
                      key: ValueKey("${pose.name}_$index"),
                      width: 100,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: AppShadows.card,
                      ),
                      child: Stack(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(pose.image, height: 60),
                              const SizedBox(height: 8),
                              Text(pose.name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                              Text("${pose.duration}s", style: const TextStyle(fontSize: 10, color: AppColors.gray)),
                            ],
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: IconButton(
                              icon: const Icon(Icons.close, size: 16, color: Colors.red),
                              onPressed: () => _removePose(index),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
          ),
          
          const Divider(height: 1),
          
          // 3. Pose Catalog (Grid)
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _poseCatalog.length,
              itemBuilder: (context, index) {
                final pose = _poseCatalog[index];
                return GestureDetector(
                  onTap: () => _addPose(pose),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(pose.image, height: 80),
                        const SizedBox(height: 12),
                        Text(
                          pose.name,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        const Icon(Icons.add_circle, color: AppColors.turquoise, size: 24),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
