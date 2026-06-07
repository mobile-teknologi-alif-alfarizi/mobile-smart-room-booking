import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_app/services/chat_service.dart';
import 'package:mobile_app/services/auth_service.dart';
import 'package:mobile_app/theme/app_colors.dart';

class ChatRoomScreen extends StatefulWidget {
  final int recipientId;
  final String recipientName;
  final String recipientRole;
  final String recipientNomorInduk;

  const ChatRoomScreen({
    super.key,
    required this.recipientId,
    required this.recipientName,
    required this.recipientRole,
    required this.recipientNomorInduk,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<dynamic> _messages = [];
  Map<String, dynamic>? _currentUser;
  bool _isLoading = true;
  bool _isSending = false;
  String? _errorMessage;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadUserAndMessages();
    // Start periodic polling every 3 seconds to get new messages
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _pollMessages();
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUserAndMessages() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final user = await _authService.getStoredUser();
      _currentUser = user;

      // Mark all messages as read
      await _chatService.markConversationAsSeen(widget.recipientId);

      // Load conversation messages
      final messagesList = await _chatService.getConversation(widget.recipientId);

      if (!mounted) return;

      setState(() {
        _messages = messagesList;
        _isLoading = false;
      });

      // Scroll to bottom
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  Future<void> _pollMessages() async {
    try {
      final messagesList = await _chatService.getConversation(widget.recipientId);
      if (!mounted) return;

      // If message count changes, scroll to bottom and update UI
      final hasNewMessages = messagesList.length != _messages.length;
      setState(() {
        _messages = messagesList;
      });

      if (hasNewMessages) {
        _scrollToBottom();
        // Mark as seen when new messages arrive while user is in screen
        _chatService.markConversationAsSeen(widget.recipientId);
      }
    } catch (_) {
      // Ignore background refresh errors
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

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
    });

    try {
      _messageController.clear();
      final sentMessage = await _chatService.sendMessage(widget.recipientId, text);

      if (!mounted) return;

      setState(() {
        _isSending = false;
        _messages.add(sentMessage);
      });

      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSending = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengirim pesan: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _deleteMessage(String uuid, int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Pesan', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Apakah Anda yakin ingin menghapus pesan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _chatService.deleteMessage(uuid);
      setState(() {
        _messages.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pesan berhasil dihapus'),
          backgroundColor: AppColors.accent,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus pesan: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  String _formatTimeOnly(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';
    try {
      final parsed = DateTime.parse(dateString).toLocal();
      return '${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  String _formatDateSeparator(DateTime date) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 1,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
          color: AppColors.textPrimary,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.recipientName,
              style: TextStyle(
                fontSize: isMobile ? 15 : 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Admin • ${widget.recipientNomorInduk}',
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  )
                : _errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.cloud_off_rounded, size: 48, color: AppColors.error),
                              const SizedBox(height: 12),
                              Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: _loadUserAndMessages,
                                child: const Text('Coba Lagi'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _messages.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.06),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.chat_bubble_outline_rounded,
                                    color: AppColors.primary,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Belum ada pesan',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Kirim pesan pertama Anda untuk memulai chat.',
                                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            itemCount: _messages.length,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            itemBuilder: (ctx, index) {
                              final message = _messages[index];
                              final sentId = message['sent_id']?.toString() ?? '';
                              final currentId = _currentUser?['id']?.toString() ?? '';
                              final isMine = sentId == currentId;

                              // Date separator logic
                              bool showDateSeparator = false;
                              DateTime? currentDate;
                              try {
                                currentDate = DateTime.parse(message['created_at'].toString()).toLocal();
                                if (index == 0) {
                                  showDateSeparator = true;
                                } else {
                                  final prevDate = DateTime.parse(_messages[index - 1]['created_at'].toString()).toLocal();
                                  if (currentDate.year != prevDate.year ||
                                      currentDate.month != prevDate.month ||
                                      currentDate.day != prevDate.day) {
                                    showDateSeparator = true;
                                  }
                                }
                              } catch (_) {}

                              return Column(
                                children: [
                                  if (showDateSeparator && currentDate != null)
                                    Container(
                                      margin: const EdgeInsets.symmetric(vertical: 16),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: AppColors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: AppColors.borderLight),
                                      ),
                                      child: Text(
                                        _formatDateSeparator(currentDate),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: AppColors.textTertiary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  Align(
                                    alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                                    child: GestureDetector(
                                      onLongPress: isMine && message['uuid'] != null
                                          ? () => _deleteMessage(message['uuid'].toString(), index)
                                          : null,
                                      child: Container(
                                        margin: EdgeInsets.only(
                                          bottom: 10,
                                          left: isMine ? 50 : 0,
                                          right: isMine ? 0 : 50,
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                        decoration: BoxDecoration(
                                          gradient: isMine
                                              ? const LinearGradient(
                                                  colors: AppColors.primaryGradient,
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                )
                                              : null,
                                          color: isMine ? null : AppColors.white,
                                          borderRadius: BorderRadius.only(
                                            topLeft: const Radius.circular(16),
                                            topRight: const Radius.circular(16),
                                            bottomLeft: isMine ? const Radius.circular(16) : Radius.zero,
                                            bottomRight: isMine ? Radius.zero : const Radius.circular(16),
                                          ),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: AppColors.shadow,
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            )
                                          ],
                                          border: isMine ? null : Border.all(color: AppColors.borderLight),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              message['message']?.toString() ?? '',
                                              style: TextStyle(
                                                color: isMine ? AppColors.white : AppColors.textPrimary,
                                                fontSize: 13,
                                                height: 1.4,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  _formatTimeOnly(message['created_at']?.toString()),
                                                  style: TextStyle(
                                                    color: isMine ? AppColors.white.withOpacity(0.7) : AppColors.textTertiary,
                                                    fontSize: 9,
                                                  ),
                                                ),
                                                if (isMine) ...[
                                                  const SizedBox(width: 4),
                                                  Icon(
                                                    message['status_seen'] == true ? Icons.done_all : Icons.done,
                                                    color: AppColors.white.withOpacity(0.7),
                                                    size: 11,
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.white,
              border: Border(top: BorderSide(color: AppColors.borderLight)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.lightGray,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _messageController,
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: 'Ketik pesan...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                      style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: _sendMessage,
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: AppColors.primaryGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: AppColors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
