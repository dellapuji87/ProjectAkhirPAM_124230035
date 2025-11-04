// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class JobAdapter extends TypeAdapter<Job> {
  @override
  final int typeId = 0;

  @override
  Job read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Job(
      id: fields[0] as int,
      company_name: fields[1] as String,
      job_title: fields[2] as String,
      location: fields[3] as String,
      latitude: fields[4] as double,
      longitude: fields[5] as double,
      address: fields[6] as String,
      salary: fields[7] as double,
      work_days: fields[8] as String,
      work_hours: fields[9] as String,
      education_level: fields[10] as String,
      description: fields[11] as String,
      requirements: (fields[12] as List).cast<String>(),
      skills: (fields[13] as List).cast<String>(),
      image: fields[14] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Job obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.company_name)
      ..writeByte(2)
      ..write(obj.job_title)
      ..writeByte(3)
      ..write(obj.location)
      ..writeByte(4)
      ..write(obj.latitude)
      ..writeByte(5)
      ..write(obj.longitude)
      ..writeByte(6)
      ..write(obj.address)
      ..writeByte(7)
      ..write(obj.salary)
      ..writeByte(8)
      ..write(obj.work_days)
      ..writeByte(9)
      ..write(obj.work_hours)
      ..writeByte(10)
      ..write(obj.education_level)
      ..writeByte(11)
      ..write(obj.description)
      ..writeByte(12)
      ..write(obj.requirements)
      ..writeByte(13)
      ..write(obj.skills)
      ..writeByte(14)
      ..write(obj.image);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JobAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
