import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../cubit/home_cubit.dart';
import '../widgets/folder_grid_item.dart';
import '../widgets/create_folder_dialog.dart';
import '../widgets/select_folder_dialog.dart';
import '../../../flip_card/presentation/widgets/select_mode_dialog.dart';
import '../../../flip_card/presentation/pages/flip_card_page.dart';
import '../../../vocabulary/presentation/cubit/vocabulary_cubit.dart';
import '../../../vocabulary/services/vocabulary_service.dart';
import '../../../vocabulary/data/repositories/vocabulary_repository.dart';
import '../../data/database_helper.dart';
import 'package:kotobamate/features/quiz/presentation/pages/quiz_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180.0,
            floating: false,
            snap: false,
            pinned: false,
            elevation: 0,
            stretch: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'My Vocabulary',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 2),
                      blurRadius: 4,
                      color: Colors.black26,
                    ),
                  ],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF2980B9),
                      const Color(0xFF1E3799),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Pattern overlay
                    Positioned.fill(
                      child: CustomPaint(
                        painter: GridPatternPainter(
                          lineColor: Colors.white.withOpacity(0.05),
                          lineWidth: 1,
                          spacing: 20,
                        ),
                      ),
                    ),
                    // Gradient overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.2),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.search,
                  color: Colors.white,
                  size: 28,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 2),
                      blurRadius: 4,
                      color: Colors.black26,
                    ),
                  ],
                ),
                onPressed: () {
                  // TODO: Implement search
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              minHeight: 80,
              maxHeight: 80,
              child: Container(
                padding: const EdgeInsets.only(top: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildToolbarButton(
                      onPressed: () async {
                        // Show folder selection dialog
                        final selectedFolderIds =
                            await showDialog<List<String>>(
                          context: context,
                          builder: (_) => BlocProvider.value(
                            value: context.read<HomeCubit>(),
                            child: const SelectFolderDialog(),
                          ),
                        );

                        if (selectedFolderIds == null || !context.mounted)
                          return;

                        // Show mode selection dialog
                        final isJapaneseFirst = await showDialog<bool>(
                          context: context,
                          builder: (_) => const SelectModeDialog(),
                        );

                        if (isJapaneseFirst == null || !context.mounted) return;

                        // Navigate to quiz page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider(
                              create: (context) => VocabularyCubit(
                                vocabularyService: VocabularyService(
                                  vocabularyRepository: VocabularyRepository(
                                    DatabaseHelper.instance,
                                  ),
                                ),
                              )..loadVocabulariesFromFolders(selectedFolderIds),
                              child: QuizPage(
                                folderIds: selectedFolderIds,
                                isJapaneseFirst: isJapaneseFirst,
                              ),
                            ),
                          ),
                        );
                      },
                      icon: Icons.quiz,
                      label: 'Start Quiz',
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
                      ),
                    ),
                    _buildToolbarButton(
                      onPressed: () async {
                        // Show folder selection dialog
                        final selectedFolderIds =
                            await showDialog<List<String>>(
                          context: context,
                          builder: (_) => BlocProvider.value(
                            value: context.read<HomeCubit>(),
                            child: const SelectFolderDialog(),
                          ),
                        );

                        if (selectedFolderIds == null || !context.mounted)
                          return;

                        // Show mode selection dialog
                        final isJapaneseFirst = await showDialog<bool>(
                          context: context,
                          builder: (_) => const SelectModeDialog(),
                        );

                        if (isJapaneseFirst == null || !context.mounted) return;

                        // Navigate to flip card page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider(
                              create: (context) => VocabularyCubit(
                                vocabularyService: VocabularyService(
                                  vocabularyRepository: VocabularyRepository(
                                    DatabaseHelper.instance,
                                  ),
                                ),
                              )..loadVocabulariesFromFolders(selectedFolderIds),
                              child: FlipCardPage(
                                folderIds: selectedFolderIds,
                                isJapaneseFirst: isJapaneseFirst,
                              ),
                            ),
                          ),
                        );
                      },
                      icon: Icons.flip,
                      label: 'Flip Card',
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2C3E50), Color(0xFF34495E)],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: BlocBuilder<HomeCubit, HomeState>(
              builder: (context, state) {
                if (state is HomeLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is HomeError) {
                  return Center(child: Text(state.message));
                }

                if (state is HomeLoaded) {
                  if (state.folders.isEmpty) {
                    return ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height - 280, // Trừ đi chiều cao của AppBar và toolbar
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.folder_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No folders yet',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap + to create a new folder',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: state.folders.length,
                    itemBuilder: (context, index) {
                      final folder = state.folders[index];
                      return FolderGridItem(folder: folder);
                    },
                  );
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => BlocProvider.value(
              value: context.read<HomeCubit>(),
              child: const CreateFolderDialog(),
            ),
          );
        },
        backgroundColor: const Color(0xFF3498DB),
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(
          Icons.create_new_folder_outlined,
          shadows: [
            Shadow(
              color: Colors.black26,
              blurRadius: 3,
              offset: Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbarButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Gradient gradient,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(14),
              child: Icon(
                icon,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

class GridPatternPainter extends CustomPainter {
  GridPatternPainter({
    required this.lineColor,
    required this.lineWidth,
    required this.spacing,
  });

  final Color lineColor;
  final double lineWidth;
  final double spacing;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = lineWidth;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(GridPatternPainter oldDelegate) =>
      lineColor != oldDelegate.lineColor ||
      lineWidth != oldDelegate.lineWidth ||
      spacing != oldDelegate.spacing;
}
