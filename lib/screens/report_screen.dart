import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/app_theme.dart';
import '../models/animal_report_model.dart';
import '../services/supabase_service.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contactController = TextEditingController();
  final _addressController = TextEditingController();
  
  AnimalType _selectedAnimalType = AnimalType.dog;
  AnimalCondition _selectedCondition = AnimalCondition.injured;
  bool _isEmergency = false;
  List<XFile> _selectedImages = [];
  
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cream,
      appBar: AppBar(
        title: const Text('Report Animal in Need'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: AppTheme.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emergency toggle
              _buildEmergencyToggle(),
              const SizedBox(height: 24),
              
              // Basic Information
              _buildBasicInformation(),
              const SizedBox(height: 24),
              
              // Animal Details
              _buildAnimalDetails(),
              const SizedBox(height: 24),
              
              // Location Information
              _buildLocationInformation(),
              const SizedBox(height: 24),
              
              // Images Section
              _buildImagesSection(),
              const SizedBox(height: 24),
              
              // Contact Information
              _buildContactInformation(),
              const SizedBox(height: 32),
              
              // Submit Button
              _buildSubmitButton(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildEmergencyToggle() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _isEmergency ? AppTheme.emergencyRed.withOpacity(0.1) : AppTheme.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isEmergency ? AppTheme.emergencyRed : AppTheme.lightGrey.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _isEmergency ? AppTheme.emergencyRed.withOpacity(0.2) : AppTheme.grey.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _isEmergency ? AppTheme.emergencyRed.withOpacity(0.2) : AppTheme.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              Icons.warning,
              color: _isEmergency ? AppTheme.emergencyRed : AppTheme.grey,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Emergency Report',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: _isEmergency ? AppTheme.emergencyRed : AppTheme.darkGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Toggle if this is an urgent situation requiring immediate attention',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.grey,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isEmergency,
            onChanged: (value) {
              setState(() {
                _isEmergency = value;
              });
            },
            activeColor: AppTheme.emergencyRed,
          ),
        ],
      ),
    );
  }
  
  Widget _buildBasicInformation() {
    return _buildSection(
      title: 'Basic Information',
      children: [
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Report Title',
            hintText: 'Brief description of the situation',
            prefixIcon: Icon(Icons.title),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a title';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Detailed Description',
            hintText: 'Describe the animal\'s condition and situation in detail',
            prefixIcon: Icon(Icons.description),
          ),
          maxLines: 4,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a description';
            }
            return null;
          },
        ),
      ],
    );
  }
  
  Widget _buildAnimalDetails() {
    return _buildSection(
      title: 'Animal Details',
      children: [
        DropdownButtonFormField<AnimalType>(
          value: _selectedAnimalType,
          decoration: const InputDecoration(
            labelText: 'Animal Type',
            prefixIcon: Icon(Icons.pets),
          ),
          items: AnimalType.values.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(_getAnimalTypeDisplayName(type)),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedAnimalType = value;
              });
            }
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<AnimalCondition>(
          value: _selectedCondition,
          decoration: const InputDecoration(
            labelText: 'Condition',
            prefixIcon: Icon(Icons.medical_services),
          ),
          items: AnimalCondition.values.map((condition) {
            return DropdownMenuItem(
              value: condition,
              child: Text(_getConditionDisplayName(condition)),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedCondition = value;
              });
            }
          },
        ),
      ],
    );
  }
  
  Widget _buildLocationInformation() {
    return _buildSection(
      title: 'Location Information',
      children: [
        TextFormField(
          controller: _addressController,
          decoration: const InputDecoration(
            labelText: 'Address or Landmark',
            hintText: 'Where is the animal located?',
            prefixIcon: Icon(Icons.location_on),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the location';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.softBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.softBlue.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.softBlue.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.softBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  Icons.my_location,
                  color: AppTheme.softBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Use Current Location',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppTheme.softBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'We\'ll automatically detect your current location',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.grey,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.softBlue.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _getCurrentLocation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.softBlue,
                    foregroundColor: AppTheme.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('Get Location'),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
  
  Widget _buildImagesSection() {
    return _buildSection(
      title: 'Photos (Optional)',
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.lightGrey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.lightGrey.withOpacity(0.3),
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.camera_alt_outlined,
                  size: 52,
                  color: AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Add photos to help others understand the situation',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.grey,
                  fontSize: 16,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryGreen.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera, size: 20),
                      label: const Text('Camera'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: AppTheme.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accentOrange.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library, size: 20),
                      label: const Text('Gallery'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentOrange,
                        foregroundColor: AppTheme.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (_selectedImages.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            '${_selectedImages.length} photo(s) selected',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.primaryGreen,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
  
  Widget _buildContactInformation() {
    return _buildSection(
      title: 'Contact Information',
      children: [
        TextFormField(
          controller: _contactController,
          decoration: const InputDecoration(
            labelText: 'Phone Number (Optional)',
            hintText: 'For urgent communication',
            prefixIcon: Icon(Icons.phone),
          ),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.warningAmber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppTheme.warningAmber,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Your contact information will only be shared with verified volunteers who offer to help.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.darkGreen,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (_isEmergency ? AppTheme.emergencyRed : AppTheme.primaryGreen).withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _submitReport,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isEmergency ? AppTheme.emergencyRed : AppTheme.primaryGreen,
          foregroundColor: AppTheme.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _isEmergency ? Icons.emergency : Icons.send,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _isEmergency ? 'Submit Emergency Report' : 'Submit Report',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSection({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.lightGrey.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.grey.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getSectionIcon(title),
                  color: AppTheme.primaryGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.darkGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
  
  IconData _getSectionIcon(String title) {
    switch (title) {
      case 'Basic Information':
        return Icons.info_outline;
      case 'Animal Details':
        return Icons.pets;
      case 'Location Information':
        return Icons.location_on;
      case 'Photos (Optional)':
        return Icons.camera_alt;
      case 'Contact Information':
        return Icons.contact_phone;
      default:
        return Icons.info;
    }
  }
  
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImages.add(image);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: AppTheme.emergencyRed,
        ),
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permission denied'),
              backgroundColor: AppTheme.emergencyRed,
            ),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permission permanently denied. Please enable in settings.'),
            backgroundColor: AppTheme.emergencyRed,
          ),
        );
        return;
      }

      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Getting your location...'),
          duration: Duration(seconds: 2),
        ),
      );

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      // Update address field with coordinates (you can implement reverse geocoding here)
      _addressController.text = 'Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}';
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location obtained successfully!'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error getting location: $e'),
          backgroundColor: AppTheme.emergencyRed,
        ),
      );
    }
  }
  
  Future<void> _submitReport() async {
    if (_formKey.currentState!.validate()) {
      if (_addressController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please provide a location for the animal'),
            backgroundColor: AppTheme.emergencyRed,
          ),
        );
        return;
      }

      try {
        // Show loading
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

        // Parse coordinates from address if it contains lat/lng
        double latitude = -1.2921; // Default to Nairobi
        double longitude = 36.8219;
        
        if (_addressController.text.contains('Lat:') && _addressController.text.contains('Lng:')) {
          final parts = _addressController.text.split(', ');
          latitude = double.parse(parts[0].split(': ')[1]);
          longitude = double.parse(parts[1].split(': ')[1]);
        }

        // Upload images first
        List<String> imageUrls = [];
        for (XFile image in _selectedImages) {
          try {
            final imageUrl = await SupabaseService.uploadImage(image, image.name);
            if (imageUrl != null) {
              imageUrls.add(imageUrl);
            }
          } catch (e) {
            print('Error uploading image: $e');
          }
        }

        // Create report
        final currentUser = SupabaseService.currentUser;
        final report = AnimalReportModel(
          id: '',
          reporterId: currentUser?.id ?? '', // Will be converted to null in toJson for anonymous users
          reporterName: currentUser?.email ?? 'Anonymous',
          title: _titleController.text,
          description: _descriptionController.text,
          animalType: _selectedAnimalType,
          condition: _selectedCondition,
          latitude: latitude,
          longitude: longitude,
          address: _addressController.text,
          imageUrls: imageUrls,
          status: ReportStatus.reported,
          isEmergency: _isEmergency,
          contactPhone: _contactController.text.isNotEmpty ? _contactController.text : null,
          contactName: currentUser?.email ?? 'Anonymous',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await SupabaseService.createReport(report);
        
        // Hide loading
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEmergency 
                  ? 'Emergency report submitted! Nearby volunteers will be notified immediately.'
                  : 'Report submitted successfully! We\'ll notify nearby volunteers.',
            ),
            backgroundColor: AppTheme.successGreen,
            duration: const Duration(seconds: 4),
          ),
        );
        
        // Clear form
        _formKey.currentState!.reset();
        _titleController.clear();
        _descriptionController.clear();
        _contactController.clear();
        _addressController.clear();
        setState(() {
          _selectedImages.clear();
          _isEmergency = false;
          _selectedAnimalType = AnimalType.dog;
          _selectedCondition = AnimalCondition.injured;
        });
        
        // Navigate back to home
        Navigator.of(context).pop();
        
      } catch (e) {
        // Hide loading
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting report: $e'),
            backgroundColor: AppTheme.emergencyRed,
          ),
        );
      }
    }
  }
  
  String _getAnimalTypeDisplayName(AnimalType type) {
    switch (type) {
      case AnimalType.dog:
        return 'Dog';
      case AnimalType.cat:
        return 'Cat';
      case AnimalType.bird:
        return 'Bird';
      case AnimalType.wildlife:
        return 'Wildlife';
      case AnimalType.livestock:
        return 'Livestock';
      case AnimalType.other:
        return 'Other';
    }
  }
  
  String _getConditionDisplayName(AnimalCondition condition) {
    switch (condition) {
      case AnimalCondition.injured:
        return 'Injured';
      case AnimalCondition.sick:
        return 'Sick';
      case AnimalCondition.lost:
        return 'Lost';
      case AnimalCondition.abandoned:
        return 'Abandoned';
      case AnimalCondition.trapped:
        return 'Trapped';
      case AnimalCondition.aggressive:
        return 'Aggressive';
      case AnimalCondition.dead:
        return 'Dead';
      case AnimalCondition.other:
        return 'Other';
    }
  }
}