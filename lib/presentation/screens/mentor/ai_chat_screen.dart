/// AI Chat Screen
/// Enhanced chat interface matching StudySmarter design with mascot and quick actions.
library;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:studnet_ai_buddy/di/service_locator.dart';
import 'package:studnet_ai_buddy/domain/services/ai_mentor_service.dart';
import 'package:studnet_ai_buddy/domain/repositories/academic_repository.dart'; // Added
import 'package:studnet_ai_buddy/domain/entities/academic_profile.dart'; // Added
import 'package:studnet_ai_buddy/core/utils/result.dart'; // Added
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_colors.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_decorations.dart';
import 'package:studnet_ai_buddy/presentation/widgets/core/chat_bubble.dart';
import 'package:studnet_ai_buddy/presentation/widgets/core/gradient_scaffold.dart';
import 'package:studnet_ai_buddy/presentation/widgets/core/mascot_widget.dart';
import 'package:studnet_ai_buddy/presentation/widgets/core/quick_action_button.dart';

/// Enhanced chat screen for AI interactions matching StudySmarter design.
class AIChatScreen extends StatefulWidget {
  final String? subjectTitle;

  const AIChatScreen({super.key, this.subjectTitle});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessageData> _messages = [];
  bool _isTyping = false;
  bool _isThinking = false;
  int _messageCount = 0;
  static const int _maxMessages = 10;

  @override
  void initState() {
    super.initState();
    _loadInitialMessage();
  }

  void _loadInitialMessage() {
    // Load initial greeting based on context
    final greeting = widget.subjectTitle != null
        ? "Great! To create flashcards for your ${widget.subjectTitle} exam, could you tell me which topics or areas you'd like to focus on? Also, let me know the difficulty level (easy, medium, hard) and how many flashcards you'd prefer."
        : "Hello! I'm your AI Study Buddy. How can I help you today?";

    _messages.add(
      ChatMessageData(
        text: greeting,
        isUser: false,
        quickActions: _getInitialQuickActions(),
      ),
    );
  }

