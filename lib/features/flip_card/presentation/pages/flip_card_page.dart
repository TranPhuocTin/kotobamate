import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kotobamate/features/vocabulary/domain/entities/vocabulary.dart';
import 'package:kotobamate/features/vocabulary/presentation/cubit/vocabulary_cubit.dart';
import 'package:kotobamate/features/vocabulary/presentation/cubit/vocabulary_state.dart';
import 'package:flutter_tts/flutter_tts.dart';

class FlipCardPage extends StatefulWidget {
  final List<String> folderIds;
  final bool
      isJapaneseFirst; // true: Japanese -> Vietnamese, false: Vietnamese -> Japanese

  const FlipCardPage({
    super.key,
    required this.folderIds,
    required this.isJapaneseFirst,
  });

  @override
  State<FlipCardPage> createState() => _FlipCardPageState();
}

class _FlipCardPageState extends State<FlipCardPage>
    with SingleTickerProviderStateMixin {
  bool isFlipped = false;
  int currentIndex = 0;
  List<MapEntry<String, String>> vocabularies = [];
  double _dragOffset = 0;
  late final AnimationController _animationController;
  late final Animation<Offset> _slideAnimation;
  final FlutterTts _tts = FlutterTts();
  bool _ttsInitialized = false;
  String? _lastSpokenWord;

  @override
  void initState() {
    super.initState();
    _initTts();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _initTts() async {
    try {
      // Initialize with lower values for better responsiveness
      await _tts.setLanguage('ja-JP');
      await _tts.setSpeechRate(0.4);  // Reduced from 0.5
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      
      // Add handlers for TTS events
      _tts.setStartHandler(() {
        print('TTS Started');
      });
      
      _tts.setCompletionHandler(() {
        print('TTS Completed');
        _lastSpokenWord = null;
      });
      
      _tts.setErrorHandler((msg) {
        print('TTS Error: $msg');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi phát âm: $msg')),
          );
        }
      });
      
      List<dynamic>? languages = await _tts.getLanguages;
      if (languages != null && languages.contains('ja-JP')) {
        setState(() {
          _ttsInitialized = true;
        });
      } else {
        print('Japanese language not supported');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Thiết bị không hỗ trợ tiếng Nhật')),
          );
        }
      }
    } catch (e) {
      print('TTS initialization error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể khởi tạo TTS')),
        );
      }
    }
  }

  @override
  void dispose() {
    _tts.stop();
    _animationController.dispose();
    super.dispose();
  }

  void _onCardDragEnd(DragEndDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (_dragOffset.abs() > screenWidth * 0.4) {
      if (_dragOffset > 0 && currentIndex > 0) {
        // Swipe right - previous card
        setState(() {
          currentIndex--;
          isFlipped = false;
          _dragOffset = 0;
        });
      } else if (_dragOffset < 0 && currentIndex < vocabularies.length - 1) {
        // Swipe left - next card
        setState(() {
          currentIndex++;
          isFlipped = false;
          _dragOffset = 0;
        });
      } else {
        // Show feedback when at first/last card
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                _dragOffset > 0 ? 'Đã là từ đầu tiên' : 'Đã là từ cuối cùng'),
            duration: const Duration(seconds: 1),
          ),
        );
        setState(() {
          _dragOffset = 0;
        });
      }
    } else {
      // Reset position if not dragged enough
      setState(() {
        _dragOffset = 0;
      });
    }
  }

  Future<void> _playAudio(String word) async {
    if (!_ttsInitialized) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đang khởi tạo TTS, vui lòng đợi')),
        );
      }
      return;
    }

    try {
      // Prevent multiple simultaneous TTS requests
      if (_lastSpokenWord == word) {
        return;
      }
      
      // Stop any ongoing speech
      await _tts.stop();
      
      _lastSpokenWord = word;
      await _tts.speak(word);
    } catch (e) {
      print('TTS error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể phát âm thanh')),
        );
      }
      _lastSpokenWord = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VocabularyCubit, VocabularyState>(
      buildWhen: (previous, current) => 
          current is VocabularyLoaded || 
          current is VocabularyLoading || 
          current is VocabularyError,
      listenWhen: (previous, current) => current is VocabularyLoaded,
      listener: (context, state) {
        if (state is VocabularyLoaded) {
          setState(() {
            vocabularies = state.vocabularies.entries.toList();
          });
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Flip Card'),
            actions: [
              IconButton(
                icon: const Icon(Icons.shuffle),
                onPressed: () {
                  setState(() {
                    vocabularies.shuffle();
                    currentIndex = 0;
                    isFlipped = false;
                  });
                },
              ),
            ],
          ),
          body: RepaintBoundary(
            child: state is VocabularyLoading
                ? const Center(child: CircularProgressIndicator())
                : state is VocabularyError
                    ? Center(child: Text(state.message))
                    : vocabularies.isEmpty
                        ? const Center(child: Text('No vocabularies available'))
                        : Column(
                            children: [
                              Expanded(
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    // Previous card
                                    if (currentIndex > 0)
                                      RepaintBoundary(
                                        child: _buildCard(currentIndex - 1,
                                            offset: -MediaQuery.of(context).size.width),
                                      ),
                                    // Current card
                                    RepaintBoundary(
                                      child: Transform.translate(
                                        offset: Offset(_dragOffset, 0),
                                        child: GestureDetector(
                                          onTap: () => setState(() => isFlipped = !isFlipped),
                                          onHorizontalDragUpdate: (details) {
                                            if (mounted) {
                                              setState(() {
                                                _dragOffset += details.delta.dx;
                                              });
                                            }
                                          },
                                          onHorizontalDragEnd: _onCardDragEnd,
                                          child: _buildCard(currentIndex),
                                        ),
                                      ),
                                    ),
                                    // Next card
                                    if (currentIndex < vocabularies.length - 1)
                                      RepaintBoundary(
                                        child: _buildCard(currentIndex + 1,
                                            offset: MediaQuery.of(context).size.width),
                                      ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.arrow_back_ios),
                                      onPressed: currentIndex > 0
                                          ? () {
                                              setState(() {
                                                currentIndex--;
                                                isFlipped = false;
                                              });
                                            }
                                          : null,
                                    ),
                                    Text(
                                      '${currentIndex + 1}/${vocabularies.length}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.arrow_forward_ios),
                                      onPressed:
                                          currentIndex < vocabularies.length - 1
                                              ? () {
                                                  setState(() {
                                                    currentIndex++;
                                                    isFlipped = false;
                                                  });
                                                }
                                              : null,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
          ),
        );
      },
    );
  }

  Widget _buildCard(int index, {double offset = 0}) {
    return RepaintBoundary(
      child: Transform.translate(
        offset: Offset(offset, 0),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  return Transform(
                    transform: Matrix4.rotationY(
                      (1 - animation.value) * 3.14159,
                    ),
                    alignment: Alignment.center,
                    child: child,
                  );
                },
                child: child,
              );
            },
            child: Container(
              key: ValueKey<bool>(isFlipped),
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        isFlipped
                            ? widget.isJapaneseFirst
                                ? vocabularies[index].value
                                : vocabularies[index].key
                            : widget.isJapaneseFirst
                                ? vocabularies[index].key
                                : vocabularies[index].value,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  if ((widget.isJapaneseFirst && !isFlipped) ||
                      (!widget.isJapaneseFirst && isFlipped))
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: IconButton(
                        icon: const Icon(Icons.volume_up),
                        onPressed: () => _playAudio(
                          widget.isJapaneseFirst
                              ? vocabularies[index].key
                              : vocabularies[index].value,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
