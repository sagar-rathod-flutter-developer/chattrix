abstract class ProfileEvent {}

class UploadProfileImageEvent extends ProfileEvent {
  final String imagePath;
  UploadProfileImageEvent(this.imagePath);
}
