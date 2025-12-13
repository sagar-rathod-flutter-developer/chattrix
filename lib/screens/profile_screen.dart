
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../bloc/profile/profile_bloc.dart';
import '../bloc/profile/profile_event.dart';
import '../bloc/profile/profile_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoading) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Uploading image...")),
            );
          }
          if (state is ProfileSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Profile updated")),
            );
          }
        },
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final data =
                snapshot.data!.data() as Map<String, dynamic>? ?? {};

            final imageUrl = data['imageUrl'] ?? '';

            return Column(
              children: [
                const SizedBox(height: 20),

                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final picked =
                        await picker.pickImage(source: ImageSource.gallery);

                    if (picked != null) {
                      context.read<ProfileBloc>().add(
                            UploadProfileImageEvent(picked.path),
                          );
                    }
                  },
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage:
                        imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                    child: imageUrl.isEmpty
                        ? const Icon(Icons.person, size: 40)
                        : null,
                  ),
                ),

                const SizedBox(height: 16),
                Text(
                  data['name'] ?? '',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(data['email'] ?? ''),
              ],
            );
          },
        ),
      ),
    );
  }
}
