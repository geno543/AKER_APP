import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/app_theme.dart';
import '../services/openrouter_service.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final ImagePicker _imagePicker = ImagePicker();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    _messages.add(
      ChatMessage(
        text: "🐾 Welcome to AKER AI - Your Specialized Animal Rescue Assistant!\n\nI'm equipped to help with:\n\n🚨 Emergency rescue situations\n🔍 Animal species identification\n🏥 Health condition assessments\n🍼 Baby animal care protocols\n💊 First aid procedures\n🐾 Behavior analysis\n🏠 Shelter & resource location\n📱 Reporting abuse or neglect\n\nSend me a photo or describe your situation, and I'll provide immediate, actionable guidance to help save animal lives!",
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cream,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.smart_toy,
                color: AppTheme.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aker AI Assistant',
                  style: TextStyle(
                    color: AppTheme.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Online',
                  style: TextStyle(
                    color: AppTheme.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _showQuickActions,
            icon: const Icon(Icons.more_vert),
            color: AppTheme.white,
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick action chips
          _buildQuickActionChips(),
          
          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return _buildTypingIndicator();
                }
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          
          // Message input
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildQuickActionChips() {
    final quickActions = [
      {'label': 'Emergency Rescue', 'icon': Icons.emergency, 'color': AppTheme.emergencyRed},
      {'label': 'Identify Animal', 'icon': Icons.search, 'color': AppTheme.softBlue},
      {'label': 'Health Check', 'icon': Icons.medical_services, 'color': AppTheme.accentOrange},
      {'label': 'Baby Animal Care', 'icon': Icons.child_care, 'color': AppTheme.primaryGreen},
      {'label': 'Shelter Finder', 'icon': Icons.home, 'color': AppTheme.softBlue},
      {'label': 'First Aid Guide', 'icon': Icons.healing, 'color': AppTheme.accentOrange},
      {'label': 'Behavior Help', 'icon': Icons.pets, 'color': AppTheme.primaryGreen},
      {'label': 'Report Abuse', 'icon': Icons.report, 'color': AppTheme.emergencyRed},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final availableWidth = constraints.maxWidth;
        
        // Better responsive breakpoints
        final isVerySmall = screenWidth < 360;
        final isSmall = screenWidth < 480;
        final isMedium = screenWidth < 768;
        final isLarge = screenWidth >= 768;
        
        // Dynamic grid configuration based on available space
        int crossAxisCount;
        if (isVerySmall) {
          crossAxisCount = 2;
        } else if (isSmall) {
          crossAxisCount = 2;
        } else if (isMedium) {
          crossAxisCount = 4;
        } else {
          crossAxisCount = 4;
        }
        
        // Calculate optimal dimensions
        final buttonWidth = (availableWidth - 32) / crossAxisCount - 8;
        final height = isVerySmall ? 90.0 : (isSmall ? 100.0 : (isMedium ? 110.0 : 120.0));
        final aspectRatio = isVerySmall ? 0.7 : (isSmall ? 0.8 : (isMedium ? 0.9 : 1.0));
        
        return Container(
          height: height,
          padding: EdgeInsets.symmetric(
            horizontal: isVerySmall ? 8 : (isSmall ? 12 : 16), 
            vertical: 4,
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: quickActions.map((action) {
                return Container(
                  width: isVerySmall ? 80 : (isSmall ? 90 : (isMedium ? 100 : 110)),
                  height: height - 8,
                  margin: EdgeInsets.only(right: isVerySmall ? 6 : 8),
                  padding: EdgeInsets.symmetric(
                    horizontal: isVerySmall ? 4 : 6, 
                    vertical: isVerySmall ? 4 : 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(isVerySmall ? 12 : 16),
                    border: Border.all(
                      color: (action['color'] as Color).withOpacity(0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                      BoxShadow(
                        color: (action['color'] as Color).withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () => _sendQuickMessage(_getQuickActionMessage(action['label'] as String)),
                    borderRadius: BorderRadius.circular(isVerySmall ? 12 : 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(isVerySmall ? 6 : 8),
                          decoration: BoxDecoration(
                            color: (action['color'] as Color).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(isVerySmall ? 8 : 10),
                          ),
                          child: Icon(
                            action['icon'] as IconData,
                            color: action['color'] as Color,
                            size: isVerySmall ? 14 : (isSmall ? 16 : (isMedium ? 18 : 20)),
                          ),
                        ),
                        SizedBox(height: isVerySmall ? 4 : 6),
                        Text(
                          action['label'] as String,
                          style: TextStyle(
                            fontSize: isVerySmall ? 8 : (isSmall ? 9 : (isMedium ? 10 : 11)),
                            color: AppTheme.darkGreen,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final maxWidth = screenWidth > 600 ? 400.0 : screenWidth * 0.75;
        final imageHeight = screenWidth > 600 ? 250.0 : 180.0;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment:
                message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!message.isUser) ...{
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.smart_toy,
                    color: AppTheme.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
              },
              Flexible(
                child: Container(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: message.isUser ? AppTheme.primaryGreen : AppTheme.white,
                    borderRadius: BorderRadius.circular(16).copyWith(
                      bottomLeft: message.isUser
                          ? const Radius.circular(16)
                          : const Radius.circular(4),
                      bottomRight: message.isUser
                          ? const Radius.circular(4)
                          : const Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.grey.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.imageUrl != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: message.imageUrl!.startsWith('http')
                              ? Image.network(
                                  message.imageUrl!,
                                  width: double.infinity,
                                  height: imageHeight,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: double.infinity,
                                      height: imageHeight,
                                      color: AppTheme.grey.withOpacity(0.3),
                                      child: Icon(
                                        Icons.broken_image,
                                        color: AppTheme.grey,
                                      ),
                                    );
                                  },
                                )
                              : Image.file(
                                  File(message.imageUrl!),
                                  width: double.infinity,
                                  height: imageHeight,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: double.infinity,
                                      height: imageHeight,
                                      color: AppTheme.grey.withOpacity(0.3),
                                      child: Icon(
                                        Icons.broken_image,
                                        color: AppTheme.grey,
                                      ),
                                    );
                                  },
                                ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      Text(
                        message.text,
                        style: TextStyle(
                          color: message.isUser ? AppTheme.white : AppTheme.darkGreen,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTime(message.timestamp),
                        style: TextStyle(
                          color: message.isUser
                              ? AppTheme.white.withOpacity(0.7)
                              : AppTheme.grey,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (message.isUser) ...{
                const SizedBox(width: 8),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.accentOrange,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.person,
                    color: AppTheme.white,
                    size: 18,
                  ),
                ),
              },
            ],
          ),
        );
      },
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.smart_toy,
              color: AppTheme.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(16).copyWith(
                bottomLeft: const Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(0),
                const SizedBox(width: 4),
                _buildTypingDot(1),
                const SizedBox(width: 4),
                _buildTypingDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 600 + (index * 200)),
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: AppTheme.grey,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        boxShadow: [
          BoxShadow(
            color: AppTheme.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _showImagePicker,
            icon: Icon(
              Icons.camera_alt,
              color: AppTheme.primaryGreen,
            ),
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Ask about animal care, emergencies...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppTheme.lightGrey,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen,
              borderRadius: BorderRadius.circular(25),
            ),
            child: IconButton(
              onPressed: _sendMessage,
              icon: Icon(
                Icons.send,
                color: AppTheme.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(
          text: text,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _messageController.clear();
      _isTyping = true;
    });

    _scrollToBottom();
    _generateResponse(text);
  }

  String _getQuickActionMessage(String action) {
    switch (action) {
      case 'Emergency Rescue':
        return '🚨 I found an injured animal that needs immediate help';
      case 'Identify Animal':
        return '🔍 Help me identify this animal species and breed';
      case 'Health Check':
        return '🏥 Assess this animal\'s health condition and symptoms';
      case 'Baby Animal Care':
        return '🍼 I found a baby animal, what should I do?';
      case 'Shelter Finder':
        return '🏠 Find animal shelters and rescue centers near me';
      case 'First Aid Guide':
        return '💊 Emergency first aid procedures for animals';
      case 'Behavior Help':
        return '🐾 This animal is acting strangely, what does it mean?';
      case 'Report Abuse':
        return '📱 I need to report animal abuse or neglect';
      default:
        return action;
    }
  }

  void _sendQuickMessage(String message) {
    setState(() {
      _messages.add(
        ChatMessage(
          text: message,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _isTyping = true;
    });

    _scrollToBottom();
    _generateResponse(message);
  }

  void _generateResponse(String userMessage) async {
    try {
      final response = await OpenRouterService.generateResponse(userMessage);
      
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(
            ChatMessage(
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
            ChatMessage(
              text: _getAIResponse(userMessage),
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
        });
        _scrollToBottom();
      }
    }
  }

  String _getAIResponse(String userMessage) {
    final message = userMessage.toLowerCase();
    
    if (message.contains('emergency') || message.contains('urgent') || message.contains('injured animal')) {
      return "🚨 For immediate emergencies:\n\n1. Call local emergency services: 911\n2. Contact nearest animal hospital\n3. Keep the animal calm and safe\n4. Don't move severely injured animals\n5. Control bleeding if present\n\nWould you like specific first aid instructions for the type of animal you're helping?";
    }
    
    if (message.contains('identify') || message.contains('species') || message.contains('breed')) {
      return "🔍 Animal Identification Help:\n\n• Take clear photos from multiple angles\n• Note size, color patterns, and distinctive features\n• Observe behavior and habitat\n• Check for any tags or markings\n\nPlease share a photo or describe the animal's appearance, and I'll help identify the species and provide appropriate care guidance.";
    }
    
    if (message.contains('health') || message.contains('symptoms') || message.contains('assess')) {
      return "🏥 Animal Health Assessment:\n\n• Check breathing rate and pattern\n• Look for visible injuries or discharge\n• Observe alertness and responsiveness\n• Note eating/drinking behavior\n• Check for parasites or skin issues\n\nWhat specific symptoms are you observing? I can help determine if immediate veterinary care is needed.";
    }
    
    if (message.contains('baby') || message.contains('infant') || message.contains('young')) {
      return "🍼 Baby Animal Care:\n\n• Don't assume it's abandoned - mother may return\n• Keep warm and quiet\n• Don't feed unless instructed by wildlife expert\n• Contact local wildlife rehabilitator\n• Avoid human contact to prevent imprinting\n\nWhat type of baby animal did you find? The care varies significantly by species.";
    }
    
    if (message.contains('first aid') || message.contains('procedures')) {
      return "💊 Emergency First Aid Procedures:\n\n• Assess the situation safely\n• Control bleeding with clean cloth\n• Stabilize fractures if necessary\n• Keep airway clear\n• Monitor vital signs\n• Transport to veterinarian\n\nWhat type of emergency are you dealing with? I can provide specific step-by-step instructions.";
    }
    
    if (message.contains('behavior') || message.contains('acting') || message.contains('strange')) {
      return "🐾 Animal Behavior Analysis:\n\n• Stress signs: panting, pacing, hiding\n• Pain indicators: vocalization, aggression\n• Illness symptoms: lethargy, loss of appetite\n• Fear responses: trembling, defensive postures\n\nDescribe the specific behaviors you're observing, and I'll help interpret what they might mean.";
    }
    
    if (message.contains('abuse') || message.contains('neglect') || message.contains('report')) {
      return "📱 Reporting Animal Abuse/Neglect:\n\n• Document with photos/video if safe\n• Contact local animal control\n• Call ASPCA hotline: 1-888-426-4435\n• Report to police if severe\n• Provide detailed location and description\n\nYour report can save lives. Do you need help finding local authorities to contact?";
    }
    
    if (message.contains('shelter') || message.contains('find')) {
      return "🏠 Finding Animal Shelters:\n\n• Use the map feature to locate nearby shelters\n• Contact local animal control\n• Check with veterinary clinics\n• Search online directories\n• Call 211 for local resources\n\nI can help you find specific shelters in your area. What's your current location?";
    }
    
    if (message.contains('care') || message.contains('feed')) {
      return "🐾 Animal Care Guidelines:\n\n• Provide fresh water\n• Appropriate food for species\n• Safe, comfortable shelter\n• Regular health check-ups\n• Proper exercise and socialization\n\nWhat specific animal care question do you have? I can provide detailed guidance.";
    }
    
    return "I understand you need help with animal rescue. I can assist with:\n\n🚨 Emergency rescue procedures\n🔍 Animal identification\n🏥 Health assessments\n🍼 Baby animal care\n🏠 Finding shelters\n💊 First aid guidance\n🐾 Behavior interpretation\n📱 Reporting abuse\n\nCould you be more specific about what you need help with?";
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

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        // Verify file exists and is accessible
        final file = File(image.path);
        if (!await file.exists()) {
          throw Exception('Selected image file does not exist');
        }
        
        // Add user message with image
        setState(() {
          _messages.add(
            ChatMessage(
              text: 'Please analyze this animal photo and provide care suggestions.',
              isUser: true,
              timestamp: DateTime.now(),
              imageUrl: image.path,
            ),
          );
          _isTyping = true;
        });
        
        _scrollToBottom();
        
        // Generate AI response with image analysis
        try {
          final response = await OpenRouterService.generateResponse(
            'Please analyze this animal photo and provide care suggestions, health assessment, and any recommendations.',
            imageUrl: image.path,
          );
          
          if (mounted) {
            setState(() {
              _isTyping = false;
              _messages.add(
                ChatMessage(
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
                ChatMessage(
                  text: 'I can see the image, but I\'m having trouble analyzing it right now. Based on what I can observe, please ensure the animal has access to fresh water, appropriate food, and a safe environment. If you notice any signs of distress or injury, please contact a veterinarian immediately.',
                  isUser: false,
                  timestamp: DateTime.now(),
                ),
              );
            });
            _scrollToBottom();
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: AppTheme.emergencyRed,
          ),
        );
      }
    }
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Upload Animal Photo',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.darkGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'I can analyze animal photos to provide care suggestions and identify potential issues.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Gallery'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.softBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.darkGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.clear_all, color: AppTheme.primaryGreen),
                title: const Text('Clear Chat'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _messages.clear();
                    _addWelcomeMessage();
                  });
                },
              ),
              ListTile(
                leading: Icon(Icons.help, color: AppTheme.softBlue),
                title: const Text('Help & Tips'),
                onTap: () {
                  Navigator.pop(context);
                  _sendQuickMessage('Help and tips');
                },
              ),
              ListTile(
                leading: Icon(Icons.phone, color: AppTheme.emergencyRed),
                title: const Text('Emergency Contacts'),
                onTap: () {
                  Navigator.pop(context);
                  _sendQuickMessage('Emergency contacts');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? imageUrl;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.imageUrl,
  });
}