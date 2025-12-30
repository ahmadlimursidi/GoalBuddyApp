// Sample drill session with Lottie animations
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class DrillSessionScreen extends StatefulWidget {
  final String drillName;
  final String animationAssetPath;

  const DrillSessionScreen({
    super.key,
    required this.drillName,
    required this.animationAssetPath,
  });

  @override
  _DrillSessionScreenState createState() => _DrillSessionScreenState();
}

class _DrillSessionScreenState extends State<DrillSessionScreen> {
  int _currentStep = 0;
  bool _isPlaying = false;

  final List<String> _drillSteps = [
    "Get ready!",
    "Start the drill",
    "Keep going!",
    "Great job!",
    "Finished!"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.drillName),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lottie animation
            SizedBox(
              width: 200,
              height: 200,
              child: Lottie.asset(
                widget.animationAssetPath,
                fit: BoxFit.contain,
              ),
            ),
            if (widget.drillName.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  widget.drillName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            
            const SizedBox(height: 32),
            
            // Current step display
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _drillSteps[_currentStep],
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Progress indicator
            LinearProgressIndicator(
              value: (_currentStep + 1) / _drillSteps.length,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Text(
              "${(_currentStep + 1)}/${_drillSteps.length}",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            
            const SizedBox(height: 32),
            
            // Control buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _currentStep > 0 ? _previousStep : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Previous"),
                ),
                
                ElevatedButton(
                  onPressed: _isPlaying ? _pauseAnimation : _playAnimation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isPlaying 
                        ? Colors.orange 
                        : Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(_isPlaying ? "Pause" : "Play"),
                ),
                
                ElevatedButton(
                  onPressed: _currentStep < _drillSteps.length - 1 
                      ? _nextStep : _finishDrill,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    _currentStep < _drillSteps.length - 1 
                        ? "Next" 
                        : "Finish"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _nextStep() {
    if (_currentStep < _drillSteps.length - 1) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _playAnimation() {
    setState(() {
      _isPlaying = true;
    });
  }

  void _pauseAnimation() {
    setState(() {
      _isPlaying = false;
    });
  }

  void _finishDrill() {
    // Handle drill completion
    Navigator.pop(context);
  }
}