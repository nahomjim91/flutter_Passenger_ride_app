import 'package:flutter/material.dart';
import 'package:ride_app/compont/firebaseUtillies.dart';
import 'package:ride_app/compont/uploadImage.dart';
import 'package:ride_app/passenger.dart';

// ignore: must_be_immutable
class ProfilePage extends StatefulWidget {
  Passenger passenger;
  ProfilePage({super.key, required this.passenger});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            ProfilePic(
              passenger: widget.passenger,
              isShowPhotoUpload: false,
            ),
            Text(
              "${widget.passenger.first_name} ${widget.passenger.last_name}",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(height: 16.0 * 2),
            //
            Info(
              infoKey: "Location",
              info: "New York, NYC",
            ),
            Info(
              infoKey: "Phone",
              info: widget.passenger.phone_number,
            ),
            Info(
              infoKey: "Email Address",
              info: widget.passenger.email,
            ),
            const SizedBox(height: 16.0),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 160,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamed('editProfile');
                  },
                  child: const Text("Edit profile"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class ProfilePic extends StatefulWidget {
  ProfilePic({
    super.key,
    required this.passenger,
    this.isShowPhotoUpload = false,
    this.imageUploadBtnPress,
    this.resized = false,
  });

  Passenger passenger;
  final bool resized;
  final bool isShowPhotoUpload;
  final VoidCallback? imageUploadBtnPress;

  @override
  State<ProfilePic> createState() => _ProfilePicState();
}

class _ProfilePicState extends State<ProfilePic> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(widget.resized ? 10 : 16.0),
      margin: EdgeInsets.symmetric(vertical: widget.resized ? 10 : 16.0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color:
              Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.08),
        ),
      ),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: widget.resized ? 60 : 50,
            backgroundColor: Colors.grey.shade800,
            child: ClipOval(
              child: Image.network(
                "http://127.0.0.1:8000${widget.passenger.profile_photo!}",
                width: widget.resized ? 120 : 100,
                height: widget.resized ? 120 : 100,
                fit: BoxFit.cover,
                cacheWidth: 100 * 2,
                cacheHeight: 100 * 2,
                headers: {
                  'Accept': '*/*',
                },
                errorBuilder: (context, error, stackTrace) {
                  print("Error loading image: $error");
                  return Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey,
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.white,
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).primaryColor,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              ),
            ),
          ),
          if (widget.isShowPhotoUpload)
            InkWell(
              onTap: () => Uploadimage().pickAndUploadImage(
                context,
                widget.passenger,
                (String newPhotoPath) {
                  setState(() {
                    widget.passenger.profile_photo = newPhotoPath;
                    Firebaseutillies()
                        .savePassengerToFirestore(widget.passenger);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile photo updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
              ),
              child: CircleAvatar(
                radius: 13,
                backgroundColor: Colors.red,
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class Info extends StatelessWidget {
  const Info({
    super.key,
    required this.infoKey,
    required this.info,
  });

  final String infoKey, info;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            infoKey,
            style: TextStyle(
              color: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .color!
                  .withOpacity(0.8),
            ),
          ),
          Text(info),
        ],
      ),
    );
  }
}
