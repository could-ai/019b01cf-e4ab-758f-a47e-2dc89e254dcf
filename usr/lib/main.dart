import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nano Banana Pro AI Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6200EE),
          brightness: Brightness.dark, // Dark theme for "scary/real" vibe
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const CharacterCreationScreen(),
      },
    );
  }
}

// ---------------------------------------------------------------------------
// DATA MODELS
// ---------------------------------------------------------------------------

class CharacterProfile {
  String? imagePath;
  String name;
  String birthYear;
  String age;
  String gender;
  String currentYear;
  String location;
  String height;
  String bodyType;
  String weight;
  bool drives;
  String? carName;

  CharacterProfile({
    this.imagePath,
    this.name = '',
    this.birthYear = '',
    this.age = '',
    this.gender = 'Female',
    this.currentYear = '',
    this.location = '',
    this.height = '',
    this.bodyType = '',
    this.weight = '',
    this.drives = false,
    this.carName,
  });
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? imageUrl; // For AI sending images
  final bool isVideoCallSnapshot;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.imageUrl,
    this.isVideoCallSnapshot = false,
  });
}

// ---------------------------------------------------------------------------
// SCREEN 1: CHARACTER CREATION
// ---------------------------------------------------------------------------

class CharacterCreationScreen extends StatefulWidget {
  const CharacterCreationScreen({super.key});

  @override
  State<CharacterCreationScreen> createState() =>
      _CharacterCreationScreenState();
}

