import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import 'package:untitl/video_hd.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Video Player'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isLoading = false;
  String errorMessage = '';
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();

  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(errorMessage), // Display error message if any
            const SizedBox(height: 20),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: _downloadAndPlayVideo,
              child: const Text('Download & Play Video'),
            ),
            const SizedBox(height: 20),
            !isLoading?const SizedBox(): _controller!=null?AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: VideoPlayer(_controller!),
            ):const SizedBox(),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadAndPlayVideo() async {
    setState(() {
      isLoading = true;
      errorMessage = ''; // Clear any previous error message
    });

    try {
      final status = await Permission.storage.request();
      if (status == PermissionStatus.granted) {
        final dio = Dio();
        const savePath = '/storage/emulated/0/Download/video.mp4'; // Change the path as needed
        await dio.download(
          "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
          savePath,
        );

     VideoPlayerController   _controller = VideoPlayerController.file(File(savePath));
     _controller.initialize().then((value){
       _controller.play();
       Navigator.push(context, MaterialPageRoute(builder: (context) => VideoPlayerPage(controller: _controller),));
     });

      } else {
        setState(() {
          errorMessage =
          'Storage permission denied. Please grant permission to download the video.';
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = 'Error downloading or playing video: $error';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
