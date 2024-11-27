import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

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
    
    return Column(
      children: [
        Expanded(
          child: Consumer<ChatProvider>(
            builder: (context, chatProvider, _) {
              if (chatProvider.messages.isEmpty) {
                return Center(
                  child: Text(
                    '¡Hola! ¿En qué puedo ayudarte?',
                    style: theme.textTheme.titleMedium,
                  ),
                );
              }
              
              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: chatProvider.messages.length,
                itemBuilder: (context, index) {
                  final message = chatProvider.messages[index];
                  return Align(
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
                      child: Text(
                        message.text,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: message.isUserMessage
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSecondary,
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
                    icon: chatProvider.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(),
                        )
                      : const Icon(Icons.send),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}