  List<QuickActionData> _getInitialQuickActions() {
    if (widget.subjectTitle != null) {
      return [
        QuickActionData(
          text: 'Create flashcards from your file',
          onTap: () => _handleQuickAction('Create flashcards from your file'),
        ),
        QuickActionData(
          text: 'Create flashcards without a file',
          onTap: () => _handleQuickAction('Create flashcards without a file'),
        ),
      ];
    }
    return [];
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleQuickAction(String actionText) {
    _sendMessage(actionText, isQuickAction: true);
  }

  Future<void> _sendMessage(String text, {bool isQuickAction = false}) async {
    if (text.isEmpty || _messageCount >= _maxMessages) return;

    setState(() {
      _messages.add(ChatMessageData(text: text, isUser: true));
      _messageCount++;
      _isTyping = true;
      _isThinking = true;
      if (!isQuickAction) {
        _messageController.clear();
      }
    });

    _scrollToBottom();

    // Get AI response
    try {
      final aiService = getIt<AIMentorService>();

      // Fetch profile context if possible (basic implementation for now)
      // Ideally this should be in a ViewModel or cached
      AcademicProfile? profile;
      try {
        final academicRepo = getIt<AcademicRepository>();
        final result = await academicRepo.getAcademicProfile();
        if (result is Success) {
          profile = (result as Success<AcademicProfile?>).value;
        }
      } catch (_) {
        // Ignore profile fetch error
      }

      final response = await aiService.answerQuery(
        query: text,
        profile: profile,
      );

      if (mounted) {
        setState(() {
          _isTyping = false;
          _isThinking = false;
          _messages.add(
            ChatMessageData(
              text: response,
              isUser: false,
              quickActions: _getQuickActionsForResponse(text, response),
            ),
          );
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _isThinking = false;
          _messages.add(
            ChatMessageData(
              text: _getFallbackResponse(text),
              isUser: false,
              quickActions: _getQuickActionsForResponse(text, ''),
            ),
          );
        });
        _scrollToBottom();
      }
    }
  }

  List<QuickActionData>? _getQuickActionsForResponse(
    String userMessage,
    String aiResponse,
  ) {
    final lowerMessage = userMessage.toLowerCase();
    final lowerResponse = aiResponse.toLowerCase();

    if (lowerMessage.contains('flashcard') ||
        lowerResponse.contains('flashcard')) {
      return [
        QuickActionData(
          text: 'Specify topics and difficulty',
          onTap: () => _handleQuickAction('Specify topics and difficulty'),
        ),
      ];
    }

    if (lowerResponse.contains('specify') || lowerResponse.contains('topics')) {
      return null; // User needs to type response
    }

    return null;
  }

  String _getFallbackResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();

    if (lowerMessage.contains('flashcard')) {
      return "Please specify the topics within ${widget.subjectTitle ?? 'your subject'} you'd like the flashcards to cover, and your preferred difficulty level (easy, medium, or hard). Also, let me know approximately how many flashcards you want.";
    }

    if (lowerMessage.contains('create') && lowerMessage.contains('new')) {
      return "Thanks for the details! I'll prepare the flashcards for you. Would you like me to add these flashcards to your existing study set or create a new one?";
    }

    return "I understand. Let me help you with that. Could you provide more details?";
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleFileUpload() async {
    // File picker for uploading attachments
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'jpg', 'png'],
      );
      if (result != null && result.files.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Selected: ${result.files.first.name}'),
              backgroundColor: StudyBuddyColors.success,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File upload coming soon'),
            backgroundColor: StudyBuddyColors.cardBackground,
          ),
        );
      }
    }
  }

  void _showChatMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: StudyBuddyColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.delete_outline_rounded,
                color: StudyBuddyColors.textPrimary,
              ),
              title: const Text(
                'Clear Chat',
                style: TextStyle(color: StudyBuddyColors.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                setState(() => _messages.clear());
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.share_rounded,
                color: StudyBuddyColors.textPrimary,
              ),
              title: const Text(
                'Share Conversation',
                style: TextStyle(color: StudyBuddyColors.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sharing coming soon!')),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: Column(
        children: [
          // Header
          Padding(
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
                Expanded(
                  child: Text(
                    widget.subjectTitle ?? 'AI Study Buddy',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: StudyBuddyColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const IconButton(
                  onPressed: null,
                  icon: Icon(
                    Icons.lock_rounded,
                    color: StudyBuddyColors.textTertiary,
                    size: 20,
                  ),
                ),
                IconButton(
                  onPressed: () => _showChatMenu(),
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    color: StudyBuddyColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: StudyBuddyColors.border, height: 1),

          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return _buildTypingIndicator();
                }
                return _buildMessage(_messages[index]);
              },
            ),
          ),

          // Message limit indicator
          if (_messageCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: StudyBuddyColors.cardBackground,
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 14,
                    color: StudyBuddyColors.textTertiary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'You can send up to ${_maxMessages - _messageCount} more messages',
                    style: const TextStyle(
                      fontSize: 12,
                      color: StudyBuddyColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),

          // Input bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: StudyBuddyColors.cardBackground,
              border: const Border(
                top: BorderSide(color: StudyBuddyColors.border),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: _handleFileUpload,
                  icon: const Icon(
                    Icons.camera_alt_rounded,
                    color: StudyBuddyColors.textSecondary,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    enabled: _messageCount < _maxMessages,
                    style: const TextStyle(color: StudyBuddyColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Ask me anything...',
                      hintStyle: const TextStyle(
                        color: StudyBuddyColors.textTertiary,
                      ),
                      filled: true,
                      fillColor: StudyBuddyColors.backgroundLight,
                      border: OutlineInputBorder(
                        borderRadius: StudyBuddyDecorations.borderRadiusFull,
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) {
                      if (_messageCount < _maxMessages) {
                        _sendMessage(_messageController.text);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: _messageCount < _maxMessages
                      ? () => _sendMessage(_messageController.text)
                      : null,
                  icon: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: _messageCount < _maxMessages
                              ? StudyBuddyColors.primary
                              : StudyBuddyColors.textTertiary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      if (_messageCount > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: const BoxDecoration(
                              color: StudyBuddyColors.warning,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '$_messageCount/$_maxMessages',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessageData message) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!message.isUser) ...[
          const SizedBox(width: 8),
          Column(
            children: [
              const MascotWidget(
                expression: MascotExpression.speaking,
                size: MascotSize.small,
              ),
              const SizedBox(height: 4),
              const Text(
                'Assistant',
                style: TextStyle(
                  fontSize: 10,
                  color: StudyBuddyColors.textTertiary,
                ),
              ),
              const Text(
                'BETA',
                style: TextStyle(
                  fontSize: 8,
                  color: StudyBuddyColors.textTertiary,
                ),
              ),
              if (_isThinking) ...[
                const SizedBox(height: 4),
                const Text(
                  'Thinking...',
                  style: TextStyle(
                    fontSize: 10,
                    color: StudyBuddyColors.primary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: ChatBubble(
            text: message.text,
            isUser: message.isUser,
            quickActions: message.quickActions
                ?.map(
                  (action) =>
                      QuickActionButton(text: action.text, onTap: action.onTap),
                )
                .toList(),
          ),
        ),
        if (message.isUser) const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildTypingIndicator() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          SizedBox(width: 8),
          Column(
            children: [
              MascotWidget(
                expression: MascotExpression.thinking,
                size: MascotSize.small,
              ),
              SizedBox(height: 4),
              Text(
                'Assistant',
                style: TextStyle(
                  fontSize: 10,
                  color: StudyBuddyColors.textTertiary,
                ),
              ),
              Text(
                'BETA',
                style: TextStyle(
                  fontSize: 8,
                  color: StudyBuddyColors.textTertiary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Thinking...',
                style: TextStyle(
                  fontSize: 10,
                  color: StudyBuddyColors.primary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          SizedBox(width: 8),
          Expanded(child: TypingIndicator()),
        ],
      ),
    );
  }
}

/// Chat message data model.
class ChatMessageData {
  final String text;
  final bool isUser;
  final List<QuickActionData>? quickActions;

  ChatMessageData({required this.text, this.isUser = false, this.quickActions});
}

/// Quick action data model.
class QuickActionData {
  final String text;
  final VoidCallback onTap;

  QuickActionData({required this.text, required this.onTap});
}
