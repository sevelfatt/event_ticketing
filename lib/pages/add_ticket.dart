import 'package:flutter/material.dart';
import 'package:skl_1_event_ticketing/services/api_service.dart';

class AddTicketPage extends StatefulWidget {
  const AddTicketPage({super.key});

  @override
  _AddTicketPageState createState() => _AddTicketPageState();
}

class _AddTicketPageState extends State<AddTicketPage> {
  final ApiService _api = ApiService();
  final _textController = TextEditingController();

  Future<void> _submit() async {
    if (_textController.text.isEmpty) return;

    try {
      await _api.addTicket(_textController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ticket added successfully!')),
      );
      _textController.clear();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add ticket.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Ticket'),
        centerTitle: true,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Create a new ticket',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Enter ticket name',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
              ),
              child: const Text(
                'Submit',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
