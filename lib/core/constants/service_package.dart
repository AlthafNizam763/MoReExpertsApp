import 'package:flutter/material.dart';

enum ServicePackage { silver, silver2, golden, golden2, premium, premium2 }

class PackageInfo {
  final ServicePackage id;
  final String name;
  final String price;
  final String description;
  final List<Color> gradientColors;
  final List<String> includedDocuments;
  final List<String> includedServices;

  const PackageInfo({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.gradientColors,
    required this.includedDocuments,
    required this.includedServices,
  });

  static const List<PackageInfo> allPackages = [
    PackageInfo(
      id: ServicePackage.silver,
      name: 'Silver',
      price: '₹250',
      description: 'Standard professional resume service.',
      gradientColors: [Color(0xFFC0C0C0), Color(0xFF8E8E8E)],
      includedDocuments: ['Resume PDF'],
      includedServices: ['Standard Resume Writing', 'No Updates Included'],
    ),
    PackageInfo(
      id: ServicePackage.silver2,
      name: 'Silver 2nd',
      price: '₹350',
      description: 'Enhanced resume service with source files.',
      gradientColors: [Color(0xFF757575), Color(0xFF424242)],
      includedDocuments: ['Resume PDF', 'Resume Word Document'],
      includedServices: ['Standard Resume Writing', 'No Updates Included'],
    ),
    PackageInfo(
      id: ServicePackage.golden,
      name: 'Golden',
      price: '₹450',
      description: 'Professional package with cover letter and updates.',
      gradientColors: [Color(0xFF1A1A1A), Color(0xFF0D0D0D)],
      includedDocuments: ['Resume PDF', 'Resume Word Document', 'Cover Letter'],
      includedServices: [
        'Premium Resume Writing',
        'Custom Cover Letter',
        '3 Months Updation Period'
      ],
    ),
    PackageInfo(
      id: ServicePackage.golden2,
      name: 'Golden 2nd',
      price: '₹550',
      description: 'Advanced professional package with extended updates.',
      gradientColors: [Color(0xFFF5A623), Color(0xFFD48806)],
      includedDocuments: ['Resume PDF', 'Resume Word Document', 'Cover Letter'],
      includedServices: [
        'Premium Resume Writing',
        'Custom Cover Letter',
        '6 Months Updation Period'
      ],
    ),
    PackageInfo(
      id: ServicePackage.premium,
      name: 'Premium',
      price: '₹600',
      description: 'Executive level package with multiple models.',
      gradientColors: [Color(0xFF0F0F0B), Color(0xFF1C1C1C)],
      includedDocuments: [
        'Resume PDF (Colour)',
        'Resume PDF (Black & White)',
        'Resume PDF (Horizontal)',
        'Resume Word Document',
        'Cover Letter'
      ],
      includedServices: [
        'Three Models: Colour, B&W, Horizontal',
        'Executive Branding',
        '1 Year Updation Period'
      ],
    ),
    PackageInfo(
      id: ServicePackage.premium2,
      name: 'Premium 2nd',
      price: '₹650',
      description: 'Ultimate career advancement with lifetime support.',
      gradientColors: [Color(0xFF2C0A3B), Color(0xFF0F0F0F)],
      includedDocuments: [
        'Resume PDF (Colour)',
        'Resume PDF (Black & White)',
        'Resume PDF (Horizontal)',
        'Resume Word Document',
        'Cover Letter'
      ],
      includedServices: [
        'Three Models: Colour, B&W, Horizontal',
        'Lifetime Updation Period',
        'Priority Career Support'
      ],
    ),
  ];
}
