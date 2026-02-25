import 'package:asip_fitness_analytics/features/session/provider/session_provider.dart';
import 'package:asip_fitness_analytics/features/session/widgets/exercise_form.dart';
import 'package:asip_fitness_analytics/shared/models/workout_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

class SessionRegistrationScreen extends ConsumerStatefulWidget {
  const SessionRegistrationScreen({super.key});

  @override
  ConsumerState<SessionRegistrationScreen> createState() => _SessionRegistrationScreenState();
}

class _SessionRegistrationScreenState extends ConsumerState<SessionRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _exerciseController = TextEditingController();
  final _setsController = TextEditingController();
  final _repsController = TextEditingController();
  final _weightController = TextEditingController();
  final _rpeController = TextEditingController();
  final _heartRateController = TextEditingController();
  final _bodyweightController = TextEditingController();
  final _sleepController = TextEditingController();

  bool _useRIR = false;
  double _sessionLoad = 0;

  void _calculateSessionLoad() {
    final sets = int.tryParse(_setsController.text) ?? 0;
    final reps = int.tryParse(_repsController.text) ?? 0;
    final weight = double.tryParse(_weightController.text) ?? 0;
    final rpe = int.tryParse(_rpeController.text) ?? 0;

    setState(() {
      _sessionLoad = sets * reps * weight * (1 + (rpe / 10));
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final session = WorkoutSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      exerciseName: _exerciseController.text,
      sets: int.parse(_setsController.text),
      repetitions: int.parse(_repsController.text),
      weight: double.parse(_weightController.text),
      rpe: _useRIR ? null : int.tryParse(_rpeController.text),
      rir: _useRIR ? int.tryParse(_rpeController.text) : null,
      heartRate: int.tryParse(_heartRateController.text),
      bodyweight: double.tryParse(_bodyweightController.text),
      sleepHours: int.tryParse(_sleepController.text),
      sessionLoad: _sessionLoad,
    );

    final success = await ref.read(sessionControllerProvider.notifier).submitSession(session);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session submitted successfully'),
          backgroundColor: Colors.green,
        ),
      );
      _clearForm();
    }
  }

  void _clearForm() {
    _exerciseController.clear();
    _setsController.clear();
    _repsController.clear();
    _weightController.clear();
    _rpeController.clear();
    _heartRateController.clear();
    _bodyweightController.clear();
    _sleepController.clear();
    setState(() => _sessionLoad = 0);
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(sessionControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Session'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ExerciseForm(
                exerciseController: _exerciseController,
                setsController: _setsController,
                repsController: _repsController,
                weightController: _weightController,
                onChanged: _calculateSessionLoad,
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Text('Use RIR instead of RPE'),
                          const SizedBox(width: 8),
                          Switch(
                            value: _useRIR,
                            onChanged: (value) {
                              setState(() => _useRIR = value);
                              _calculateSessionLoad();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _rpeController,
                        decoration: InputDecoration(
                          labelText: _useRIR ? 'RIR' : 'RPE',
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onChanged: (_) => _calculateSessionLoad(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter ${_useRIR ? 'RIR' : 'RPE'}';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _heartRateController,
                        decoration: const InputDecoration(
                          labelText: 'Heart Rate (bpm)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _bodyweightController,
                        decoration: const InputDecoration(
                          labelText: 'Bodyweight (kg)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _sleepController,
                        decoration: const InputDecoration(
                          labelText: 'Sleep (hours)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Session Load:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      _sessionLoad.toStringAsFixed(0),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: sessionState.isLoading ? null : _submitForm,
                child: sessionState.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Submit Session'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}