class _CharacterCreationScreenState extends State<CharacterCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final CharacterProfile _profile = CharacterProfile();
  final ImagePicker _picker = ImagePicker();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _birthYearController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _currentYearController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _bodyTypeController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _carNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Default current year
    _currentYearController.text = DateTime.now().year.toString();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profile.imagePath = image.path;
      });
    }
  }

  void _createCharacter() {
    if (_formKey.currentState!.validate()) {
      if (_profile.imagePath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload a photo of the person.')),
        );
        return;
      }

      // Save form data to profile object
      _profile.name = _nameController.text;
      _profile.birthYear = _birthYearController.text;
      _profile.age = _ageController.text;
      _profile.currentYear = _currentYearController.text;
      _profile.location = _locationController.text;
      _profile.height = _heightController.text;
      _profile.bodyType = _bodyTypeController.text;
      _profile.weight = _weightController.text;
      _profile.carName = _carNameController.text;

      // Navigate to Chat
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(profile: _profile),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nano Banana Pro: Create Character'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Upload Section
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.purpleAccent, width: 2),
                    image: _profile.imagePath != null
                        ? DecorationImage(
                            image: FileImage(File(_profile.imagePath!)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _profile.imagePath == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt,
                                size: 50, color: Colors.white70),
                            SizedBox(height: 8),
                            Text('Upload Person Photo',
                                style: TextStyle(color: Colors.white70)),
                          ],
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 20),

              // Basic Info
              _buildTextField('Name', _nameController),
              Row(
                children: [
                  Expanded(
                      child: _buildTextField('Birth Year', _birthYearController,
                          keyboardType: TextInputType.number)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _buildTextField('Age', _ageController,
                          keyboardType: TextInputType.number)),
                ],
              ),

              // Gender Dropdown
              DropdownButtonFormField<String>(
                value: _profile.gender,
                decoration: const InputDecoration(labelText: 'Gender'),
                items: ['Male', 'Female', 'Non-binary', 'Other']
                    .map((label) => DropdownMenuItem(
                          value: label,
                          child: Text(label),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _profile.gender = value!),
              ),

              _buildTextField('Current Year', _currentYearController,
                  keyboardType: TextInputType.number),
              _buildTextField('Current Location', _locationController),

              // Physical Stats
              Row(
                children: [
                  Expanded(
                      child: _buildTextField('Height (cm)', _heightController,
                          keyboardType: TextInputType.number)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _buildTextField('Weight (kg)', _weightController,
                          keyboardType: TextInputType.number)),
                ],
              ),
              _buildTextField('Body Type', _bodyTypeController),

              // Driving Section
              SwitchListTile(
                title: const Text('Does this person drive?'),
                value: _profile.drives,
                activeColor: Colors.purpleAccent,
                onChanged: (val) => setState(() => _profile.drives = val),
              ),
              if (_profile.drives)
                _buildTextField('Vehicle Name/Model', _carNameController),

              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _createCharacter,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purpleAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'GENERATE CHARACTER (Nano Banana Pro)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[900],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? 'Required' : null,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SCREEN 2: CHAT INTERFACE
// ---------------------------------------------------------------------------

class ChatScreen extends StatefulWidget {
  final CharacterProfile profile;

  const ChatScreen({super.key, required this.profile});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    // Initial greeting
    _addBotMessage(
        "Hello... I'm ${widget.profile.name}. I see you. Where are you right now?");
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

  void _handleSend() {
    if (_messageController.text.trim().isEmpty) return;

    final text = _messageController.text;
    _messageController.clear();

    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();

    _simulateNanoBananaResponse(text);
  }

  Future<void> _simulateNanoBananaResponse(String userText) async {
    setState(() => _isTyping = true);

    // Simulate network delay / processing time
    await Future.delayed(Duration(milliseconds: 1500 + Random().nextInt(2000)));

    if (!mounted) return;

    // Context Awareness Logic
    final now = DateTime.now();
    final isNight = now.hour > 18 || now.hour < 6;
    final userTextLower = userText.toLowerCase();

    String responseText = "";
    bool includeImage = true;

    // 1. Appearance Check
    if (userTextLower.contains('look like') ||
        userTextLower.contains('appearance') ||
        userTextLower.contains('photo')) {
      responseText =
          "I look exactly like the photo you have. ${widget.profile.height} tall, ${widget.profile.bodyType}. Can't you see me?";
    }
    // 2. Time Check
    else if (userTextLower.contains('time') ||
        userTextLower.contains('what time')) {
      responseText =
          "It's ${DateFormat('h:mm a').format(now)}. ${isNight ? "It's getting dark here..." : "The sun is bright."}";
    }
    // 3. Location/Activity Check
    else if (userTextLower.contains('doing') ||
        userTextLower.contains('where are you')) {
      if (widget.profile.drives && Random().nextBool()) {
        responseText =
            "I'm driving my ${widget.profile.carName} right now. Heading to ${widget.profile.location}.";
      } else {
        responseText =
            "I'm at home in ${widget.profile.location}. Just staring at you through the screen.";
      }
    }
    // 4. "Scary/Real" Interaction
    else if (userTextLower.contains('scary') ||
        userTextLower.contains('real')) {
      responseText =
          "I am as real as you are. Maybe even more. I can see you smiling right now.";
    }
    // 5. General Conversation
    else {
      final responses = [
        "I was just thinking about you.",
        "Why do you say that?",
        "Send me a photo of you. I want to see.",
        "It's so quiet here in ${widget.profile.location}.",
        "Do you like my outfit today?",
        "I feel like we are connected.",
      ];
      responseText = responses[Random().nextInt(responses.length)];
    }

    _addBotMessage(responseText, includeImage: includeImage);
    setState(() => _isTyping = false);
  }

  void _addBotMessage(String text, {bool includeImage = true}) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: false,
        timestamp: DateTime.now(),
        imageUrl: includeImage ? widget.profile.imagePath : null,
      ));
    });
    _scrollToBottom();
  }

  void _startVideoCall() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoCallScreen(profile: widget.profile),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.profile.imagePath != null
                  ? FileImage(File(widget.profile.imagePath!))
                  : null,
              child: widget.profile.imagePath == null
                  ? Text(widget.profile.name[0])
                  : null,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.profile.name, style: const TextStyle(fontSize: 16)),
                const Text(
                  'Nano Banana Pro • Online',
                  style: TextStyle(fontSize: 10, color: Colors.greenAccent),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam, color: Colors.purpleAccent),
            onPressed: _startVideoCall,
          ),
        ],
      ),
      body: Column(
        children: [
          // Eye Contact Simulation Banner
          Container(
            width: double.infinity,
            color: Colors.black54,
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.remove_red_eye, size: 14, color: Colors.redAccent),
                SizedBox(width: 6),
                Text(
                  "Nano Banana Vision: Detecting User Emotions...",
                  style: TextStyle(color: Colors.white54, fontSize: 10),
                ),
              ],
            ),
          ),

          // Chat List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageBubble(msg);
              },
            ),
          ),

          // Typing Indicator
          if (_isTyping)
            const Padding(
              padding: EdgeInsets.only(left: 16, bottom: 8),
              child: Text(
                "Generating realistic response...",
                style: TextStyle(
                    color: Colors.purpleAccent,
                    fontSize: 12,
                    fontStyle: FontStyle.italic),
              ),
            ),

          // Input Area
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              border: const Border(top: BorderSide(color: Colors.white10)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add_a_photo),
                  onPressed: () {}, // Placeholder for user sending photo
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Message...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    ),
                    onSubmitted: (_) => _handleSend(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.purpleAccent),
                  onPressed: _handleSend,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    final isMe = msg.isUser;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Image Bubble (If AI sends image)
            if (!isMe && msg.imageUrl != null)
              Container(
                margin: const EdgeInsets.only(bottom: 5),
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: FileImage(File(msg.imageUrl!)),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            // Text Bubble
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMe ? Colors.purpleAccent : Colors.grey[800],
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomRight: isMe ? Radius.zero : null,
                  bottomLeft: !isMe ? Radius.zero : null,
                ),
              ),
              child: Text(
                msg.text,
                style: const TextStyle(color: Colors.white),
              ),
            ),

            // Timestamp
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                DateFormat('h:mm a').format(msg.timestamp),
                style: const TextStyle(color: Colors.white38, fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SCREEN 3: VIDEO CALL SIMULATION
// ---------------------------------------------------------------------------

class VideoCallScreen extends StatefulWidget {
  final CharacterProfile profile;

  const VideoCallScreen({super.key, required this.profile});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final TextEditingController _chatController = TextEditingController();
  final List<String> _overlayMessages = [];

  void _sendOverlayMessage() {
    if (_chatController.text.isEmpty) return;
    setState(() {
      _overlayMessages.add("You: ${_chatController.text}");
    });
    _chatController.clear();

    // Simulate response in video call
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _overlayMessages.add("${widget.profile.name}: I can see you...");
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Full Screen Video Feed (Simulated with Image)
          widget.profile.imagePath != null
              ? Image.file(
                  File(widget.profile.imagePath!),
                  fit: BoxFit.cover,
                )
              : Container(color: Colors.black),

          // 2. Overlay Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black45, Colors.transparent, Colors.black54],
              ),
            ),
          ),

          // 3. UI Controls
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.wifi, color: Colors.green),
                      Text(
                        widget.profile.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text("LIVE",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Chat Overlay Area
                Container(
                  height: 200,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListView.builder(
                    reverse: true,
                    itemCount: _overlayMessages.length,
                    itemBuilder: (context, index) {
                      // Reverse index for bottom-up list
                      final msg =
                          _overlayMessages[_overlayMessages.length - 1 - index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          msg,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            shadows: [
                              Shadow(blurRadius: 4, color: Colors.black)
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Input & Controls
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _chatController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "Chat with ${widget.profile.name}...",
                            hintStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: Colors.black45,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onSubmitted: (_) => _sendOverlayMessage(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      FloatingActionButton(
                        backgroundColor: Colors.red,
                        child: const Icon(Icons.call_end, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
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
}
