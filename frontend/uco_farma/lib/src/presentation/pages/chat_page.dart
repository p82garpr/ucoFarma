import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/auth_provider.dart';
import 'dart:math' show sin;
import 'package:flutter_markdown/flutter_markdown.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeChatbot();
    });
  }

  void _initializeChatbot() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    
    if (authProvider.user?.medicines != null) {
      chatProvider.setUserMedicines(authProvider.user!.medicines);
    }

    if (chatProvider.messages.isEmpty) {
      chatProvider.addBotMessage('¡Hola! ¿En qué puedo ayudarte?');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = Provider.of<AuthProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    
    // Actualizar los medicamentos cuando cambien
    if (authProvider.user?.medicines != null) {
      chatProvider.setUserMedicines(authProvider.user!.medicines);
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Stack(
      children: [
        /*Positioned.fill(
          child: Opacity(
            opacity: 0.5,
            child: Image.asset(
              'assets/images/logo-removebg.png',
              width: 50,
              height: 50,
              fit: BoxFit.cover, // Asegúrate de que el logo se ajuste correctamente
            ),
          ),
        ),*/
        Column(
          children: [
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, chatProvider, _) {
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: chatProvider.messages.length + (chatProvider.isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == chatProvider.messages.length && chatProvider.isLoading) {
                        return const TypingIndicator();
                      }
                      final message = chatProvider.messages[index];
                      return IgnorePointer(
                        child: Align(
                          alignment: message.isUserMessage 
                            ? Alignment.centerRight 
                            : Alignment.centerLeft,
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.75,
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: message.isUserMessage
                                ? theme.colorScheme.primary
                                : theme.colorScheme.secondary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Markdown(
                              data: message.text,
                              shrinkWrap: true,
                              styleSheet: MarkdownStyleSheet(
                                p: theme.textTheme.bodyMedium?.copyWith(
                                  color: message.isUserMessage
                                    ? theme.colorScheme.onPrimary
                                    : theme.colorScheme.onSecondary,
                                ),
                                strong: theme.textTheme.bodyMedium?.copyWith(
                                  color: message.isUserMessage
                                    ? theme.colorScheme.onPrimary
                                    : theme.colorScheme.onSecondary,
                                  fontWeight: FontWeight.bold,
                                ),
                                em: theme.textTheme.bodyMedium?.copyWith(
                                  color: message.isUserMessage
                                    ? theme.colorScheme.onPrimary
                                    : theme.colorScheme.onSecondary,
                                  fontStyle: FontStyle.italic,
                                ),
                                h1: theme.textTheme.titleLarge?.copyWith(
                                  color: message.isUserMessage
                                    ? theme.colorScheme.onPrimary
                                    : theme.colorScheme.onSecondary,
                                ),
                                h2: theme.textTheme.titleMedium?.copyWith(
                                  color: message.isUserMessage
                                    ? theme.colorScheme.onPrimary
                                    : theme.colorScheme.onSecondary,
                                ),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      // Mostrar diálogo de confirmación
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Limpiar chat'),
                          content: const Text('¿Estás seguro de que deseas borrar todo el historial del chat?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: theme.colorScheme.error,
                              ),
                              onPressed: () {
                                final chatProvider = Provider.of<ChatProvider>(
                                  context, 
                                  listen: false
                                );
                                chatProvider.clearChat();
                                Navigator.pop(context);
                              },
                              child: const Text('Limpiar'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.delete_outline,
                      color: theme.colorScheme.error,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        hintText: 'Escribe un mensaje...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Consumer<ChatProvider>(
                    builder: (context, chatProvider, _) {
                      return IconButton(
                        onPressed: chatProvider.isLoading
                          ? null
                          : () {
                              if (_textController.text.trim().isEmpty) return;
                              
                              chatProvider.sendMessage(_textController.text);
                              _textController.clear();
                              
                              Future.delayed(
                                const Duration(milliseconds: 100),
                                _scrollToBottom,
                              );
                            },
                        icon: const Icon(Icons.send),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  height: 6,
                  width: 6,
                  transform: Matrix4.translationValues(
                    0, 
                    -4 * sin((_controller.value * 2 * 3.14159) + (index * 1.0)), 
                    0
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSecondary,
                    shape: BoxShape.circle,
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}