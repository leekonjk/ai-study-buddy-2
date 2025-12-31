/// AI Mentor Screen
/// Chat-based AI assistant for study help with typing indicators.
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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

  void _sendMessage(String text) {
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

    // Simulate AI response after typing
    Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(
            _ChatMessage(
              text: _getAIResponse(text),
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
        });
        _scrollToBottom();
      }
    });
  }

  String _getAIResponse(String query) {
    final lowerQuery = query.toLowerCase();

    if (lowerQuery.contains('photosynthesis')) {
      return "🌱 **Photosynthesis** is how plants make their own food!\n\n**Simple Explanation:**\n1. Plants absorb sunlight through their leaves\n2. They take in CO₂ from the air\n3. They absorb water through their roots\n4. These combine to create glucose (sugar) + oxygen\n\n**Formula:** 6CO₂ + 6H₂O + Light → C₆H₁₂O₆ + 6O₂\n\nWould you like me to create flashcards on this topic?";
    } else if (lowerQuery.contains('equation') ||
        lowerQuery.contains('solve')) {
      return "🧮 I'd be happy to help you solve equations!\n\nPlease share the specific equation, and I'll:\n• Break it down step by step\n• Explain each operation\n• Show you the solution\n\nJust type or paste the equation!";
    } else if (lowerQuery.contains('flashcard')) {
      return "📝 Great idea! Flashcards are excellent for memorization.\n\nTo create flashcards, I need:\n1. **The topic** you're studying\n2. **Key terms** and definitions\n\nOr you can upload your notes and I'll generate them for you!\n\nWhat topic would you like to create flashcards for?";
    } else if (lowerQuery.contains('quiz')) {
      return "🎯 Let's test your knowledge!\n\nI can quiz you on any topic. Here's how:\n1. Tell me the subject (e.g., Biology, History)\n2. Choose difficulty (Easy/Medium/Hard)\n3. I'll ask questions one by one\n\nWhat subject would you like to be quizzed on?";
    } else if (lowerQuery.contains('tip') || lowerQuery.contains('study')) {
      return "💡 **Top Study Tips:**\n\n1. **Pomodoro Technique** - Study 25 min, break 5 min\n2. **Active Recall** - Test yourself instead of re-reading\n3. **Spaced Repetition** - Review at increasing intervals\n4. **Teach Others** - Explaining helps you understand\n5. **Sleep Well** - Memory consolidates during sleep\n\nWould you like me to help you set up a study schedule?";
    }

    return "That's an interesting question! 🤔\n\nI'm here to help with:\n• Explaining concepts\n• Creating study materials\n• Quizzing and testing\n• Study planning\n\nCould you tell me more about what you'd like to learn?";
  }

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
