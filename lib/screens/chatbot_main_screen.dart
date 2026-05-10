import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'home_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatMainScreen extends StatefulWidget {
  final String userId;
  const ChatMainScreen({super.key, required this.userId});

  @override
  State<ChatMainScreen> createState() => _ChatMainScreenState();
}

class _ChatMainScreenState extends State<ChatMainScreen> {
  final String baseUrl = "https://web-production-8714e.up.railway.app";
  final TextEditingController controller = TextEditingController();

  final AudioPlayer _audioPlayer = AudioPlayer();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final user = Supabase.instance.client.auth.currentUser;
  final session = Supabase.instance.client.auth.currentSession;

  bool _isListening = false;
  bool isVoiceInput = false;

  String get userId => widget.userId;

  List<ChatSession> chatSessions = [];
  List<Map<String, dynamic>> messages = [];
  String? currentChatId;
  bool isSidebarOpen = false;
  final Color customBlue = const Color(0xff5D8AA8);

  @override
  void initState() {
    super.initState();
    loadChats();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    setState(() {
      messages.add({
        "role": "bot",
        "text":
            "أهلاً بك! أنا لطيف، مساعدك الطبي لأمراض الجلدية. كيف يمكنني مساعدتك اليوم؟\n\nWelcome! I am Lateef, your dermatology assistant. How can I help you today?",
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    controller.dispose();
    super.dispose();
  }

  Future<void> _playBase64Audio(String base64String) async {
    try {
      if (base64String.isEmpty) return;

      final bytes = base64Decode(base64String);

      // حماية من الملفات الفاسدة
      if (bytes.length < 2000) {
        print("❌ Audio file too small → invalid");
        return;
      }

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/temp_audio.mp3');

      await file.writeAsBytes(bytes, flush: true);

      await _audioPlayer.stop();
      await _audioPlayer.play(DeviceFileSource(file.path));
    } catch (e) {
      print("❌ Error playing audio: $e");
    }
  }


  void _listen() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) return;

    if (!_isListening) {
      await _speech.stop();

      bool available = await _speech.initialize(
        onStatus: (val) {
          print("STATUS: $val");

          if (val == "done") {
            setState(() => _isListening = false);

            // ابعتي الرسالة بعد انتهاء التسجيل
            if (controller.text.trim().isNotEmpty) {
              isVoiceInput = true;
              sendMessage(controller.text.trim());
            }
          }
        },

        onError: (val) {
          print("Speech Error: $val");
          setState(() => _isListening = false);
        },
      );

      if (available) {
        setState(() => _isListening = true);

        await _speech.listen(
          localeId: "ar_EG", // مهم جداً
          listenMode: stt.ListenMode.confirmation,
          partialResults: true,

          onResult: (val) {
            print("WORDS: ${val.recognizedWords}");

            setState(() {
              controller.text = val.recognizedWords;
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      await _speech.stop();
    }
  }

  bool isArabic(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }

  void goHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  Future<void> loadChats() async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/chats"),
        headers: {
          "Authorization":
              "Bearer ${Supabase.instance.client.auth.currentSession?.accessToken}",
        },
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          chatSessions = (data as List)
              .map((e) => ChatSession.fromJson(e))
              .toList();
        });
      }
    } catch (e) {
      debugPrint("❌ Error loading chats: $e");
    }
  }

  Future<void> loadMessages(String chatId) async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/chat/$chatId"),
        headers: {
          "Authorization":
              "Bearer ${Supabase.instance.client.auth.currentSession?.accessToken}",
        },
      );
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        setState(() {
          currentChatId = chatId; // تأكد أن الـ ID تم تخزينه هنا
          isVoiceInput = false;
          messages = data.map((msg) {
            return {
              "role": msg["role"] == "assistant" ? "bot" : "user",
              "text": msg["content"],
            };
          }).toList();
        });
      }
    } catch (e) {
      debugPrint("❌ Error loading messages: $e");
    }
  }

  void startNewChat() {
    setState(() {
      currentChatId = null;
      messages = [];
      _addWelcomeMessage();
      isSidebarOpen = false;
      isVoiceInput = false;
    });
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // تحديث الواجهة برسالة المستخدم فوراً
    setState(() {
      messages.add({"role": "user", "text": text});
    });

    String currentInput = text;
    controller.clear();

    try {
      // اختيار الـ endpoint
      String endpoint = isVoiceInput ? "/chat-voice" : "/chat";

      String lang = isArabic(currentInput) ? "ar" : "en";
      final res = await http
    .post(
      Uri.parse("$baseUrl$endpoint"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${session?.accessToken}",
      },
      body: jsonEncode({
        "chat_id": currentChatId,
        "text": currentInput,
        "lang": lang,
      }),
    )
    .timeout(const Duration(seconds: 60));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        String replyText = "";

        if (isVoiceInput) {
          // replyText = data["text"] ?? "";
          replyText = data["text"] ?? data["response"] ?? "No response";
          String? audioBase64 = data["audio"];
          if (audioBase64 != null && audioBase64.isNotEmpty) {
            await _playBase64Audio(audioBase64);
          } else {
            print("❌ No audio returned from backend");
          }
        } else {
          // التعامل مع الرد النصي (سواء كان قائمة مقاطع أو نص مباشر)
          if (data["paragraphs"] is List) {
            replyText = (data["paragraphs"] as List).join("\n");
          } else {
            replyText = data["response"] ?? data["text"] ?? "No response";
          }
        }

        // تحديث الـ chat_id إذا كانت هذه أول رسالة في المحادثة
        if (currentChatId == null && data.containsKey("chat_id")) {
          currentChatId = data["chat_id"].toString();
        }

        setState(() {
          messages.add({"role": "bot", "text": replyText});
          isVoiceInput = false;
        });

        loadChats(); // تحديث القائمة الجانبية لتظهر المحادثة الجديدة أو العنوان المحدث
      } else {
        debugPrint("Server Error: ${res.statusCode}");
      }
    } catch (e) {
      debugPrint("Send Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Connection Error. Please check your server."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              buildTopBar(),
              Expanded(child: buildMessages()),
              buildInput(),
            ],
          ),
          if (isSidebarOpen)
            Stack(
              children: [
                GestureDetector(
                  onTap: () => setState(() => isSidebarOpen = false),
                  child: Container(color: Colors.black26),
                ),
                buildSidebar(),
              ],
            ),
        ],
      ),
    );
  }

  Widget buildTopBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)],
        ),
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_ios, color: customBlue),
              onPressed: goHome,
            ),
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.black),
              onPressed: () => setState(() => isSidebarOpen = true),
            ),
            const Expanded(
              child: Text(
                "Lateef",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add, color: Colors.black),
              onPressed: startNewChat,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMessages() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: messages.length,
      itemBuilder: (context, i) {
        final msg = messages[i];
        final isUser = msg["role"] == "user";
        final text = msg["text"] ?? "";
        final bool isTextArabic = isArabic(text);

        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isUser ? customBlue : Colors.grey[100],
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(15),
                topRight: const Radius.circular(15),
                bottomLeft: Radius.circular(isUser ? 15 : 0),
                bottomRight: Radius.circular(isUser ? 0 : 15),
              ),
            ),
            child: Text(
              text,
              textDirection: isTextArabic
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              style: TextStyle(
                color: isUser ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              _isListening ? Icons.mic : Icons.mic_none,
              color: _isListening ? Colors.red : customBlue,
            ),
            onPressed: _listen,
          ),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: "Describe your skin concern...",
                filled: true,
                fillColor: const Color.fromARGB(255, 231, 231, 231),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              ),
            ),
          ),
          const SizedBox(width: 10),
          FloatingActionButton.small(
            backgroundColor: customBlue,
            elevation: 0,
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                isVoiceInput = false;
                sendMessage(controller.text);
              }
            },
            child: const Icon(Icons.send, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget buildSidebar() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.80,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Row(
                children: [
                  Icon(Icons.history_rounded, color: customBlue, size: 28),
                  const SizedBox(width: 12),
                  const Text(
                    "Chat History",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, indent: 20, endIndent: 20),
            Expanded(
              child: chatSessions.isEmpty
                  ? Center(
                      child: Text(
                        "No chats yet",
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 12,
                      ),
                      itemCount: chatSessions.length,
                      itemBuilder: (context, i) {
                        final chat = chatSessions[i];
                        final bool isSelected = currentChatId == chat.chatId;

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? customBlue.withOpacity(0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            leading: Icon(
                              Icons.chat_bubble_outline_rounded,
                              color: isSelected ? customBlue : Colors.grey[600],
                              size: 20,
                            ),
                            title: Text(
                              chat.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isSelected ? customBlue : Colors.black87,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                isSidebarOpen = false;
                                currentChatId = chat.chatId;
                              });
                              loadMessages(chat.chatId);
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                "Lateef AI Assistant v1.0",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatSession {
  final String chatId;
  final String title;
  ChatSession({required this.chatId, required this.title});
  factory ChatSession.fromJson(Map<String, dynamic> json) => ChatSession(
    chatId: json["chat_id"].toString(),
    title: json["title"] ?? "Untitled Chat",
  );
}
