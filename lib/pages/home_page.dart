import 'package:flutter/material.dart';
import 'add_ticket.dart';
import 'package:skl_1_event_ticketing/services/api_service.dart';
import 'scanner_page.dart';
import '../models/ticket.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _api = ApiService();
  List<Ticket> _tickets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshTickets();
  }

  Future<void> _refreshTickets() async {
    setState(() => _isLoading = true);
    try {
      final data = await _api.getTickets();
      setState(() => _tickets = data);
    } finally {
      setState(() => _isLoading = false);
    }
    FlutterNativeSplash.remove();

  }

  Future<void> _deleteTicket(String id) async {
    await _api.deleteTicket(id);
    _refreshTickets();
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'redeemed':
        return Colors.red;
      case 'unredeemed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Event Scanner',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _tickets.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.confirmation_number_outlined,
                            size: 64, color: Colors.grey),
                        SizedBox(height: 12),
                        Text(
                          'No tickets yet',
                          style: TextStyle(
                              fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _refreshTickets,
                    child: ListView.builder(
                      itemCount: _tickets.length,
                      itemBuilder: (context, index) {
                        final ticket = _tickets[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding:
                                const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                            title: Text(
                              ticket.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6, left: 0),
                              child: Chip(
                                label: Text(
                                  ticket.status,
                                  style: const TextStyle(
                                      color: Colors.white),
                                ),
                                backgroundColor:
                                    _statusColor(ticket.status),
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.red),
                              onPressed: () =>
                                  _deleteTicket(ticket.id),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.add),
          label: const Text(
            'Add Ticket',
            style: TextStyle(fontSize: 16),
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddTicketPage()),
          ).then((_) => _refreshTickets()),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Scan'),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ScannerPage()),
        ).then((_) => _refreshTickets()),
      ),
    );
  }
}
