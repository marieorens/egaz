import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:egaz/autres_pages/intermediate_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    
    _controller = VideoPlayerController.asset("assets/videos/egass.mp4")
      ..initialize().then((_) {
        setState(() {}); 
        _controller.play(); 
      });

    
    _controller.addListener(() {
    
      if (_controller.value.position == _controller.value.duration) {
      
      
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const IntermediatePage()),
          );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      body: Center(
        child: _controller.value.isInitialized
            ? SizedBox.expand( 
                child: FittedBox(
                  fit: BoxFit.cover, 
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                ),
              )
            : const CircularProgressIndicator(), 
      ),
    );
  }
}
