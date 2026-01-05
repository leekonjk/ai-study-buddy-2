/// AI Mentor Screen
/// Chat-based AI assistant for study help with typing indicators.
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:studnet_ai_buddy/di/service_locator.dart';
import 'package:studnet_ai_buddy/domain/repositories/academic_repository.dart';
import 'package:studnet_ai_buddy/domain/services/ai_mentor_service.dart';
import 'package:studnet_ai_buddy/presentation/theme/app_theme.dart';
import 'package:studnet_ai_buddy/presentation/widgets/core/gradient_scaffold.dart';
import 'package:studnet_ai_buddy/presentation/widgets/ai/lottie_typing_indicator.dart';

/// AI Mentor chat screen with suggested prompts.
class AIMentorScreen extends StatefulWidget {
  const AIMentorScreen({super.key});

  @override
  State<AIMentorScreen> createState() => _AIMentorScreenState();
}

class _AIMentorScreenState extends State<AIMentorScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isTyping = false;

  // AI Services
  final AIMentorService _aiService = getIt<AIMentorService>();
  final AcademicRepository _academicRepo = getIt<AcademicRepository>();

  final List<String> _suggestedPrompts = [
    '📚 Explain photosynthesis simply',
    '🧮 Help me solve this equation',
    '📝 Create flashcards for this topic',
    '🎯 Quiz me on my study material',
    '💡 Give me study tips',
  ];

  @override
  void initState() {
    super.initState();
    // Add welcome message
    _messages.add(
      _ChatMessage(
        text:
            "Hi there! 👋 I'm your AI Study Buddy. How can I help you learn today?\n\nYou can ask me to:\n• Explain difficult concepts\n• Create study materials\n• Quiz you on topics\n• Give study tips",
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        _ChatMessage(
          text: text.trim(),
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _isTyping = true;
    });

    _messageController.clear();
    _scrollToBottom();

    // Call real AI service
    try {
      // Get academic profile for context
      final profileResult = await _academicRepo.getAcademicProfile();
      final profile = profileResult.fold(
        onSuccess: (p) => p,
        onFailure: (_) => null,
      );

      final response = await _aiService.answerQuery(
        query: text,
        profile: profile,
      );

      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(
            _ChatMessage(
              text: response,
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(
            _ChatMessage(
              text:
                  "I'm having trouble connecting right now. Please try again in a moment.",
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
        });
        _scrollToBottom();
      }
    }
  }

  // _getAIResponse removed - now using real AI service

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Chat messages
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount:
                    _messages.length +
                    (_isTyping ? 1 : 0) +
                    (_messages.length == 1 ? 1 : 0), // +1 for prompts
                itemBuilder: (context, index) {
                  // Show suggested prompts after welcome message
                  if (_messages.length == 1 && index == 1) {
                    return _buildSuggestedPrompts();
                  }
                  final adjustedIndex = _messages.length == 1 && index > 1
                      ? index - 1
                      : index;

                  if (adjustedIndex < _messages.length) {
                    return _buildMessageBubble(_messages[adjustedIndex]);
                  }
                  // Typing indicator
                  return _buildTypingIndicator();
                },
              ),
            ),

            // Input field
            _buildInputField(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: StudyBuddyColors.textPrimary,
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [StudyBuddyColors.primary, StudyBuddyColors.secondary],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.psychology_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Study Buddy',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: StudyBuddyColors.textPrimary,
                  ),
                ),
                Text(
                  'Always here to help',
                  style: TextStyle(
                    fontSize: 12,
                    color: StudyBuddyColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, size: 8, color: AppColors.success),
                SizedBox(width: 4),
                Text(
                  'Online',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestedPrompts() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Try asking:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: StudyBuddyColors.textSecondary,
              ),
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _suggestedPrompts.map((prompt) {
              return InkWell(
                onTap: () => _sendMessage(
                  prompt.replaceAll(RegExp(r'[^\x00-\x7F]'), '').trim(),
                ),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: StudyBuddyColors.cardBackground,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: StudyBuddyColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    prompt,
                    style: const TextStyle(
                      fontSize: 13,
                      color: StudyBuddyColors.textPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildMessageBubble(_ChatMessage message) {
    return Align(
          alignment: message.isUser
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: message.isUser
                  ? StudyBuddyColors.primary
                  : StudyBuddyColors.cardBackground,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(message.isUser ? 18 : 4),
                bottomRight: Radius.circular(message.isUser ? 4 : 18),
              ),
              border: message.isUser
                  ? null
                  : Border.all(color: StudyBuddyColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              message.text,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: message.isUser
                    ? Colors.white
                    : StudyBuddyColors.textPrimary,
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 200.ms)
        .slideX(begin: message.isUser ? 0.2 : -0.2, end: 0, duration: 200.ms);
  }

  Widget _buildTypingIndicator() {
    return const LottieTypingIndicator();
  }

  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: StudyBuddyColors.cardBackground,
        border: Border(top: BorderSide(color: StudyBuddyColors.border)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              // Show attachment picker
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Attachment feature coming soon!'),
                  backgroundColor: StudyBuddyColors.primary,
                ),
              );
            },
            icon: const Icon(
              Icons.add_circle_outline_rounded,
              color: StudyBuddyColors.textSecondary,
            ),
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              style: const TextStyle(color: StudyBuddyColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Ask me anything...',
                hintStyle: TextStyle(color: StudyBuddyColors.textTertiary),
                filled: true,
                fillColor: StudyBuddyColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: _sendMessage,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [StudyBuddyColors.primary, StudyBuddyColors.secondary],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: IconButton(
              onPressed: () => _sendMessage(_messageController.text),
              icon: const Icon(Icons.send_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

/// Chat message model.
class _ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  _ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
