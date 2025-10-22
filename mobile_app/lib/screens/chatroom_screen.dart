import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:gyanvruksh/services/enhanced_api_service.dart';
import 'package:gyanvruksh/widgets/glassmorphism_card.dart';
import 'package:gyanvruksh/widgets/custom_form_field.dart';
import 'package:gyanvruksh/widgets/custom_animated_button.dart';
import 'package:gyanvruksh/widgets/backgrounds/cinematic_background.dart';
import 'package:gyanvruksh/widgets/particle_background.dart';
import 'package:gyanvruksh/widgets/floating_elements.dart';
import 'package:gyanvruksh/widgets/animated_wave_background.dart';
import 'package:gyanvruksh/widgets/micro_interactions.dart';
import 'package:gyanvruksh/widgets/animated_text_widget.dart';
import 'package:gyanvruksh/theme/futuristic_theme.dart';
import 'dart:convert';

class ChatroomScreen extends StatefulWidget {
  const ChatroomScreen({super.key});

  @override
  State<ChatroomScreen> createState() => _ChatroomScreenState();
}

class _ChatroomScreenState extends State<ChatroomScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController = ScrollController();
  late WebSocketChannel _channel;
  bool _isConnected = false;
  late AnimationController _backgroundController;
  late Animation<Color?> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat(reverse: true);

    _backgroundAnimation = ColorTween(
      begin: const Color(0xFF667EEA),
      end: const Color(0xFF764BA2),
    ).animate(_backgroundController);

    _connectToWebSocket();
    _loadPreviousMessages();
  }

  void _connectToWebSocket() {
    final user = ApiService.currentUser;
    if (user == null) return;

    _channel = WebSocketChannel.connect(
      Uri.parse('${ApiService.baseUrl.replaceFirst('http', 'ws')}/api/chat/ws'),
    );

    _channel.stream.listen(
      (message) {
        final data = jsonDecode(message);
        setState(() {
          _messages.add(data);
        });
        _scrollToBottom();
      },
      onDone: () {
        setState(() {
          _isConnected = false;
        });
      },
      onError: (error) {
        setState(() {
          _isConnected = false;
        });
      },
    );

    setState(() {
      _isConnected = true;
    });
  }

  Future<void> _loadPreviousMessages() async {
    try {
      // For now, we'll skip loading previous messages since getChatMessages doesn't exist
      // final messages = await ApiService().getChatMessages();
      // setState(() {
      //   _messages.addAll(messages.cast<Map<String, dynamic>>());
      // });
      _scrollToBottom();
    } catch (e) {
      // Handle error
    }
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

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final user = ApiService.currentUser;
    if (user == null) return;

    final messageData = {
      'user_id': user['id'],
      'message': _messageController.text.trim(),
    };

    _channel.sink.add(jsonEncode(messageData));
    _messageController.clear();
  }

  @override
  void dispose() {
    _channel.sink.close();
    _messageController.dispose();
    _scrollController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, bool isMe, int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: GlassmorphismCard(
          width: null,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          blurStrength: 10,
          opacity: 0.1,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(4),
            bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isMe)
                Text(
                  message['full_name'] ?? 'Unknown',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                message['message'],
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                message['timestamp'] ?? '',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      )
          .animate()
          .fadeIn(duration: 400.ms, delay: Duration(milliseconds: index * 50))
          .slideX(
            begin: isMe ? 0.2 : -0.2,
            end: 0,
            duration: 300.ms,
            delay: Duration(milliseconds: index * 50),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final user = ApiService.currentUser;

    return Scaffold(
      body: Stack(
        children: [
          // Cinematic Background
          CinematicBackground(isDark: false),

          // Enhanced Particle Background
          ParticleBackground(
            particleCount: 25,
            maxParticleSize: 3.0,
            particleColor: FuturisticColors.primary,
          ),

          // Floating Elements
          FloatingElements(
            elementCount: 6,
            maxElementSize: 40,
            icons: const [
              Icons.chat,
              Icons.message,
              Icons.people,
              Icons.forum,
              Icons.question_answer,
              Icons.group,
            ],
          ),

          // Animated Wave Background
          AnimatedWaveBackground(
            color: FuturisticColors.neonBlue.withOpacity(0.03),
            height: MediaQuery.of(context).size.height,
          ),

          SafeArea(
            child: Column(
              children: [
                // Enhanced Header with Glassmorphism
                GlassmorphismCard(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  blurStrength: 15,
                  opacity: 0.1,
                  borderRadius: BorderRadius.circular(20),
                  child: Row(
                    children: [
                      MicroInteractionWrapper(
                        child: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(
                            Icons.arrow_back,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AnimatedTextWidget(
                          text: 'Community Chat',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: FuturisticColors.primary.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          animationType: AnimationType.fade,
                          duration: const Duration(milliseconds: 800),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _isConnected
                                  ? FuturisticColors.primary.withOpacity(0.2)
                                  : Colors.red.withOpacity(0.2),
                              _isConnected
                                  ? FuturisticColors.secondary.withOpacity(0.2)
                                  : Colors.red.withOpacity(0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          _isConnected ? Icons.wifi : Icons.wifi_off,
                          color: _isConnected ? FuturisticColors.primary : Colors.red,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(duration: 600.ms)
                .slideY(begin: -0.2, end: 0, duration: 500.ms),

                // Messages List
                Expanded(
                  child: _messages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                FontAwesomeIcons.comments,
                                size: 64,
                                color: colorScheme.onSurface.withOpacity(0.3),
                              ),
                              const SizedBox(height: 16),
                              AnimatedTextWidget(
                                text: 'No messages yet',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.6),
                                ),
                                animationType: AnimationType.fade,
                                duration: const Duration(milliseconds: 600),
                              ),
                              const SizedBox(height: 8),
                              AnimatedTextWidget(
                                text: 'Start the conversation!',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.4),
                                ),
                                animationType: AnimationType.fade,
                                duration: const Duration(milliseconds: 600),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final message = _messages[index];
                            final isMe = message['user_id'] == user?['id'];
                            return _buildMessageBubble(message, isMe, index);
                          },
                        ),
                ),

                // Enhanced Message Input
                GlassmorphismCard(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  blurStrength: 15,
                  opacity: 0.1,
                  borderRadius: BorderRadius.circular(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomFormField(
                          controller: _messageController,
                          labelText: 'Message',
                          hintText: 'Type a message...',
                          prefixIcon: Icons.message_outlined,
                          maxLines: 3,
                        ),
                      ),
                      const SizedBox(width: 12),
                      MicroInteractionWrapper(
                        child: CustomAnimatedButton(
                          text: 'Send',
                          onPressed: _sendMessage,
                          width: 50,
                          height: 50,
                          backgroundColor: FuturisticColors.primary,
                        ),
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(duration: 600.ms, delay: 400.ms)
                .slideY(begin: 0.2, end: 0, duration: 500.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
