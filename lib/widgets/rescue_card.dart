import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/app_theme.dart';

class RescueCard extends StatelessWidget {
  final String? title;
  final String animalType;
  final String condition;
  final String location;
  final String? time;
  final String? timeAgo;
  final String? status;
  final String? imageUrl;
  final bool isEmergency;
  final VoidCallback? onTap;
  
  const RescueCard({
    super.key,
    this.title,
    required this.animalType,
    required this.condition,
    required this.location,
    this.time,
    this.timeAgo,
    this.status,
    this.imageUrl,
    this.isEmergency = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayTime = time ?? timeAgo ?? '';
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isEmergency 
            ? BorderSide(color: AppTheme.emergencyRed, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Image or icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _getAnimalColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getAnimalColor().withOpacity(0.3),
                  ),
                ),
                child: imageUrl != null && imageUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: imageUrl!.startsWith('assets/')
                            ? (imageUrl!.endsWith('.svg')
                                ? SvgPicture.asset(
                                    imageUrl!,
                                    fit: BoxFit.cover,
                                    placeholderBuilder: (context) => Icon(
                                      _getAnimalIcon(),
                                      color: _getAnimalColor(),
                                      size: 30,
                                    ),
                                  )
                                : Image.asset(
                                    imageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        _getAnimalIcon(),
                                        color: _getAnimalColor(),
                                        size: 30,
                                      );
                                    },
                                  ))
                            : Image.network(
                                imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    _getAnimalIcon(),
                                    color: _getAnimalColor(),
                                    size: 30,
                                  );
                                },
                              ),
                      )
                    : Icon(
                        _getAnimalIcon(),
                        color: _getAnimalColor(),
                        size: 30,
                      ),
              ),
              const SizedBox(width: 16),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title or animal type
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title ?? '$animalType - $condition',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.darkGreen,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isEmergency)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.emergencyRed,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'URGENT',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    
                    // Animal type and condition
                    Text(
                      '$animalType • ${condition.toUpperCase()}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _getConditionColor(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    // Location
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    
                    // Time and status
                    Row(
                      children: [
                        if (displayTime.isNotEmpty) ...[
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            displayTime,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                        if (status != null && displayTime.isNotEmpty)
                          const SizedBox(width: 12),
                        if (status != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getStatusColor().withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: _getStatusColor().withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              status!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: _getStatusColor(),
                                fontWeight: FontWeight.w500,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  IconData _getAnimalIcon() {
    switch (animalType.toLowerCase()) {
      case 'dog':
        return Icons.pets;
      case 'cat':
        return Icons.pets;
      case 'bird':
        return Icons.flutter_dash;
      case 'wildlife':
        return Icons.nature;
      case 'livestock':
        return Icons.agriculture;
      default:
        return Icons.pets;
    }
  }
  
  Color _getAnimalColor() {
    switch (animalType.toLowerCase()) {
      case 'dog':
        return AppTheme.primaryBrown;
      case 'cat':
        return AppTheme.primaryGreen;
      case 'bird':
        return AppTheme.softBlue;
      case 'wildlife':
        return AppTheme.darkGreen;
      case 'livestock':
        return AppTheme.accentOrange;
      default:
        return AppTheme.primaryGreen;
    }
  }
  
  Color _getConditionColor() {
    switch (condition.toLowerCase()) {
      case 'critical':
      case 'emergency':
        return AppTheme.emergencyRed;
      case 'injured':
      case 'sick':
        return AppTheme.warningAmber;
      case 'healthy':
      case 'rescued':
        return AppTheme.successGreen;
      default:
        return AppTheme.primaryGreen;
    }
  }
  
  Color _getStatusColor() {
    switch (status?.toLowerCase()) {
      case 'pending':
        return AppTheme.warningAmber;
      case 'in_progress':
      case 'active':
        return AppTheme.softBlue;
      case 'resolved':
      case 'completed':
        return AppTheme.primaryGreen;
      case 'cancelled':
        return AppTheme.grey;
      default:
        return AppTheme.primaryGreen;
    }
  }
}