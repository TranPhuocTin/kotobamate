import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kotobamate/features/vocabulary/presentation/cubit/vocabulary_cubit.dart';
import 'package:kotobamate/features/vocabulary/presentation/cubit/vocabulary_state.dart';
import 'package:kotobamate/features/vocabulary/domain/entities/vocabulary.dart';
import 'dart:math';
import 'dart:async';
import 'package:kotobamate/features/quiz/domain/models/quiz_result.dart';
import 'package:kotobamate/features/quiz/presentation/pages/quiz_result_page.dart';

class QuizPage extends StatefulWidget {
  final List<String> folderIds;
  final bool isJapaneseFirst;

  const QuizPage({
    Key? key,
    required this.folderIds,
    required this.isJapaneseFirst,
  }) : super(key: key);

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage>
    with SingleTickerProviderStateMixin {
  List<Vocabulary> vocabularies = [];
  late int currentQuestionIndex;
  late String correctAnswer;
  late List<String> options;
  Timer? _timer;
  int _timeLeft = 5;
  late AnimationController _animationController;
  late Animation<double> _timerAnimation;
  String? selectedAnswer;
  bool? isCorrect;
  List<QuizAnswer> quizAnswers = [];
  bool isTimeout = false;

  @override
  void initState() {
    super.initState();
    currentQuestionIndex = 0;
    options = [];

    // Khởi tạo animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _timerAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(_animationController);

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !isTimeout) {
        setState(() {
          isTimeout = true;
          selectedAnswer = ''; // Đánh dấu là không chọn đáp án
          isCorrect = false;

          // Thêm kết quả vào danh sách
          quizAnswers.add(QuizAnswer(
            question: widget.isJapaneseFirst
                ? vocabularies[currentQuestionIndex].word
                : vocabularies[currentQuestionIndex].meaning,
            correctAnswer: correctAnswer,
            userAnswer: 'No answer',
            isCorrect: false,
          ));
        });

        // Đợi 1 giây để hiển thị đáp án đúng
        Future.delayed(const Duration(seconds: 1), () {
          _moveToNextQuestion();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void startTimer() {
    _timeLeft = 5;
    _animationController.reset();
    _animationController.forward();
  }

  void _moveToNextQuestion() {
    if (currentQuestionIndex < vocabularies.length - 1) {
      setState(() {
        selectedAnswer = null;
        isCorrect = null;
        isTimeout = false; // Reset timeout flag
        currentQuestionIndex++;
        generateQuestion();
        startTimer();
      });
    } else {
      // Chuyển đến trang kết quả khi hoàn thành quiz
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QuizResultPage(
            answers: quizAnswers,
            totalQuestions: vocabularies.length,
          ),
        ),
      );
    }
  }

  void generateQuestion() {
    if (currentQuestionIndex < vocabularies.length) {
      final currentVocabulary = vocabularies[currentQuestionIndex];

      // Hiển thị từ tiếng Nhật làm câu hỏi nếu isJapaneseFirst = true
      String question = widget.isJapaneseFirst
          ? currentVocabulary.word // tiếng Nhật
          : currentVocabulary.meaning; // tiếng Việt

      // Đáp án đúng sẽ là nghĩa c��a từ được hỏi
      correctAnswer = widget.isJapaneseFirst
          ? currentVocabulary.meaning // tiếng Việt
          : currentVocabulary.word; // tiếng Nhật

      // Tạo danh sách đáp án
      options = [correctAnswer];
      while (options.length < 4) {
        final randomVocabulary =
            vocabularies[Random().nextInt(vocabularies.length)];
        final answer = widget.isJapaneseFirst
            ? randomVocabulary.meaning // lấy nghĩa tiếng Việt làm đáp án
            : randomVocabulary.word; // lấy từ tiếng Nhật làm đáp án
        if (!options.contains(answer)) {
          options.add(answer);
        }
      }
      options.shuffle();
    }
  }

  void checkAnswer(String answer) {
    _animationController.stop();
    setState(() {
      selectedAnswer = answer;
      isCorrect = answer == correctAnswer;

      // Lưu kết quả câu trả lời
      quizAnswers.add(QuizAnswer(
        question: widget.isJapaneseFirst
            ? vocabularies[currentQuestionIndex].word
            : vocabularies[currentQuestionIndex].meaning,
        correctAnswer: correctAnswer,
        userAnswer: answer,
        isCorrect: isCorrect!,
      ));
    });

    // Đợi 1 giây trước khi chuyển câu hỏi tiếp theo
    Future.delayed(const Duration(seconds: 1), () {
      if (currentQuestionIndex < vocabularies.length - 1) {
        _moveToNextQuestion();
      } else {
        // Chuyển đến trang kết quả khi hoàn thành quiz
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => QuizResultPage(
              answers: quizAnswers,
              totalQuestions: vocabularies.length,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VocabularyCubit, VocabularyState>(
      builder: (context, state) {
        if (state is VocabularyLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is VocabularyError) {
          return Scaffold(
            body: Center(child: Text(state.message)),
          );
        }

        if (state is VocabularyLoaded && vocabularies.isEmpty) {
          vocabularies = state.vocabularies.entries
              .map((entry) => Vocabulary(
                    word: entry.key,
                    meaning: entry.value,
                    id: entry.hashCode,
                    folderId: int.parse(widget.folderIds.first),
                    createdAt: DateTime.now(),
                  ))
              .toList();
          vocabularies.shuffle();
          generateQuestion();
          startTimer();
        }

        if (currentQuestionIndex >= vocabularies.length) {
          return const Scaffold(
            body: Center(child: Text('Quiz Finished!')),
          );
        }

        final currentVocabulary = vocabularies[currentQuestionIndex];

        return Scaffold(
          body: Stack(
            children: [
              // Background with winter theme
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.blue[700]!,
                      Colors.blue[900]!,
                    ],
                  ),
                ),
                child: CustomPaint(
                  painter: WinterPatternPainter(),
                  child: Container(),
                ),
              ),

              // Main content
              SafeArea(
                child: Column(
                  children: [
                    // Header with back button and progress
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          // Back button
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Spacer(),
                          // Progress indicator
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${currentQuestionIndex + 1}/${vocabularies.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Timer indicator
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: AnimatedBuilder(
                        animation: _timerAnimation,
                        builder: (context, child) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: _timerAnimation.value,
                              backgroundColor: Colors.white24,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _timerAnimation.value > 0.3
                                    ? Colors.white
                                    : Colors.red,
                              ),
                              minHeight: 8,
                            ),
                          );
                        },
                      ),
                    ),

                    // Question card
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.isJapaneseFirst
                                    ? currentVocabulary.word
                                    : currentVocabulary.meaning,
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Choose the correct answer',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Answer options
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ListView.builder(
                          itemCount: options.length,
                          itemBuilder: (context, index) {
                            final option = options[index];

                            // Mặc định là màu trắng cho tất cả các options
                            Color backgroundColor =
                                Colors.white.withOpacity(0.95);
                            Color textColor = Colors.black87;

                            // Xử lý màu sắc khi người dùng đã chọn đáp án hoặc hết thời gian
                            if (selectedAnswer != null || isTimeout) {
                              if (isTimeout) {
                                // Khi hết thời gian, chỉ bôi đỏ đáp án đúng
                                if (option == correctAnswer) {
                                  backgroundColor = const Color(0xFFF44336)
                                      .withOpacity(0.95); // đáp án đúng -> đỏ
                                  textColor = Colors.white;
                                }
                              } else {
                                // Khi người dùng chọn đáp án
                                if (option == selectedAnswer) {
                                  // Nếu là đáp án người dùng chọn
                                  if (option == correctAnswer) {
                                    backgroundColor = const Color(0xFF4CAF50)
                                        .withOpacity(0.95); // chọn đúng -> xanh
                                  } else {
                                    backgroundColor = const Color(0xFFF44336)
                                        .withOpacity(0.95); // chọn sai -> đỏ
                                  }
                                  textColor = Colors.white;
                                } else if (option == correctAnswer &&
                                    selectedAnswer != correctAnswer) {
                                  // Hiển thị đáp án đúng khi chọn sai
                                  backgroundColor =
                                      const Color(0xFF4CAF50).withOpacity(0.95);
                                  textColor = Colors.white;
                                }
                              }
                            }

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: ElevatedButton(
                                onPressed:
                                    (selectedAnswer == null && !isTimeout)
                                        ? () => checkAnswer(option)
                                        : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: backgroundColor,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 24,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 4,
                                  disabledBackgroundColor: backgroundColor,
                                  disabledForegroundColor: textColor,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    option,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: textColor,
                                      fontWeight: option == correctAnswer &&
                                              (selectedAnswer != null ||
                                                  isTimeout)
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class WinterPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1;

    // Vẽ người tuyết
    void drawSnowman(Offset position, double scale) {
      final snowmanPaint = Paint()
        ..color = Colors.white.withOpacity(0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      // Thân dưới
      canvas.drawCircle(
        Offset(position.dx, position.dy + 50 * scale),
        30 * scale,
        snowmanPaint,
      );

      // Thân giữa
      canvas.drawCircle(
        Offset(position.dx, position.dy),
        20 * scale,
        snowmanPaint,
      );

      // Đầu
      canvas.drawCircle(
        Offset(position.dx, position.dy - 35 * scale),
        15 * scale,
        snowmanPaint,
      );

      // Mắt
      final eyePaint = Paint()
        ..color = Colors.white.withOpacity(0.2)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(position.dx - 5 * scale, position.dy - 37 * scale),
        2 * scale,
        eyePaint,
      );
      canvas.drawCircle(
        Offset(position.dx + 5 * scale, position.dy - 37 * scale),
        2 * scale,
        eyePaint,
      );
    }

    // Vẽ cây thông
    void drawChristmasTree(Offset position, double scale) {
      final treePaint = Paint()
        ..color = Colors.white.withOpacity(0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      final path = Path();

      // Thân cây
      path.moveTo(position.dx, position.dy + 40 * scale);
      path.lineTo(position.dx - 8 * scale, position.dy + 40 * scale);
      path.lineTo(position.dx + 8 * scale, position.dy + 40 * scale);
      path.lineTo(position.dx, position.dy + 60 * scale);

      // Tán lá
      path.moveTo(position.dx, position.dy - 40 * scale);
      path.lineTo(position.dx - 30 * scale, position.dy + 40 * scale);
      path.lineTo(position.dx + 30 * scale, position.dy + 40 * scale);
      path.close();

      // Tầng lá phụ
      path.moveTo(position.dx, position.dy - 20 * scale);
      path.lineTo(position.dx - 25 * scale, position.dy + 30 * scale);
      path.lineTo(position.dx + 25 * scale, position.dy + 30 * scale);
      path.close();

      path.moveTo(position.dx, position.dy);
      path.lineTo(position.dx - 20 * scale, position.dy + 20 * scale);
      path.lineTo(position.dx + 20 * scale, position.dy + 20 * scale);
      path.close();

      canvas.drawPath(path, treePaint);
    }

    // Vẽ các bông tuyết
    void drawSnowflake(Offset center, double size) {
      for (var i = 0; i < 6; i++) {
        final angle = (i * pi / 3);
        final dx = cos(angle) * size;
        final dy = sin(angle) * size;
        canvas.drawLine(
          center,
          Offset(center.dx + dx, center.dy + dy),
          paint,
        );

        // Vẽ nhánh phụ
        final branchSize = size * 0.4;
        final branchAngle = pi / 6;
        for (var j = 0; j < 2; j++) {
          final branchAngleOffset = j == 0 ? branchAngle : -branchAngle;
          final branchDx = cos(angle + branchAngleOffset) * branchSize;
          final branchDy = sin(angle + branchAngleOffset) * branchSize;
          canvas.drawLine(
            Offset(center.dx + dx * 0.5, center.dy + dy * 0.5),
            Offset(center.dx + dx * 0.5 + branchDx,
                center.dy + dy * 0.5 + branchDy),
            paint,
          );
        }
      }
    }

    // Vẽ nhiều bông tuyết với kích thước khác nhau
    final random = Random(42);
    for (var i = 0; i < 15; i++) {
      drawSnowflake(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        8 + random.nextDouble() * 15,
      );
    }

    // Vẽ người tuyết ở góc dưới trái
    drawSnowman(
      Offset(size.width * 0.15, size.height * 0.8),
      1.0,
    );

    // Vẽ cây thông ở góc dưới phải
    drawChristmasTree(
      Offset(size.width * 0.85, size.height * 0.7),
      1.2,
    );

    // Vẽ cây thông nhỏ hơn ở giữa
    drawChristmasTree(
      Offset(size.width * 0.75, size.height * 0.85),
      0.8,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
