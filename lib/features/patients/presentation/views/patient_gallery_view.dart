// lib/features/patients/presentation/views/patient_gallery_view.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/patient.dart';
import '../bloc/patient_bloc.dart';
import '../bloc/patient_event.dart';

class PatientGalleryView extends StatelessWidget {
  final Patient patient;
  final ImagePicker _picker = ImagePicker();

  PatientGalleryView({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: patient.photoPaths.isEmpty
              ? const Center(child: Text("Nenhuma foto de evolução cadastrada"))
              : GridView.builder(
                  padding: const EdgeInsets.all(24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: patient.photoPaths.length,
                  itemBuilder: (context, index) => ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(File(patient.photoPaths[index]), fit: BoxFit.cover),
                  ),
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: ElevatedButton.icon(
            onPressed: () async {
              final XFile? image = await _picker.pickImage(source: ImageSource.camera);
              if (image != null && context.mounted) {
                context.read<PatientBloc>().add(AddPhotoToPatient(patient.id, image.path));
              }
            },
            icon: const Icon(Icons.camera_alt),
            label: const Text("ADICIONAR FOTO"),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: const Color(0xFF7C3AED),
            ),
          ),
        ),
      ],
    );
  }
}