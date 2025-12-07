import 'package:hive/hive.dart';

part 'job.g.dart';

@HiveType(typeId: 0)
class Job extends HiveObject {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String company_name;
  @HiveField(2)
  final String job_title;
  @HiveField(3)
  final String location;
  @HiveField(4)
  final double latitude;
  @HiveField(5)
  final double longitude;
  @HiveField(6)
  final String address;
  @HiveField(7)
  final double salary;
  @HiveField(8)
  final String work_days;
  @HiveField(9)
  final String work_hours;
  @HiveField(10)
  final String education_level;
  @HiveField(11)
  final String description;
  @HiveField(12)
  final List<String> requirements;
  @HiveField(13)
  final List<String> skills;
  @HiveField(14)
  final String image;

  Job({
    required this.id,
    required this.company_name,
    required this.job_title,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.salary,
    required this.work_days,
    required this.work_hours,
    required this.education_level,
    required this.description,
    required this.requirements,
    required this.skills,
    required this.image,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'],
      company_name: json['company_name'],
      job_title: json['job_title'],
      location: json['location'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      address: json['address'] as String? ?? 'Alamat tidak tersedia',
      salary: json['salary'].toDouble(),
      work_days: json['work_days'],
      work_hours: json['work_hours'],
      education_level: json['education_level'],
      description: json['description'],
      requirements: List<String>.from(json['requirements'] ?? []),
      skills: List<String>.from(json['skills'] ?? []),
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_name': company_name,
      'job_title': job_title,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'salary': salary,
      'work_days': work_days,
      'work_hours': work_hours,
      'education_level': education_level,
      'description': description,
      'requirements': requirements,
      'skills': skills,
      'image': image,
    };
  }
}
