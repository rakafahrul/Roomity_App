import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rom_app/models/facility.dart';
import 'package:rom_app/services/api_service.dart';

class AdminFacilityDetailScreen extends StatefulWidget {
  final Facility facility;

  const AdminFacilityDetailScreen({required this.facility, super.key});

  @override
  _AdminFacilityDetailScreenState createState() => _AdminFacilityDetailScreenState();
}

class _AdminFacilityDetailScreenState extends State<AdminFacilityDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _name = widget.facility.name;
  }

  Future<void> _updateFacility() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await _apiService.updateFacility(
          widget.facility.id,
          {'name': _name},
        );
        if (mounted) {
          _showSuccess('Facility updated successfully');
          Navigator.pop(context, true); 
        }
      } catch (e) {
        if (mounted) {
          _showError('Failed to update facility: $e');
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _deleteFacility() async {
    setState(() => _isLoading = true);
    try {
      await _apiService.deleteFacility(widget.facility.id);
      if (mounted) {
        _showSuccess('Facility deleted successfully');
        Navigator.pop(context, true); 
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to delete facility: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  void _showSuccess(String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Facility Details')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Form(
                    key: _formKey,
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: 'Facility Name'),
                      initialValue: _name,
                      onChanged: (value) => _name = value,
                      validator: (value) => value!.isEmpty ? 'Enter facility name' : null,
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _updateFacility,
                    child: const Text('Update Facility'),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Confirm Delete'),
                                content: const Text('Are you sure you want to delete this facility?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _deleteFacility();
                                    },
                                    child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Delete Facility'),
                  ),
                ],
              ),
            ),
    );
  }
}